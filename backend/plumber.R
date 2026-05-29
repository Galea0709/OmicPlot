# 富集分析气泡图 API
# 启动（在 backend 目录下）：Rscript -e "plumber::pr('plumber.R')$run(host='127.0.0.1', port=8787)"

# Plumber 解析 multipart 中的 CSV 时会调用 readr，默认刷屏列类型说明
if (requireNamespace("readr", quietly = TRUE)) {
  options(readr.show_col_types = FALSE)
}

# 请在 backend 目录下启动服务，以便正确 source 同目录下的 R 脚本
source("enrichment_logic.R", local = TRUE)

#* CORS
#* @filter cors
function(req, res) {
  res$setHeader("Access-Control-Allow-Origin", "*")
  res$setHeader("Access-Control-Allow-Methods", "GET, POST, OPTIONS")
  res$setHeader("Access-Control-Allow-Headers", "Content-Type, Accept")
  if (identical(req$REQUEST_METHOD, "OPTIONS")) {
    res$status <- 204
    return(list())
  }
  plumber::forward()
}

#* 健康检查（api_signature 用于确认当前进程加载的是哪份 plumber.R、工作目录是否正确）
#* @get /api/health
function() {
  wd <- getwd()
  pr <- tryCatch(normalizePath("plumber.R", mustWork = FALSE), error = function(e) NA_character_)
  mt <- tryCatch({
    fi <- file.info(pr)
    if (is.na(fi$size[1]) || fi$size[1] < 1) {
      NA_character_
    } else {
      format(fi$mtime[1])
    }
  }, error = function(e) NA_character_)
  el <- tryCatch(normalizePath("enrichment_logic.R", mustWork = FALSE), error = function(e) NA_character_)
  el_mt <- tryCatch({
    fi <- file.info(el)
    if (is.na(fi$size[1]) || fi$size[1] < 1) {
      NA_character_
    } else {
      format(fi$mtime[1])
    }
  }, error = function(e) NA_character_)
  list(
    ok = TRUE,
    service = "enrichment-bubble",
    plot_ok_body = "application/json; charset=UTF-8",
    ## 前端可据此判断当前 R 进程是否已加载含 Y 轴样式等参数的 API（需保存 backend 后重启 run_api.R）
    plot_style_param_keys = c(
      "y_wrap_width",
      "axis_y_text_lineheight"
    ),
    api_signature = list(
      cwd = wd,
      plumber_r = pr,
      plumber_r_mtime = mt,
      enrichment_logic_r = el,
      enrichment_logic_r_mtime = el_mt
    )
  )
}

#' Plumber 多版本兼容：上传文件临时路径
upload_tmp_path <- function(file) {
  if (is.null(file)) {
    return(NULL)
  }
  p <- file$datapath
  if (length(p) == 1L && nzchar(p)) {
    return(p)
  }
  p <- file$tmp_filename
  if (length(p) == 1L && nzchar(p)) {
    return(p)
  }
  NULL
}

#' 原始文件名（用于扩展名，临时文件可能无后缀）
upload_orig_name <- function(file) {
  if (is.null(file)) {
    return("")
  }
  n <- file$filename
  if (length(n) == 1L && nzchar(n)) {
    return(n)
  }
  n <- file$name
  if (length(n) == 1L && nzchar(n)) {
    return(n)
  }
  ""
}

#' 将 ggplot/grid 图导出为单页 PDF 的 base64 字符串；失败返回 NULL。
#' Windows 无界面或 ggtext/gridtext 时 grDevices::pdf() 常失败，故依次尝试：
#' cairo_pdf → Cairo::CairoPDF → ragg::agg_pdf → 标准 pdf() → ggplot2::ggsave(..., cairo_pdf)。
export_plot_pdf_base64 <- function(plot_obj, w_in, h_in, tmp_pdf) {
  safe_close_dev <- function() {
    if (grDevices::dev.cur() != 1L) {
      try(grDevices::dev.off(), silent = TRUE)
    }
  }
  wipe_tmp <- function() {
    if (file.exists(tmp_pdf)) {
      unlink(tmp_pdf, force = TRUE)
    }
  }
  dbg <- identical(Sys.getenv("ENRICH_PLOT_DEBUG", ""), "1")

  read_b64_if_valid_pdf <- function() {
    if (!file.exists(tmp_pdf)) {
      return(NULL)
    }
    fi <- file.info(tmp_pdf)
    sz <- fi$size[[1L]]
    if (length(sz) != 1L || is.na(sz) || sz < 80L) {
      wipe_tmp()
      return(NULL)
    }
    rp <- readBin(tmp_pdf, "raw", n = sz)
    hdr <- tryCatch(
      rawToChar(rp[seq_len(min(5L, length(rp)))]),
      error = function(e) ""
    )
    if (!nzchar(hdr) || !startsWith(hdr, "%PDF")) {
      wipe_tmp()
      return(NULL)
    }
    b64 <- jsonlite::base64_enc(rp)
    wipe_tmp()
    b64
  }

  try_draw <- function(open_fn) {
    wipe_tmp()
    tryCatch(
      {
        open_fn()
        print(plot_obj)
        safe_close_dev()
        read_b64_if_valid_pdf()
      },
      error = function(e) {
        safe_close_dev()
        wipe_tmp()
        if (dbg) {
          message("export_plot_pdf_base64 设备失败：", conditionMessage(e))
        }
        NULL
      }
    )
  }

  cairo_on <- tryCatch(
    {
      caps <- grDevices::capabilities()
      v <- unname(caps[["cairo"]])
      isTRUE(as.logical(v)) || identical(as.character(v), "TRUE")
    },
    error = function(e) FALSE
  )

  if (cairo_on) {
    b64 <- try_draw(function() {
      grDevices::cairo_pdf(
        filename = tmp_pdf,
        width = w_in,
        height = h_in,
        onefile = TRUE,
        family = "sans"
      )
    })
    if (!is.null(b64) && nzchar(b64)) {
      return(b64)
    }
  }

  if (requireNamespace("Cairo", quietly = TRUE)) {
    b64 <- try_draw(function() {
      Cairo::CairoPDF(file = tmp_pdf, width = w_in, height = h_in, bg = "white")
    })
    if (!is.null(b64) && nzchar(b64)) {
      return(b64)
    }
  }

  if (requireNamespace("ragg", quietly = TRUE)) {
    b64 <- try_draw(function() {
      ragg::agg_pdf(tmp_pdf, width = w_in, height = h_in, units = "in", bg = "white")
    })
    if (!is.null(b64) && nzchar(b64)) {
      return(b64)
    }
  }

  b64 <- try_draw(function() {
    grDevices::pdf(
      file = tmp_pdf,
      width = w_in,
      height = h_in,
      useDingbats = FALSE,
      onefile = TRUE,
      family = "sans"
    )
  })
  if (!is.null(b64) && nzchar(b64)) {
    return(b64)
  }

  if (cairo_on && requireNamespace("ggplot2", quietly = TRUE)) {
    wipe_tmp()
    b64 <- tryCatch(
      {
        ggplot2::ggsave(
          filename = tmp_pdf,
          plot = plot_obj,
          width = w_in,
          height = h_in,
          units = "in",
          device = grDevices::cairo_pdf,
          limitsize = FALSE
        )
        read_b64_if_valid_pdf()
      },
      error = function(e) {
        wipe_tmp()
        if (dbg) {
          message("export_plot_pdf_base64 ggsave+cairo 失败：", conditionMessage(e))
        }
        NULL
      }
    )
    if (!is.null(b64) && nzchar(b64)) {
      return(b64)
    }
  }

  NULL
}

#' multipart 同名字段可能被 Plumber 聚合成多元素向量。
#' - 前导空串跳过：如 c(\"\", \"mmu\") 仍取 mmu。
#' - 多段非空时取 **最后一个**：常见为 c(路由默认值, 用户表单值)，取首个会导致重绘永远无法改参数。
form_field_one <- function(x, label = "field") {
  if (is.null(x)) {
    return("")
  }
  x <- trimws(as.character(x))
  if (length(x) == 0L) {
    return("")
  }
  nonempty <- x[nzchar(x)]
  if (length(nonempty) == 0L) {
    if (length(x) > 1L) {
      message("plumber /api/plot：", label, " 有 ", length(x), " 个值且均为空，已置空。")
    }
    return("")
  }
  chosen <- nonempty[[length(nonempty)]]
  if (length(nonempty) > 1L) {
    message(
      "plumber /api/plot：", label, " 有 ", length(nonempty), " 个非空值，已取最后一个：",
      encodeString(chosen, quote = "\""),
      "（多来自 Plumber 默认值 + multipart 合并，取末值才与用户修改一致）"
    )
  }
  chosen
}

#' Plumber 1.3+ 内置 req_body_args()，但未写入 NAMESPACE 导出，plumber::req_body_args 会报错。
safe_req_body_args <- function(req) {
  if (!requireNamespace("plumber", quietly = TRUE)) {
    return(list())
  }
  ns <- asNamespace("plumber")
  if (!exists("req_body_args", envir = ns, inherits = FALSE)) {
    return(list())
  }
  getFromNamespace("req_body_args", "plumber")(req)
}

#' multipart 单段转文本（跳过 file 二进制段由调用方处理）。
multipart_text_from_part <- function(part) {
  if (is.null(part)) {
    return(character(0))
  }
  if (is.character(part)) {
    return(trimws(as.character(part)))
  }
  if (!is.list(part)) {
    return(character(0))
  }
  v <- part$value
  if (is.null(v)) {
    return(character(0))
  }
  if (is.raw(v)) {
    if (length(v) == 0L) {
      return(character(0))
    }
    v <- tryCatch(
      rawToChar(v),
      error = function(e) ""
    )
    if (!nzchar(v)) {
      return(character(0))
    }
  }
  trimws(as.character(v))
}

#' 部分环境下 `req_body_args()` 拿不到 multipart 里的纯文本字段，绘图仍落回函数形参默认值。
#' 从 `req$body`（plumber_multipart）逐段读出文本，拼到 body_args **末尾**，与 form_field_one「取最后非空」一致。
merge_multipart_into_body_args <- function(req, body_args) {
  b <- req$body
  if (!inherits(b, "plumber_multipart")) {
    return(body_args)
  }
  nms <- names(b)
  if (is.null(nms)) {
    return(body_args)
  }
  out <- if (length(body_args)) body_args else list()
  for (i in seq_along(b)) {
    nm <- nms[[i]]
    if (identical(nm, NA_character_) || !nzchar(nm) || nm == "file") {
      next
    }
    tx <- multipart_text_from_part(b[[i]])
    if (!length(tx) || !any(nzchar(tx))) {
      next
    }
    if (nm %in% names(out) && !is.null(out[[nm]])) {
      old <- flatten_plot_arg_vector(out[[nm]])
      out[[nm]] <- c(old, tx)
    } else {
      out[[nm]] <- tx
    }
  }
  out
}

#' 将 multipart / 路由绑定上的单项展平为字符向量（不做「取最后一个」，留给 form_field_one）。
flatten_plot_arg_vector <- function(v) {
  if (is.null(v)) {
    return(character(0))
  }
  if (is.data.frame(v)) {
    return(character(0))
  }
  if (is.list(v) && length(v) == 1L && !inherits(v, "data.frame")) {
    v <- v[[1L]]
  }
  if (is.null(v)) {
    return(character(0))
  }
  trimws(as.character(v))
}

#' 合并「路由形参 param_val」与「req_body_args[[key]]」。
#' - 各侧分别 form_field_one，解决单通道内 c(默认值, 用户值) 须取末项的问题。
#' - 两侧都有且不一致时，以 body_args（multipart 表单）为准，与浏览器本次 POST 一致，确保重绘跟前端改参一致。
plot_form_scalar <- function(body_args, key, param_val, default_if_empty = NULL) {
  p <- flatten_plot_arg_vector(param_val)
  b <- if (length(body_args) && key %in% names(body_args)) {
    flatten_plot_arg_vector(body_args[[key]])
  } else {
    character(0)
  }
  sp <- if (length(p)) form_field_one(p, key) else ""
  sb <- if (length(b)) form_field_one(b, key) else ""
  out <- ""
  if (nzchar(sp) && nzchar(sb) && sp != sb) {
    out <- sb
  } else if (nzchar(sp)) {
    out <- sp
  } else if (nzchar(sb)) {
    out <- sb
  }
  if (!nzchar(out) && !is.null(default_if_empty)) {
    out <- as.character(default_if_empty)[[1L]]
  }
  out
}

#' 前端随 multipart 附带 `plot_params_json`（完整作图参数 JSON），解析后 **按 key 覆盖** 上游取值。
#' 与分散表单项内容一致，但作为最终权威，避免个别环境下 Plumber/req_body_args 与路由合并仍错位。
overlay_plot_params_json <- function(body_args, plot_params_json_route, scalars_list) {
  pj <- ""
  if (length(body_args) && "plot_params_json" %in% names(body_args)) {
    v <- body_args[["plot_params_json"]]
    if (!is.null(v) && !is.data.frame(v)) {
      if (is.list(v) && length(v) == 1L && !inherits(v, "data.frame")) {
        v <- v[[1L]]
      }
      ch <- trimws(as.character(v))
      if (length(ch)) {
        pj <- paste(ch, collapse = "")
      }
    }
  }
  if (!nzchar(pj)) {
    r <- trimws(as.character(plot_params_json_route))
    if (length(r) >= 1L && nzchar(r[[1L]])) {
      pj <- r[[1L]]
    }
  }
  if (!nzchar(pj)) {
    return(scalars_list)
  }
  lst <- tryCatch(
    jsonlite::fromJSON(pj, simplifyVector = TRUE),
    error = function(e) {
      message("plumber /api/plot：plot_params_json 解析失败：", conditionMessage(e))
      NULL
    }
  )
  if (!is.list(lst) || length(lst) == 0L) {
    return(scalars_list)
  }
  for (nm in names(lst)) {
    val <- lst[[nm]]
    if (is.null(val)) {
      next
    }
    if (length(val) != 1L) {
      next
    }
    ## 含空串：与前端「自动宽高 / 清空自定义断点」等一致，须覆盖而不能跳过。
    scalars_list[[nm]] <- trimws(as.character(val)[[1L]])
  }
  scalars_list
}

#' multipart 段上的原始文件名（Plumber 1.3 webutils 结构）
part_orig_name <- function(part) {
  if (is.null(part)) {
    return("")
  }
  fn <- part$filename
  if (is.character(fn) && length(fn) >= 1L && nzchar(fn[[1L]])) {
    return(as.character(fn[[1L]]))
  }
  ""
}

#' Plumber combine_keys(multi)：单文件且带 filename 时，形参常是 setNames(list(parsed), orig)，
#' 即「长度为 1 的命名 list」，而非 data.frame。此处取出唯一元素及原始文件名。
unwrap_plumber_file_arg <- function(file) {
  if (is.null(file) || !is.list(file) || length(file) != 1L) {
    return(list(el = NULL, orig = ""))
  }
  nm <- names(file)
  orig <- if (length(nm) >= 1L && nzchar(nm[[1L]])) nm[[1L]] else ""
  list(el = file[[1L]], orig = orig)
}

#' 已解析为 data.frame 后若写临时 CSV，`read_input_data` 须按 csv 扩展名选读取器。
materialize_csv_name <- function(orig) {
  o <- if (nzchar(orig)) orig else "uploaded"
  if (grepl("\\.[cC][sS][vV]$", o)) {
    return(o)
  }
  paste0(tools::file_path_sans_ext(o), ".csv")
}

# RDS 文件魔数（R 3.5+ 序列化格式）
is_rds_raw <- function(r) {
  is.raw(r) && length(r) >= 2L && r[[1L]] == as.raw(0x58L) && r[[2L]] == as.raw(0x0aL)
}

#' 无原始文件名/无扩展名时，按魔数推断扩展名（供临时文件后缀与 read_input_data 选择解析器）
infer_ext_from_raw <- function(r) {
  if (!is.raw(r) || length(r) < 2L) {
    return("")
  }
  if (is_rds_raw(r)) {
    return("rds")
  }
  if (length(r) < 8L) {
    return("")
  }
  if (r[[1L]] == as.raw(0x50L) && r[[2L]] == as.raw(0x4BL) &&
      r[[3L]] == as.raw(0x03L) && r[[4L]] == as.raw(0x04L)) {
    return("xlsx")
  }
  if (r[[1L]] == as.raw(0xd0L) && r[[2L]] == as.raw(0xcfL) &&
      r[[3L]] == as.raw(0x11L) && r[[4L]] == as.raw(0xe0L) &&
      r[[5L]] == as.raw(0xa1L) && r[[6L]] == as.raw(0xb1L) &&
      r[[7L]] == as.raw(0x1aL) && r[[8L]] == as.raw(0xe1L)) {
    return("xls")
  }
  ""
}

#' 统一得到上传文件的磁盘路径（Plumber 1.3+ 与旧版兼容）
#' - 1.3：形参 `file` 多为 **parsed**（csv→表、excel→list），无 datapath；**原始字节在 req$body$file$value**。
#' - 旧版：`file` 为带 datapath/tmp_filename 的上传对象。
#' 返回 list(path=, orig_name=, cleanup=) ；cleanup=TRUE 表示需在会话结束时 unlink(path)。
resolve_upload_for_plot <- function(req, file) {
  body <- req$body
  if (inherits(body, "plumber_multipart")) {
    part <- body[["file"]]
    if (!is.null(part)) {
      val <- part$value
      if (is.raw(val) && length(val) > 0L) {
        orig <- part_orig_name(part)
        ext <- tolower(tools::file_ext(orig))
        if (!nzchar(ext)) {
          inf <- infer_ext_from_raw(val)
          ext <- if (nzchar(inf)) {
            inf
          } else if (is_rds_raw(val)) {
            "rds"
          } else {
            "csv"
          }
          base <- if (nzchar(orig)) tools::file_path_sans_ext(orig) else "upload"
          orig <- paste0(base, ".", ext)
        }
        tmp <- tempfile(fileext = paste0(".", ext))
        writeBin(val, tmp)
        return(list(path = tmp, orig_name = orig, cleanup = TRUE))
      }
    }
  }

  if (!is.null(file)) {
    p <- upload_tmp_path(file)
    if (!is.null(p) && nzchar(p) && file.exists(p)) {
      return(list(path = p, orig_name = upload_orig_name(file), cleanup = FALSE))
    }

    if (is.raw(file) && length(file) > 0L) {
      inf <- infer_ext_from_raw(file)
      orig <- if (nzchar(inf)) {
        paste0("upload.", inf)
      } else if (is_rds_raw(file)) {
        "upload.rds"
      } else {
        "upload.csv"
      }
      ext <- tolower(tools::file_ext(orig))
      tmp <- tempfile(fileext = paste0(".", ext))
      writeBin(file, tmp)
      return(list(path = tmp, orig_name = orig, cleanup = TRUE))
    }

    fu <- unwrap_plumber_file_arg(file)
    el <- fu$el
    fo <- fu$orig
    if (!is.null(el)) {
      if (is.data.frame(el)) {
        tmp <- tempfile(fileext = ".csv")
        utils::write.csv(el, tmp, row.names = FALSE)
        return(list(
          path = tmp,
          orig_name = materialize_csv_name(fo),
          cleanup = TRUE
        ))
      }
      if (is.raw(el) && length(el) > 0L) {
        orig <- if (nzchar(fo)) {
          fo
        } else {
          inf0 <- infer_ext_from_raw(el)
          if (nzchar(inf0)) {
            paste0("upload.", inf0)
          } else if (is_rds_raw(el)) {
            "upload.rds"
          } else {
            "upload.csv"
          }
        }
        ext <- tolower(tools::file_ext(orig))
        if (!nzchar(ext)) {
          inf <- infer_ext_from_raw(el)
          ext <- if (nzchar(inf)) {
            inf
          } else if (is_rds_raw(el)) {
            "rds"
          } else {
            "csv"
          }
          orig <- paste0(tools::file_path_sans_ext(orig), ".", ext)
        }
        tmp <- tempfile(fileext = paste0(".", ext))
        writeBin(el, tmp)
        return(list(path = tmp, orig_name = orig, cleanup = TRUE))
      }
      if (is.list(el) && length(el) >= 1L && is.data.frame(el[[1L]])) {
        tmp <- tempfile(fileext = ".csv")
        utils::write.csv(el[[1L]], tmp, row.names = FALSE)
        return(list(
          path = tmp,
          orig_name = materialize_csv_name(if (nzchar(fo)) fo else "uploaded.xlsx"),
          cleanup = TRUE
        ))
      }
    }

    if (is.data.frame(file)) {
      tmp <- tempfile(fileext = ".csv")
      utils::write.csv(as.data.frame(file), tmp, row.names = FALSE)
      return(list(path = tmp, orig_name = "uploaded.csv", cleanup = TRUE))
    }
    if (is.list(file) && length(file) >= 1L && is.data.frame(file[[1L]])) {
      tmp <- tempfile(fileext = ".csv")
      utils::write.csv(file[[1L]], tmp, row.names = FALSE)
      nm0 <- names(file)
      hint <- if (length(nm0) >= 1L && nzchar(nm0[[1L]])) nm0[[1L]] else "uploaded"
      return(list(
        path = tmp,
        orig_name = materialize_csv_name(hint),
        cleanup = TRUE
      ))
    }
  }

  list(path = NULL, orig_name = "", cleanup = FALSE)
}

allowed_upload_ext <- c("csv", "tsv", "txt", "rds", "xlsx", "xls")

#* 生成气泡图
#* 成功：写 res$body 为 UTF-8 JSON（含 base64 图片 + 富集表 + 展示表），Content-Type: application/json。
#* 失败（上传/分析错误）：返回 JSON { ok, error }，供前端提示。
#* 前端须使用 multipart/form-data，文件字段名 `file`。
#* multipart 每个表单项会单独选解析器：纯文本字段常无 Content-Type，须启用 form（否则会刷屏 “No suitable parser… type .”）。
#* Plumber 1.3+：multipart 中表单参数 `file` 常是「解析后的」对象（csv→data.frame），无 datapath；
#* 原始字节在 req$body（class plumber_multipart）的 file$value 中，由 resolve_upload_for_plot() 写入临时文件。
#* 误用整段 text/csv 作为请求正文仍由下方 HTTP_CONTENT_TYPE 检测提示。
#* @post /api/plot
#* @parser multi
#* @parser form
#* @parser octet
#* @parser excel
#* @parser rds
function(
    req,
    res,
    file,
    genome = "mmu",
    enrichment_type = "KEGG",
    top_pathways = "20",
    arrange_standard = "pvalue",
    x_axis = "GeneRatio",
    arrange_way = "pvalue",
    show_grid = "0",
    grid_major_color = "#d3d3d3",
    grid_major_linewidth = "0.4",
    grid_minor_color = "#e0e0e0",
    grid_minor_linewidth = "0.35",
    color_low = "#487dad",
    color_high = "#bb9cc4",
    plot_title = "Enrichment bubble plot",
    x_axis_title = "Gene Ratio",
    y_axis_title = "Pathway",
    bubble_size_min = "2",
    bubble_size_max = "6",
    bubble_breaks_custom = "",
    title_size = "14",
    plot_title_bold = "0",
    axis_x_title_size = "12",
    axis_y_title_size = "12",
    axis_x_text_size = "9",
    axis_y_text_size = "8",
    axis_x_title_bold = "0",
    axis_y_title_bold = "0",
    axis_x_text_bold = "0",
    axis_y_text_bold = "0",
    legend_position = "right",
    plot_width_cm = "",
    plot_height_cm = "",
    dpi = "300",
    colorbar_barwidth_mm = "4.5",
    legend_color_title = "",
    legend_color_title_size = "11",
    legend_size_title = "",
    legend_size_title_size = "11",
    highlight_terms_enabled = "0",
    highlight_terms = "",
    y_wrap_width = "60",
    axis_y_text_lineheight = "1.12",
    plot_type = "bubble",
    bar_width = "0.45",
    bar_alpha = "0.8",
    bar_y_ticks = "0",
    bar_y_tick_length_cm = "0",
    bar_x_expand_left = "0",
    bar_x_expand_right = "0",
    bar_pathway_text_x = "0.001",
    bar_pathway_text_size = "4.3",
    bar_pathway_text_bold = "0",
    bar_gene_text_x = "0.001",
    bar_gene_text_vjust = "3",
    bar_gene_text_size = "3",
    bar_show_gene_id = "0",
    bar_gene_show_n = "10",
    bar_custom_gene_ids_json = "",
    plot_params_json = ""
) {
  raw_ct <- req$HTTP_CONTENT_TYPE
  ct <- if (is.null(raw_ct) || length(raw_ct) < 1L) {
    ""
  } else {
    as.character(raw_ct[[1]])
  }
  if (identical(ct, NA_character_) || !nzchar(ct)) {
    ct <- ""
  }

  if (grepl("text/csv", ct, ignore.case = TRUE) &&
      !grepl("multipart/form-data", ct, ignore.case = TRUE)) {
    return(list(
      ok = FALSE,
      error = "[上传] 请求使用了 Content-Type: text/csv（整段正文为 CSV）。本接口必须使用 multipart/form-data，并用表单字段名 file 上传文件；不要用原始 CSV 作为 HTTP 正文。"
    ))
  }

  body_args <- tryCatch(
    safe_req_body_args(req),
    error = function(e) {
      message("plumber /api/plot：解析表单参数失败：", conditionMessage(e))
      list()
    }
  )
  body_args <- merge_multipart_into_body_args(req, body_args)

  staged <- resolve_upload_for_plot(req, file)
  tmp_path <- staged$path
  orig_name <- form_field_one(staged$orig_name, "orig_name")

  ## 分散表单项 + 路由合并（plot_form_scalar）；再由 plot_params_json 整体覆盖，保证与前端当前表单一致。
  plot_scalars <- list(
    plot_type = plot_form_scalar(body_args, "plot_type", plot_type, "bubble"),
    genome = plot_form_scalar(body_args, "genome", genome, "mmu"),
    enrichment_type = plot_form_scalar(body_args, "enrichment_type", enrichment_type, "KEGG"),
    top_pathways = plot_form_scalar(body_args, "top_pathways", top_pathways, "20"),
    arrange_standard = plot_form_scalar(body_args, "arrange_standard", arrange_standard, "pvalue"),
    x_axis = plot_form_scalar(body_args, "x_axis", x_axis, "GeneRatio"),
    arrange_way = plot_form_scalar(body_args, "arrange_way", arrange_way, "pvalue"),
    show_grid = plot_form_scalar(body_args, "show_grid", show_grid, "0"),
    grid_major_color = plot_form_scalar(
      body_args,
      "grid_major_color",
      grid_major_color,
      "#d3d3d3"
    ),
    grid_major_linewidth = plot_form_scalar(
      body_args,
      "grid_major_linewidth",
      grid_major_linewidth,
      "0.4"
    ),
    grid_minor_color = plot_form_scalar(
      body_args,
      "grid_minor_color",
      grid_minor_color,
      "#e0e0e0"
    ),
    grid_minor_linewidth = plot_form_scalar(
      body_args,
      "grid_minor_linewidth",
      grid_minor_linewidth,
      "0.35"
    ),
    color_low = plot_form_scalar(body_args, "color_low", color_low, "#487dad"),
    color_high = plot_form_scalar(body_args, "color_high", color_high, "#bb9cc4"),
    plot_title = plot_form_scalar(
      body_args,
      "plot_title",
      plot_title,
      "Enrichment bubble plot"
    ),
    x_axis_title = plot_form_scalar(body_args, "x_axis_title", x_axis_title, "Gene Ratio"),
    y_axis_title = plot_form_scalar(body_args, "y_axis_title", y_axis_title, "Pathway"),
    bubble_size_min = plot_form_scalar(body_args, "bubble_size_min", bubble_size_min, "2"),
    bubble_size_max = plot_form_scalar(body_args, "bubble_size_max", bubble_size_max, "6"),
    bubble_breaks_custom = plot_form_scalar(
      body_args,
      "bubble_breaks_custom",
      bubble_breaks_custom,
      NULL
    ),
    title_size = plot_form_scalar(body_args, "title_size", title_size, "14"),
    plot_title_bold = plot_form_scalar(body_args, "plot_title_bold", plot_title_bold, "0"),
    axis_x_title_size = plot_form_scalar(body_args, "axis_x_title_size", axis_x_title_size, "12"),
    axis_y_title_size = plot_form_scalar(body_args, "axis_y_title_size", axis_y_title_size, "12"),
    axis_x_text_size = plot_form_scalar(body_args, "axis_x_text_size", axis_x_text_size, "9"),
    axis_y_text_size = plot_form_scalar(body_args, "axis_y_text_size", axis_y_text_size, "8"),
    axis_x_title_bold = plot_form_scalar(body_args, "axis_x_title_bold", axis_x_title_bold, "0"),
    axis_y_title_bold = plot_form_scalar(body_args, "axis_y_title_bold", axis_y_title_bold, "0"),
    axis_x_text_bold = plot_form_scalar(body_args, "axis_x_text_bold", axis_x_text_bold, "0"),
    axis_y_text_bold = plot_form_scalar(body_args, "axis_y_text_bold", axis_y_text_bold, "0"),
    legend_position = plot_form_scalar(body_args, "legend_position", legend_position, "right"),
    plot_width_cm = plot_form_scalar(body_args, "plot_width_cm", plot_width_cm, NULL),
    plot_height_cm = plot_form_scalar(body_args, "plot_height_cm", plot_height_cm, NULL),
    dpi = plot_form_scalar(body_args, "dpi", dpi, "300"),
    colorbar_barwidth_mm = plot_form_scalar(
      body_args,
      "colorbar_barwidth_mm",
      colorbar_barwidth_mm,
      "4.5"
    ),
    legend_color_title = plot_form_scalar(
      body_args,
      "legend_color_title",
      legend_color_title,
      NULL
    ),
    legend_color_title_size = plot_form_scalar(
      body_args,
      "legend_color_title_size",
      legend_color_title_size,
      "11"
    ),
    legend_size_title = plot_form_scalar(
      body_args,
      "legend_size_title",
      legend_size_title,
      NULL
    ),
    legend_size_title_size = plot_form_scalar(
      body_args,
      "legend_size_title_size",
      legend_size_title_size,
      "11"
    ),
    highlight_terms_enabled = plot_form_scalar(
      body_args,
      "highlight_terms_enabled",
      highlight_terms_enabled,
      "0"
    ),
    highlight_terms = plot_form_scalar(body_args, "highlight_terms", highlight_terms, NULL),
    y_wrap_width = plot_form_scalar(body_args, "y_wrap_width", y_wrap_width, "60"),
    axis_y_text_lineheight = plot_form_scalar(
      body_args,
      "axis_y_text_lineheight",
      axis_y_text_lineheight,
      "1.12"
    ),
    bar_width = plot_form_scalar(body_args, "bar_width", bar_width, "0.45"),
    bar_alpha = plot_form_scalar(body_args, "bar_alpha", bar_alpha, "0.8"),
    bar_y_ticks = plot_form_scalar(body_args, "bar_y_ticks", bar_y_ticks, "0"),
    bar_y_tick_length_cm = plot_form_scalar(body_args, "bar_y_tick_length_cm", bar_y_tick_length_cm, "0"),
    bar_x_expand_left = plot_form_scalar(body_args, "bar_x_expand_left", bar_x_expand_left, "0"),
    bar_x_expand_right = plot_form_scalar(body_args, "bar_x_expand_right", bar_x_expand_right, "0"),
    bar_pathway_text_x = plot_form_scalar(body_args, "bar_pathway_text_x", bar_pathway_text_x, "0.001"),
    bar_pathway_text_size = plot_form_scalar(body_args, "bar_pathway_text_size", bar_pathway_text_size, "4.3"),
    bar_pathway_text_bold = plot_form_scalar(body_args, "bar_pathway_text_bold", bar_pathway_text_bold, "0"),
    bar_gene_text_x = plot_form_scalar(body_args, "bar_gene_text_x", bar_gene_text_x, "0.001"),
    bar_gene_text_vjust = plot_form_scalar(body_args, "bar_gene_text_vjust", bar_gene_text_vjust, "3"),
    bar_gene_text_size = plot_form_scalar(body_args, "bar_gene_text_size", bar_gene_text_size, "3"),
    bar_show_gene_id = plot_form_scalar(body_args, "bar_show_gene_id", bar_show_gene_id, "0"),
    bar_gene_show_n = plot_form_scalar(body_args, "bar_gene_show_n", bar_gene_show_n, "10"),
    bar_custom_gene_ids_json = plot_form_scalar(
      body_args,
      "bar_custom_gene_ids_json",
      bar_custom_gene_ids_json,
      ""
    )
  )
  plot_scalars <- overlay_plot_params_json(body_args, plot_params_json, plot_scalars)
  plot_type <- tolower(trimws(plot_scalars$plot_type))
  if (!plot_type %in% c("bubble", "bar")) {
    plot_type <- "bubble"
  }
  genome <- plot_scalars$genome
  enrichment_type <- plot_scalars$enrichment_type
  top_pathways <- plot_scalars$top_pathways
  arrange_standard <- plot_scalars$arrange_standard
  x_axis <- plot_scalars$x_axis
  arrange_way <- plot_scalars$arrange_way
  show_grid <- plot_scalars$show_grid
  grid_major_color <- plot_scalars$grid_major_color
  grid_major_linewidth <- plot_scalars$grid_major_linewidth
  grid_minor_color <- plot_scalars$grid_minor_color
  grid_minor_linewidth <- plot_scalars$grid_minor_linewidth
  color_low <- plot_scalars$color_low
  color_high <- plot_scalars$color_high
  plot_title <- plot_scalars$plot_title
  x_axis_title <- plot_scalars$x_axis_title
  y_axis_title <- plot_scalars$y_axis_title
  bubble_size_min <- plot_scalars$bubble_size_min
  bubble_size_max <- plot_scalars$bubble_size_max
  bubble_breaks_custom <- plot_scalars$bubble_breaks_custom
  title_size <- plot_scalars$title_size
  plot_title_bold <- plot_scalars$plot_title_bold
  axis_x_title_size <- plot_scalars$axis_x_title_size
  axis_y_title_size <- plot_scalars$axis_y_title_size
  axis_x_text_size <- plot_scalars$axis_x_text_size
  axis_y_text_size <- plot_scalars$axis_y_text_size
  axis_x_title_bold <- plot_scalars$axis_x_title_bold
  axis_y_title_bold <- plot_scalars$axis_y_title_bold
  axis_x_text_bold <- plot_scalars$axis_x_text_bold
  axis_y_text_bold <- plot_scalars$axis_y_text_bold
  legend_position <- plot_scalars$legend_position
  plot_width_cm <- plot_scalars$plot_width_cm
  plot_height_cm <- plot_scalars$plot_height_cm
  dpi <- plot_scalars$dpi
  colorbar_barwidth_mm <- plot_scalars$colorbar_barwidth_mm
  legend_color_title <- plot_scalars$legend_color_title
  legend_color_title_size <- plot_scalars$legend_color_title_size
  legend_size_title <- plot_scalars$legend_size_title
  legend_size_title_size <- plot_scalars$legend_size_title_size
  highlight_terms_enabled <- plot_scalars$highlight_terms_enabled
  highlight_terms <- plot_scalars$highlight_terms
  y_wrap_width <- plot_scalars$y_wrap_width
  axis_y_text_lineheight <- plot_scalars$axis_y_text_lineheight
  bar_width <- plot_scalars$bar_width
  bar_alpha <- plot_scalars$bar_alpha
  bar_y_ticks <- plot_scalars$bar_y_ticks
  bar_y_tick_length_cm <- plot_scalars$bar_y_tick_length_cm
  bar_x_expand_left <- plot_scalars$bar_x_expand_left
  bar_x_expand_right <- plot_scalars$bar_x_expand_right
  bar_pathway_text_x <- plot_scalars$bar_pathway_text_x
  bar_pathway_text_size <- plot_scalars$bar_pathway_text_size
  bar_pathway_text_bold <- plot_scalars$bar_pathway_text_bold
  bar_gene_text_x <- plot_scalars$bar_gene_text_x
  bar_gene_text_vjust <- plot_scalars$bar_gene_text_vjust
  bar_gene_text_size <- plot_scalars$bar_gene_text_size
  bar_show_gene_id <- plot_scalars$bar_show_gene_id
  bar_gene_show_n <- plot_scalars$bar_gene_show_n
  bar_custom_gene_ids_json <- plot_scalars$bar_custom_gene_ids_json

  highlight_terms_vec <- character(0)
  flag <- tolower(trimws(as.character(highlight_terms_enabled)))
  from_body <- if (length(body_args) && "highlight_terms" %in% names(body_args)) {
    flatten_plot_arg_vector(body_args[["highlight_terms"]])
  } else {
    character(0)
  }
  from_scalar <- flatten_plot_arg_vector(highlight_terms)
  merged_raw <- c(from_body, from_scalar)
  merged_raw <- trimws(as.character(merged_raw))
  merged_raw <- merged_raw[nzchar(merged_raw)]
  if (length(merged_raw) && (length(flag) == 0L || !flag[[1L]] %in% c("0", "false", "off", "no"))) {
    parts <- unlist(strsplit(paste(merged_raw, collapse = "\n"), "\\r?\\n|[;,|]", perl = TRUE), use.names = FALSE)
    parts <- trimws(parts)
    highlight_terms_vec <- unique(parts[nzchar(parts)])
  }

  # 临时调试：ENRICH_PLOT_DEBUG=1 时打印（Windows: $env:ENRICH_PLOT_DEBUG='1'; Linux: export ENRICH_PLOT_DEBUG=1）。验证完删除本段或关环境变量。
  if (identical(Sys.getenv("ENRICH_PLOT_DEBUG", ""), "1")) {
    tp_try <- upload_tmp_path(file)
    sn <- tryCatch(
      paste(utils::capture.output(str(file, max.level = 2L, give.attr = FALSE)), collapse = "\n"),
      error = function(e) sprintf("<str() failed: %s>", conditionMessage(e))
    )
    message(paste0(
      "=== ENRICH_PLOT_DEBUG /api/plot ===\n",
      "HTTP_CONTENT_TYPE: ", ct, "\n",
      "class(file): ", paste(class(file), collapse = ", "), "\n",
      "names(file): ", paste(names(file), collapse = ", "), "\n",
      "upload_tmp_path(file): ", if (is.null(tp_try)) "<NULL>" else tp_try, "\n",
      "upload_orig_name(file): ", encodeString(upload_orig_name(file), quote = '"'), "\n",
      "staged$path: ", if (is.null(tmp_path)) "<NULL>" else tmp_path, "\n",
      "staged$orig_name: ", encodeString(orig_name, quote = '"'), "\n",
      "file.exists(staged$path): ", if (is.null(tmp_path) || !nzchar(tmp_path)) {
        "NA"
      } else {
        file.exists(tmp_path)
      }, "\n",
      "genome=", genome, " enrichment_type=", enrichment_type, " top_pathways=", top_pathways, "\n",
      "plot_title=", encodeString(plot_title, quote = '"'),
      " x_axis_title=", encodeString(x_axis_title, quote = '"'),
      " y_axis_title=", encodeString(y_axis_title, quote = '"'), "\n",
      "str(file):\n", sn, "\n",
      "=== end ENRICH_PLOT_DEBUG ==="
    ))
  }

  cleanup_upload <- isTRUE(staged$cleanup)
  if (cleanup_upload && !is.null(tmp_path) && nzchar(tmp_path)) {
    on.exit(unlink(tmp_path), add = TRUE)
  }

  if (is.null(tmp_path) || !nzchar(tmp_path) || !file.exists(tmp_path)) {
    message("plumber /api/plot：未解析到上传文件（字段 file + multipart；若已更新 plumber.R 请重启 R）。")
    return(list(
      ok = FALSE,
      error = "[上传] 未收到上传文件。请确认已选择文件，表单字段名为 file；修改 plumber.R 后请重启 Rscript run_api.R。"
    ))
  }
  ext <- tolower(tools::file_ext(orig_name))
  if (!nzchar(ext)) {
    return(list(
      ok = FALSE,
      error = "[上传] 无法识别文件类型（缺少扩展名）。请上传带 .csv / .tsv / .txt / .rds / .xlsx / .xls 后缀的文件，并确保使用 multipart 表单字段名 file"
    ))
  }
  if (!ext %in% allowed_upload_ext) {
    return(list(
      ok = FALSE,
      error = sprintf("[上传] 不支持的文件类型：%s【仅允许 csv、tsv、txt、rds、xlsx、xls】", ext)
    ))
  }

  tmp_plot_raster <- tempfile(fileext = ".png")
  on.exit(unlink(tmp_plot_raster), add = TRUE)

  df_to_csv_utf8 <- function(df) {
    tf <- tempfile(fileext = ".csv")
    on.exit(unlink(tf), add = TRUE)
    utils::write.csv(df, tf, row.names = FALSE, na = "", fileEncoding = "UTF-8")
    paste(readLines(tf, warn = FALSE, encoding = "UTF-8"), collapse = "\n")
  }

  plot_payload <- tryCatch(
    {
      out <- if (identical(plot_type, "bar")) {
        enrichment_bar_from_file(
          file_path = tmp_path,
          original_filename = if (nzchar(orig_name)) orig_name else NULL,
          genome = genome,
          enrichment_type = enrichment_type,
          top_pathways = as.integer(top_pathways),
          arrange_standard = arrange_standard,
          x_axis = x_axis,
          arrange_way = arrange_way,
          color_low = color_low,
          color_high = color_high,
          plot_title = plot_title,
          x_axis_title = x_axis_title,
          y_axis_title = y_axis_title,
          title_size = as.numeric(title_size),
          plot_title_bold = plot_title_bold,
          axis_x_title_size = as.numeric(axis_x_title_size),
          axis_y_title_size = as.numeric(axis_y_title_size),
          axis_x_title_bold = axis_x_title_bold,
          axis_y_title_bold = axis_y_title_bold,
          axis_x_text_size = as.numeric(axis_x_text_size),
          legend_color_title = if (nzchar(trimws(as.character(legend_color_title)))) {
            legend_color_title
          } else {
            NULL
          },
          legend_color_title_size = suppressWarnings(as.numeric(legend_color_title_size)),
          legend_position = legend_position,
          colorbar_barwidth_mm = suppressWarnings(as.numeric(colorbar_barwidth_mm)),
          bar_width = suppressWarnings(as.numeric(bar_width)),
          bar_alpha = suppressWarnings(as.numeric(bar_alpha)),
          bar_y_ticks = bar_y_ticks,
          bar_y_tick_length_cm = suppressWarnings(as.numeric(bar_y_tick_length_cm)),
          bar_x_expand_left = suppressWarnings(as.numeric(bar_x_expand_left)),
          bar_x_expand_right = suppressWarnings(as.numeric(bar_x_expand_right)),
          bar_pathway_text_x = suppressWarnings(as.numeric(bar_pathway_text_x)),
          bar_pathway_text_size = suppressWarnings(as.numeric(bar_pathway_text_size)),
          bar_pathway_text_bold = bar_pathway_text_bold,
          bar_gene_text_x = suppressWarnings(as.numeric(bar_gene_text_x)),
          bar_gene_text_vjust = suppressWarnings(as.numeric(bar_gene_text_vjust)),
          bar_gene_text_size = suppressWarnings(as.numeric(bar_gene_text_size)),
          bar_show_gene_id = bar_show_gene_id,
          bar_gene_show_n = suppressWarnings(as.numeric(bar_gene_show_n)),
          bar_custom_gene_ids_json = bar_custom_gene_ids_json
        )
      } else {
        enrichment_bubble_from_file(
          file_path = tmp_path,
          original_filename = if (nzchar(orig_name)) orig_name else NULL,
          genome = genome,
          enrichment_type = enrichment_type,
          top_pathways = as.integer(top_pathways),
          arrange_standard = arrange_standard,
          x_axis = x_axis,
          arrange_way = arrange_way,
          show_grid = tolower(trimws(as.character(show_grid))) %in% c("1", "true", "yes", "on"),
          grid_major_color = grid_major_color,
          grid_major_linewidth = grid_major_linewidth,
          grid_minor_color = grid_minor_color,
          grid_minor_linewidth = grid_minor_linewidth,
          color_low = color_low,
          color_high = color_high,
          plot_title = plot_title,
          x_axis_title = x_axis_title,
          y_axis_title = y_axis_title,
          bubble_size_min = as.numeric(bubble_size_min),
          bubble_size_max = as.numeric(bubble_size_max),
          bubble_breaks_custom = if (nzchar(bubble_breaks_custom)) bubble_breaks_custom else NULL,
          title_size = as.numeric(title_size),
          plot_title_bold = plot_title_bold,
          axis_x_title_size = as.numeric(axis_x_title_size),
          axis_y_title_size = as.numeric(axis_y_title_size),
          axis_x_text_size = as.numeric(axis_x_text_size),
          axis_y_text_size = as.numeric(axis_y_text_size),
          axis_x_title_bold = axis_x_title_bold,
          axis_y_title_bold = axis_y_title_bold,
          axis_x_text_bold = axis_x_text_bold,
          axis_y_text_bold = axis_y_text_bold,
          legend_position = legend_position,
          colorbar_barwidth_mm = suppressWarnings(as.numeric(colorbar_barwidth_mm)),
          legend_color_title = if (nzchar(trimws(as.character(legend_color_title)))) {
            legend_color_title
          } else {
            NULL
          },
          legend_color_title_size = suppressWarnings(as.numeric(legend_color_title_size)),
          legend_size_title = if (nzchar(trimws(as.character(legend_size_title)))) {
            legend_size_title
          } else {
            NULL
          },
          legend_size_title_size = suppressWarnings(as.numeric(legend_size_title_size)),
          highlight_terms = if (length(highlight_terms_vec)) highlight_terms_vec else NULL,
          y_wrap_width = y_wrap_width,
          axis_y_text_lineheight = axis_y_text_lineheight
        )
      }

      w_cm <- if (nzchar(plot_width_cm)) as.numeric(plot_width_cm) else out$width_cm
      h_cm <- if (nzchar(plot_height_cm)) as.numeric(plot_height_cm) else out$height_cm
      dp <- as.numeric(dpi)
      w_in <- as.numeric(w_cm) / 2.54
      h_in <- as.numeric(h_cm) / 2.54

      # Windows 无图形界面时 png() 偶发写出 0 字节文件，导致 base64 为空向量、JSON 里 image 变成 []。
      px_w <- max(50L, round(as.numeric(w_cm) * dp / 2.54))
      px_h <- max(50L, round(as.numeric(h_cm) * dp / 2.54))
      grDevices::png(
        filename = tmp_plot_raster,
        width = px_w,
        height = px_h,
        res = dp,
        bg = "white"
      )
      tryCatch(
        print(out$plot),
        finally = {
          if (grDevices::dev.cur() != 1L) {
            grDevices::dev.off()
          }
        }
      )

      fi <- file.info(tmp_plot_raster)
      sz <- fi$size[[1L]]
      if (length(sz) != 1L || is.na(sz) || sz < 67L) {
        stop(
          paste0(
            "PNG 未正确生成（文件过小或为空）。若在 Windows 上运行，请确认已安装 R 自带 bitmap 设备；",
            "也可尝试安装并加载 ragg 后改用 Cairo/ragg 后端。"
          )
        )
      }
      raw <- readBin(tmp_plot_raster, "raw", n = sz)
      if (length(raw) == 0L) {
        stop("读取 PNG 失败（长度为 0）")
      }

      ## 与 PNG 同一次分析：再导出矢量 PDF，供前端「下载 PDF」直接落盘（无需第二次请求）
      tmp_pdf <- tempfile(fileext = ".pdf")
      pdf_b64 <- export_plot_pdf_base64(out$plot, w_in, h_in, tmp_pdf)
      display_df <- out$plot_table
      for (nm in names(display_df)) {
        if (inherits(display_df[[nm]], "factor")) {
          display_df[[nm]] <- as.character(display_df[[nm]])
        }
      }
      raw_csv <- df_to_csv_utf8(out$enrich_table)
      display_csv <- df_to_csv_utf8(display_df)
      raw_df <- as.data.frame(out$enrich_table, stringsAsFactors = FALSE)
      for (nm in names(raw_df)) {
        col <- raw_df[[nm]]
        if (inherits(col, "factor")) {
          raw_df[[nm]] <- as.character(col)
        } else if (is.list(col) && !inherits(col, "data.frame")) {
          raw_df[[nm]] <- vapply(
            seq_len(nrow(raw_df)),
            function(i) {
              paste(as.character(unlist(col[[i]])), collapse = "/")
            },
            character(1L)
          )
        }
      }
      ## 供前端按通路名称匹配「完整富集行」；避免仅依赖 CSV 解析
      out_payload <- list(
        ok = TRUE,
        mime = "image/png",
        image = jsonlite::base64_enc(raw),
        raw_enrichment_csv = raw_csv,
        raw_enrichment = raw_df,
        display_results_csv = display_csv,
        display_results = display_df,
        meta = list(
          raw_n = nrow(out$enrich_table),
          display_n = nrow(display_df),
          input_genes = out$input_gene_n,
          plot_type = plot_type,
          genome = genome,
          enrichment_type = enrichment_type,
          arrange_standard = arrange_standard,
          arrange_way = arrange_way,
          x_axis = x_axis,
          top_pathways = as.integer(top_pathways),
          width_cm = as.numeric(w_cm),
          height_cm = as.numeric(h_cm),
          has_pdf = !is.null(pdf_b64) && nzchar(pdf_b64),
          y_wrap_width = out$y_wrap_width,
          axis_y_text_lineheight = out$axis_y_text_lineheight
        )
      )
      if (!is.null(pdf_b64) && nzchar(pdf_b64)) {
        out_payload$pdf_base64 <- pdf_b64
      }
      out_payload
    },
    error = function(e) {
      list(ok = FALSE, error = paste0("[分析] ", e$message))
    }
  )

  ## 显式写 JSON 响应体，避免 Plumber/jsonlite 将成功体误序列成原始 PNG 字节流（前端无法拿到 display_results）。
  if (isTRUE(plot_payload$ok)) {
    res$setHeader("Content-Type", "application/json; charset=UTF-8")
    json_chr <- as.character(
      jsonlite::toJSON(plot_payload, auto_unbox = TRUE, na = "null")
    )
    res$body <- charToRaw(enc2utf8(json_chr))
    return(res)
  }
  plot_payload
}
