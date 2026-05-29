# 富集分析气泡图 — 供 Plumber 调用的核心逻辑
# 依赖：clusterProfiler, org.Mm.eg.db, org.Hs.eg.db, ggplot2, dplyr, readxl
# （readr 由 Plumber 解析上传 CSV 时使用；列类型提示在 plumber.R 里已关闭）

suppressPackageStartupMessages({
  library(clusterProfiler)
  library(dplyr)
  library(ggplot2)
  library(stringr)
  library(readxl)
  library(org.Mm.eg.db)
  library(org.Hs.eg.db)
})

#' Excel 另存 CSV 常为 UTF-8 BOM；优先尝试带 BOM 的读入
read_csv_safe <- function(path) {
  tryCatch(
    utils::read.csv(path, stringsAsFactors = FALSE, check.names = FALSE, fileEncoding = "UTF-8-BOM"),
    error = function(e) {
      utils::read.csv(path, stringsAsFactors = FALSE, check.names = FALSE)
    }
  )
}

read_delim_safe <- function(path) {
  tryCatch(
    utils::read.delim(path, stringsAsFactors = FALSE, check.names = FALSE, fileEncoding = "UTF-8-BOM"),
    error = function(e) {
      utils::read.delim(path, stringsAsFactors = FALSE, check.names = FALSE)
    }
  )
}

#' .txt：首行含制表符则按 TSV，否则按 CSV
read_txt_flex <- function(path) {
  l1 <- readLines(path, n = 1L, warn = FALSE, encoding = "UTF-8")
  if (!length(l1)) {
    stop("txt 文件为空或无法读取首行")
  }
  l1[[1]] <- sub("^\uFEFF", "", l1[[1]])
  if (grepl("\t", l1[[1]], fixed = TRUE)) {
    read_delim_safe(path)
  } else {
    read_csv_safe(path)
  }
}

strip_colnames_bom <- function(df) {
  cn <- colnames(df)
  cn <- sub("^\uFEFF", "", cn)
  colnames(df) <- cn
  df
}

#' 按路径读取上传临时文件；扩展名优先取原始文件名（Plumber 临时路径常无后缀）
#' @param file_path 服务器上的临时文件路径
#' @param original_filename 浏览器上传时的原始文件名（含扩展名），可为 NULL
read_input_data <- function(file_path, original_filename = NULL) {
  if (is.null(file_path) || !nzchar(file_path) || !file.exists(file_path)) {
    stop("文件路径无效或文件不存在")
  }
  name_for_ext <- if (!is.null(original_filename) && nzchar(original_filename)) {
    original_filename
  } else {
    basename(file_path)
  }
  ext <- tolower(tools::file_ext(name_for_ext))
  if (!nzchar(ext)) {
    stop("无法根据文件名识别扩展名，请上传带后缀的文件（.csv / .tsv / .txt / .rds / .xlsx / .xls）")
  }
  df <- switch(
    ext,
    "csv" = read_csv_safe(file_path),
    "tsv" = read_delim_safe(file_path),
    "txt" = read_txt_flex(file_path),
    "rds" = readRDS(file_path),
    "xlsx" = as.data.frame(readxl::read_excel(file_path, sheet = 1L)),
    "xls" = as.data.frame(readxl::read_excel(file_path, sheet = 1L)),
    stop("不支持的文件格式：", ext, "。请使用 csv / tsv / txt / rds / xlsx / xls")
  )
  if (!is.data.frame(df)) {
    stop("读取结果不是 data.frame（例如 RDS 中保存了非表格对象）")
  }
  if (nrow(df) == 0L || ncol(df) == 0L) {
    stop("文件内容为空（0 行或 0 列）")
  }
  strip_colnames_bom(df)
}

#' 校验并统一 Gene 列名
normalize_deg_df <- function(df) {
  df <- strip_colnames_bom(df)
  cn <- colnames(df)
  cl <- tolower(cn)
  if (!"gene" %in% cl) {
    stop("未找到 Gene 列。需要列名 Gene（不区分大小写），或与 log2foldchange 两列格式")
  }
  ig <- which(cl == "gene")[[1]]
  df$Gene <- as.character(df[[cn[ig]]])
  df$Gene <- trimws(df$Gene)
  df <- df[!is.na(df$Gene) & nzchar(df$Gene), , drop = FALSE]
  n_cols <- ncol(df)
  valid <- (n_cols == 1 && sum(cl == "gene") == 1) ||
    (n_cols == 2 && all(c("gene", "log2foldchange") %in% cl))
  if (!valid) {
    stop("格式要求：1 列 Gene；或 2 列 Gene + log2foldchange（列名不区分大小写）")
  }
  df
}

get_org_db <- function(genome) {
  g <- trimws(tolower(as.character(genome)))
  if (length(g) != 1L) {
    g <- g[[1L]]
  }
  if (!nzchar(g)) {
    stop("genome 为空。请在请求中传入 genome=mmu 或 genome=hsa（与前端「参考物种」一致）。")
  }
  switch(
    g,
    "mmu" = org.Mm.eg.db,
    "hsa" = org.Hs.eg.db,
    stop(sprintf("genome 仅支持 mmu（小鼠）或 hsa（人类），当前收到：%s", encodeString(g, quote = '"')))
  )
}

#' SYMBOL -> ENTREZID，未匹配比例 > max_unmapped 则报错（默认 20%）
map_genes <- function(genes, genome, max_unmapped = 0.20) {
  org_db <- get_org_db(genome)
  gene_entrez <- tryCatch(
    bitr(
      unique(genes),
      fromType = "SYMBOL",
      toType = "ENTREZID",
      OrgDb = org_db
    ),
    error = function(e) stop("ID 转换失败：", e$message)
  )
  total <- length(unique(genes))
  mapped <- nrow(unique(gene_entrez[, c("SYMBOL", "ENTREZID")]))
  unmapped_rate <- (total - mapped) / total
  if (unmapped_rate > max_unmapped) {
    stop(sprintf(
      "未匹配基因比例 %.1f%% 超过 %.0f%%，请检查基因符号或物种是否选择正确",
      100 * unmapped_rate, 100 * max_unmapped
    ))
  }
  gene_entrez
}

run_enrichment <- function(entrez_ids, enrichment_type, genome) {
  et <- toupper(trimws(enrichment_type))
  org_db <- get_org_db(genome)
  g <- trimws(tolower(as.character(genome)))
  if (length(g) != 1L) {
    g <- g[[1L]]
  }

  if (et == "KEGG") {
    options(timeout = max(getOption("timeout"), 99999))
    res <- enrichKEGG(
      gene = entrez_ids,
      organism = g,
      pAdjustMethod = "BH",
      keyType = "kegg",
      pvalueCutoff = 0.5,
      qvalueCutoff = 0.5
    )
  } else {
    ont <- if (et == "GO") "ALL" else et
    if (!ont %in% c("ALL", "BP", "CC", "MF")) {
      stop("enrichment_type 应为 KEGG、GO、BP、CC 或 MF")
    }
    options(timeout = max(getOption("timeout"), 99999))
    res <- enrichGO(
      gene = entrez_ids,
      OrgDb = org_db,
      keyType = "ENTREZID",
      ont = ont,
      pAdjustMethod = "BH",
      pvalueCutoff = 0.05,
      qvalueCutoff = 0.05
    )
  }
  if (is.null(res) || nrow(as.data.frame(res)) == 0) {
    stop("富集结果为空，请尝试放宽阈值或检查基因列表")
  }
  as.data.frame(res)
}

mixed_to_float <- function(x) {
  x <- vapply(x, as.character, "")
  is_int <- grepl("^-?\\d+$", x)
  is_frac <- grepl("^-?\\d+\\/\\d+$", x)
  is_float <- grepl("^-?\\d+\\.\\d+$", x)
  is_mixed <- grepl("^-?\\d+ \\d+\\/\\d+$", x)
  if (!all(is_int | is_frac | is_float | is_mixed)) {
    return(suppressWarnings(as.numeric(x)))
  }
  nums <- strsplit(x, "[ /]")
  out <- ifelse(
    is_int,
    as.numeric(vapply(nums, `[`, 1, FUN.VALUE = "")),
    ifelse(
      is_float,
      as.numeric(vapply(nums, `[`, 1, FUN.VALUE = "")),
      ifelse(
        is_frac,
        as.numeric(vapply(nums, `[`, 1, FUN.VALUE = "")) /
          as.numeric(vapply(nums, `[`, 2, FUN.VALUE = "")),
        as.numeric(vapply(nums, `[`, 1, FUN.VALUE = "")) +
          as.numeric(vapply(nums, `[`, 2, FUN.VALUE = "")) /
            as.numeric(vapply(nums, `[`, 3, FUN.VALUE = ""))
      )
    )
  )
  as.numeric(out)
}

prepare_core <- function(enrich_df) {
  n <- nrow(enrich_df)

  category_vals <- if ("category" %in% names(enrich_df)) {
    enrich_df$category
  } else if ("Category" %in% names(enrich_df)) {
    enrich_df$Category
  } else if ("ONTOLOGY" %in% names(enrich_df)) {
    ## GO enrichGO 默认列为 ONTOLOGY（BP/CC/MF）
    enrich_df$ONTOLOGY
  } else {
    rep(NA_character_, n)
  }
  category_vals <- as.character(category_vals)

  subcategory_vals <- if ("subcategory" %in% names(enrich_df)) {
    enrich_df$subcategory
  } else if ("Subcategory" %in% names(enrich_df)) {
    enrich_df$Subcategory
  } else {
    rep(NA_character_, n)
  }
  subcategory_vals <- as.character(subcategory_vals)

  gene_id_vals <- if ("geneID" %in% names(enrich_df)) {
    as.character(enrich_df$geneID)
  } else {
    rep(NA_character_, n)
  }

  core <- data.frame(
    Description = enrich_df$Description,
    Count = enrich_df$Count,
    qvalue = enrich_df$qvalue,
    GeneRatio = enrich_df$GeneRatio,
    RichFactor = enrich_df$RichFactor,
    pvalue = enrich_df$pvalue,
    category = category_vals,
    subcategory = subcategory_vals,
    geneID = gene_id_vals,
    stringsAsFactors = FALSE
  )
  core$GeneRatio <- mixed_to_float(core$GeneRatio)
  core$Count <- mixed_to_float(core$Count)
  core$RichFactor <- mixed_to_float(core$RichFactor)
  core
}

add_neg_log <- function(core, arrange_standard, top_n) {
  if (arrange_standard == "pvalue") {
    core <- core %>% dplyr::arrange(pvalue)
    core <- head(core, top_n)
    core$negLog10_pvalue <- -log10(pmax(core$pvalue, .Machine$double.xmin))
    core
  } else {
    core <- core %>% dplyr::arrange(qvalue)
    core <- head(core, top_n)
    core$negLog10_qvalue <- -log10(pmax(core$qvalue, .Machine$double.xmin))
    core
  }
}

run_result_processing <- function(data, arrange_standard, x_axis, arrange_way) {
  sig_col <- if (arrange_standard == "pvalue") "pvalue" else "qvalue"

  x_col <- switch(
    x_axis,
    "GeneRatio" = "GeneRatio",
    "RichFactor" = "RichFactor",
    "-log10(pvalue)" = "negLog10_pvalue",
    "negLog10_pvalue" = "negLog10_pvalue",
    "-log10(qvalue)" = "negLog10_qvalue",
    "-logFDR" = "negLog10_qvalue",
    "negLog10_qvalue" = "negLog10_qvalue",
    stop("不支持的 X 轴：", x_axis)
  )

  if (!x_col %in% names(data)) {
    stop("当前数据缺少列：", x_col)
  }

  if (arrange_way %in% c("pvalue", "qvalue")) {
    primary <- sig_col
    secondary <- x_col
  } else if (arrange_way %in% c("GeneRatio", "RichFactor")) {
    primary <- x_col
    secondary <- sig_col
  } else {
    stop("不支持的排序方式：", arrange_way)
  }

  primary_decreasing <- primary %in% c(
    "GeneRatio", "RichFactor", "negLog10_pvalue", "negLog10_qvalue"
  )
  secondary_decreasing <- secondary %in% c(
    "GeneRatio", "RichFactor", "negLog10_pvalue", "negLog10_qvalue"
  )

  ord <- order(
    data[[primary]], data[[secondary]],
    decreasing = c(primary_decreasing, secondary_decreasing)
  )
  data <- data[ord, , drop = FALSE]
  t_order <- unique(data$Description)
  data$Description <- factor(data$Description, levels = rev(t_order), ordered = TRUE)
  data
}

#' 将候选刻度整理为恰好 4 个递增有限值，并尽量落在 [count_min, count_max] 附近
finalize_four_breaks <- function(br, count_min, count_max) {
  br <- as.numeric(br)
  br <- br[is.finite(br)]
  if (length(br) == 0L) {
    return(as.numeric(seq(count_min, count_max, length.out = 4L)))
  }
  br <- sort(unique(round(br, 8)))
  if (length(br) >= 4L) {
    idx <- unique(as.integer(round(seq(1L, length(br), length.out = 4L))))
    idx <- pmax(1L, pmin(length(br), idx))
    return(br[idx])
  }
  pad <- as.numeric(seq(count_min, count_max, length.out = 4L))
  br <- sort(unique(round(c(br, pad), 8)))
  if (length(br) < 4L) {
    br <- as.numeric(seq(min(br, count_min), max(br, count_max), length.out = 4L))
  } else if (length(br) > 4L) {
    idx <- unique(as.integer(round(seq(1L, length(br), length.out = 4L))))
    idx <- pmax(1L, pmin(length(br), idx))
    br <- br[idx]
  }
  br[seq_len(4L)]
}

#' 生成 4 个气泡刻度（Count 图例），使刻度随输入 Count 范围变化。
#'
#' 规则：十位数边界 + 按 round 后跨度取间隔；同一十段（range_round == -10）用实际 min 起点、间隔 2。
#' 若规则与数据不匹配（极端 Count、舍入边界），请在前端填写「气泡刻度」自定义字符串，
#' 由 bubble_breaks_custom 解析后传入（至少 2 个有效数字）。
#'
#' 后续可在此函数上继续迭代「自适应气泡」策略。
bubble_breaks <- function(count_min, count_max) {
  if (!is.finite(count_min) || !is.finite(count_max)) {
    return(c(1, 2, 3, 4))
  }
  if (count_max < count_min) {
    b <- count_min
    return(c(b, b + 1, b + 2, b + 3))
  }
  if (abs(count_max - count_min) < .Machine$double.eps^0.5) {
    b <- count_min
    return(c(b, b + 1, b + 2, b + 3))
  }

  round_min <- ceiling(count_min / 10) * 10
  round_max <- floor(count_max / 10) * 10
  range_round <- as.integer(round_max - round_min)

  ## 与 -10 整数比较（避免 double / int 导致 identical 失败）
  if (range_round == -10) {
    start <- count_min
    bubble_interval <- 2
    br <- seq(from = start, by = bubble_interval, length.out = 4L)
  } else {
    start <- round_min
    bubble_interval <- suppressWarnings(
      as.numeric(
        dplyr::case_when(
          range_round %in% c(0L, 10L) ~ 5,
          range_round %in% c(20L, 30L) ~ 10,
          range_round == 40L ~ 15,
          range_round %in% c(50L, 60L) ~ 20,
          range_round == 70L ~ 25,
          range_round %in% c(80L, 90L) ~ 30,
          range_round > 90L ~ 30,
          TRUE ~ max(1, round((count_max - count_min) / 3))
        )
      )
    )
    if (!is.finite(bubble_interval) || bubble_interval <= 0) {
      bubble_interval <- max(1, round((count_max - count_min) / 3))
    }
    br <- seq(from = start, by = bubble_interval, length.out = 4L)
  }

  finalize_four_breaks(br, count_min, count_max)
}

#' 解析「气泡刻度」自定义串：英文 , ; 空白及 |；并兼容中文全角逗号、顿号、全角分号（输入法常见）
parse_bubble_breaks_custom <- function(txt) {
  if (is.null(txt)) {
    return(numeric(0))
  }
  ch <- trimws(as.character(txt)[[1L]])
  if (!nzchar(ch)) {
    return(numeric(0))
  }
  ch <- gsub("\uFF0C", ",", ch, fixed = TRUE)
  ch <- gsub("\u3001", ",", ch, fixed = TRUE)
  ch <- gsub("\uFF1B", ";", ch, fixed = TRUE)
  parts <- unlist(strsplit(ch, "[,;\\s|]+", perl = TRUE), use.names = FALSE)
  parts <- trimws(parts)
  parts <- parts[nzchar(parts)]
  v <- suppressWarnings(as.numeric(parts))
  v[is.finite(v)]
}

#' 前端 / 表单用 "1"/"0" 或 logical；ggplot element_text 的 face 用 bold / plain
axis_face_from_flag <- function(x, default_bold = TRUE) {
  if (is.null(x)) {
    return(if (default_bold) "bold" else "plain")
  }
  if (is.logical(x) && length(x) >= 1L) {
    return(if (isTRUE(x[[1L]])) "bold" else "plain")
  }
  ch <- tolower(trimws(as.character(x[[1L]])))
  if (!nzchar(ch)) {
    return(if (default_bold) "bold" else "plain")
  }
  if (ch %in% c("1", "true", "yes", "on")) {
    return("bold")
  }
  "plain"
}

#' stringr::str_wrap 的 width；与前端「换行宽度」一致，限制在合理整数区间
normalize_y_wrap_width <- function(x, default = 60L) {
  if (is.null(x)) {
    return(default)
  }
  ch <- trimws(as.character(x))
  if (!length(ch) || !nzchar(ch[[1L]])) {
    return(default)
  }
  w <- suppressWarnings(as.integer(round(as.numeric(ch[[1L]]))))
  if (length(w) < 1L || is.na(w[[1L]])) {
    return(default)
  }
  max(10L, min(200L, w[[1L]]))
}

#' 多行标签行距系数（ggplot element_text lineheight）
normalize_axis_y_lineheight <- function(x, default = 1.12) {
  if (is.null(x)) {
    return(default)
  }
  ch <- trimws(as.character(x))
  if (!length(ch) || !nzchar(ch[[1L]])) {
    return(default)
  }
  v <- suppressWarnings(as.numeric(ch[[1L]]))
  if (length(v) < 1L || !is.finite(v[[1L]])) {
    return(default)
  }
  max(0.75, min(2.2, v[[1L]]))
}

#' 图例标题字号（ggplot element_text size，单位 pt）
normalize_legend_title_size <- function(x, default = 11) {
  v <- suppressWarnings(as.numeric(x))
  if (length(v) < 1L || !is.finite(v[[1L]])) {
    return(default)
  }
  max(6, min(28, v[[1L]]))
}

#' 颜色图例标题：留空用默认公式；与默认公式同义的文本也解析为 expression；其余按用户字符串展示。
resolve_legend_color_title <- function(
    legend_color_title,
    arrange_standard = "pvalue",
    style = c("bubble", "bar")
) {
  style <- match.arg(style)
  raw <- if (is.null(legend_color_title)) {
    ""
  } else {
    trimws(as.character(legend_color_title)[[1L]])
  }
  bubble_q <- expression(-log[10](italic(Q) * "-value"))
  bubble_p <- expression(-log[10](italic(p) * "-value"))
  bar_q <- expression(-log[10](qvalue))
  bar_p <- expression(-log[10](pvalue))

  if (!nzchar(raw)) {
    if (style == "bubble") {
      return(if (arrange_standard == "qvalue") bubble_q else bubble_p)
    }
    return(if (arrange_standard == "qvalue") bar_q else bar_p)
  }

  ## 用户显式填写时按字面量展示，避免与默认公式同文时被替换成 expression 导致「改了没反应」
  raw
}

#' ggtext::element_markdown 下普通换行常被忽略，须转成 <br> 才能折行
y_tick_md_linebreaks <- function(s) {
  gsub("\n", "<br>", as.character(s), fixed = TRUE)
}

build_plot <- function(
    plot_data,
    arrange_standard,
    x_axis,
    color_low,
    color_high,
    x_label,
    y_label,
    title,
    size_range,
    size_breaks,
    title_size,
    plot_title_bold = FALSE,
    axis_x_title_size,
    axis_y_title_size,
    axis_x_text_size,
    axis_y_text_size,
    axis_x_title_bold = FALSE,
    axis_y_title_bold = FALSE,
    axis_x_text_bold = FALSE,
    axis_y_text_bold = FALSE,
    legend_position,
    colorbar_barwidth_mm = 4.5,
    legend_color_title = NULL,
    legend_color_title_size = 11,
    legend_size_title = NULL,
    legend_size_title_size = 11,
    show_grid = FALSE,
    grid_major_color = "#d3d3d3",
    grid_major_linewidth = 0.4,
    grid_minor_color = "#e0e0e0",
    grid_minor_linewidth = 0.35,
    highlight_terms = NULL,
    highlight_color = "#a50f15",
    y_wrap_width = 60L,
    axis_y_text_lineheight = 1.12
) {
  if (arrange_standard == "qvalue") {
    color_col <- "negLog10_qvalue"
  } else {
    color_col <- "negLog10_pvalue"
  }

  color_lab_use <- resolve_legend_color_title(
    legend_color_title,
    arrange_standard = arrange_standard,
    style = "bubble"
  )

  lst_raw <- if (is.null(legend_size_title)) {
    ""
  } else {
    trimws(as.character(legend_size_title)[[1L]])
  }
  size_lab_use <- if (nzchar(lst_raw)) {
    lst_raw
  } else {
    "Count"
  }

  sz_col <- normalize_legend_title_size(legend_color_title_size, default = 11)
  sz_sz <- normalize_legend_title_size(legend_size_title_size, default = 11)

  x_col <- switch(
    x_axis,
    "GeneRatio" = "GeneRatio",
    "RichFactor" = "RichFactor",
    "-log10(pvalue)" = "negLog10_pvalue",
    "negLog10_pvalue" = "negLog10_pvalue",
    "-log10(qvalue)" = "negLog10_qvalue",
    "-logFDR" = "negLog10_qvalue",
    "negLog10_qvalue" = "negLog10_qvalue",
    stop("不支持的 X 轴")
  )

  title_use <- if (length(title) >= 1L) {
    t0 <- trimws(as.character(title)[[1L]])
    if (nzchar(t0)) t0 else NULL
  } else {
    NULL
  }

  highlight_terms <- unique(trimws(as.character(highlight_terms)))
  highlight_terms <- highlight_terms[nzchar(highlight_terms)]
  if (length(highlight_terms) > 0L && !requireNamespace("ggtext", quietly = TRUE)) {
    stop("检测到通路标红需求，但当前环境未安装 R 包 ggtext，请先安装：install.packages('ggtext')")
  }
  use_markdown_y <- length(highlight_terms) > 0L
  yw <- normalize_y_wrap_width(y_wrap_width)
  lh_y <- normalize_axis_y_lineheight(axis_y_text_lineheight)
  y_label_fun <- if (use_markdown_y) {
    function(x) {
      wrapped <- stringr::str_wrap(as.character(x), width = yw)
      disp <- y_tick_md_linebreaks(wrapped)
      out <- disp
      hit <- as.character(x) %in% highlight_terms
      if (any(hit)) {
        out[hit] <- sprintf("<span style='color:%s;'>%s</span>", highlight_color, disp[hit])
      }
      out
    }
  } else {
    function(x) stringr::str_wrap(as.character(x), width = yw)
  }
  face_y_text <- axis_face_from_flag(axis_y_text_bold, default_bold = FALSE)
  axis_text_y_theme <- if (use_markdown_y) {
    ggtext::element_markdown(
      color = "black",
      hjust = 1,
      size = axis_y_text_size,
      face = face_y_text,
      lineheight = lh_y
    )
  } else {
    element_text(
      color = "black",
      hjust = 1,
      size = axis_y_text_size,
      face = face_y_text,
      lineheight = lh_y
    )
  }
  gmc <- normalize_color_hex(grid_major_color, "#d3d3d3")
  gnc <- normalize_color_hex(grid_minor_color, "#e0e0e0")
  gmw <- suppressWarnings(as.numeric(grid_major_linewidth))
  if (length(gmw) < 1L || !is.finite(gmw[[1L]])) {
    gmw <- 0.4
  } else {
    gmw <- max(0.03, min(2.5, gmw[[1L]]))
  }
  gnw <- suppressWarnings(as.numeric(grid_minor_linewidth))
  if (length(gnw) < 1L || !is.finite(gnw[[1L]])) {
    gnw <- 0.35
  } else {
    gnw <- max(0.03, min(2.5, gnw[[1L]]))
  }
  grid_major_theme <- if (isTRUE(show_grid)) {
    element_line(color = gmc, linetype = "dashed", linewidth = gmw)
  } else {
    element_blank()
  }
  grid_minor_theme <- if (isTRUE(show_grid)) {
    element_line(color = gnc, linetype = "dashed", linewidth = gnw)
  } else {
    element_blank()
  }

  cb_mm_raw <- suppressWarnings(as.numeric(colorbar_barwidth_mm))
  cb_mm <- if (length(cb_mm_raw) >= 1L) {
    v <- cb_mm_raw[[1L]]
    if (is.finite(v)) max(1.2, min(8, v)) else 4.5
  } else {
    4.5
  }

  p <- ggplot(
    plot_data,
    aes(
      x = .data[[x_col]],
      y = .data[["Description"]],
      size = .data[["Count"]],
      color = .data[[color_col]]
    )
  ) +
    geom_point() +
    labs(
      x = x_label,
      y = y_label,
      title = title_use,
      color = color_lab_use,
      size = size_lab_use
    ) +
    scale_color_gradient(
      low = color_low,
      high = color_high,
      guide = guide_colourbar(
        title = color_lab_use,
        barwidth = grid::unit(cb_mm, "mm"),
        theme = theme(legend.title = element_text(size = sz_col))
      )
    ) +
    scale_size_continuous(
      breaks = size_breaks,
      labels = as.character(size_breaks),
      range = size_range,
      guide = guide_legend(theme = theme(legend.title = element_text(size = sz_sz)))
    ) +
    scale_x_continuous(labels = function(x) sprintf("%.2f", as.numeric(x))) +
    scale_y_discrete(labels = y_label_fun) +
    theme_bw() +
    theme(
      legend.position = legend_position,
      legend.direction = "vertical",
      panel.background = element_rect(fill = "white", color = NA),
      panel.border = element_rect(color = "black", linewidth = 0.8, fill = NA),
      panel.grid.major = grid_major_theme,
      panel.grid.minor = grid_minor_theme,
      axis.text.x = element_text(
        color = "black",
        size = axis_x_text_size,
        face = axis_face_from_flag(axis_x_text_bold, default_bold = FALSE)
      ),
      axis.text.y = axis_text_y_theme,
      axis.title.x = element_text(
        size = axis_x_title_size,
        face = axis_face_from_flag(axis_x_title_bold, default_bold = FALSE)
      ),
      axis.title.y = element_text(
        margin = margin(r = 25, unit = "pt"),
        vjust = 0.5,
        face = axis_face_from_flag(axis_y_title_bold, default_bold = FALSE),
        size = axis_y_title_size
      ),
      plot.title = element_text(
        face = axis_face_from_flag(plot_title_bold, default_bold = FALSE),
        hjust = 0.5,
        margin = margin(b = 10),
        size = title_size
      )
    )

  p
}

#' 颜色：支持 #RRGGBB / #RGB / rgb() / rgba()，统一为 #rrggbb 供 ggplot
normalize_color_hex <- function(s, fallback = "#808080") {
  s0 <- trimws(as.character(s)[[1L]])
  if (!nzchar(s0) || identical(s0, NA_character_)) {
    return(fallback)
  }
  if (grepl("^#", s0)) {
    if (grepl("^#[0-9a-fA-F]{3}$", s0)) {
      x <- substring(s0, 2L, 4L)
      v <- strsplit(x, "")[[1L]]
      return(tolower(paste0("#", v[1L], v[1L], v[2L], v[2L], v[3L], v[3L])))
    }
    if (grepl("^#[0-9a-fA-F]{6}", s0)) {
      return(tolower(substring(s0, 1L, 7L)))
    }
    if (grepl("^#[0-9a-fA-F]{8}$", s0)) {
      return(tolower(substring(s0, 1L, 7L)))
    }
    return(fallback)
  }
  m <- regexec(
    "^rgba?\\s*\\(\\s*([0-9.]+)\\s*,\\s*([0-9.]+)\\s*,\\s*([0-9.]+)",
    s0,
    perl = TRUE,
    ignore.case = TRUE
  )
  mo <- regmatches(s0, m)[[1L]]
  if (length(mo) < 4L) {
    return(fallback)
  }
  r <- pmax(0, pmin(255, round(as.numeric(mo[[2L]]))))
  g <- pmax(0, pmin(255, round(as.numeric(mo[[3L]]))))
  b <- pmax(0, pmin(255, round(as.numeric(mo[[4L]]))))
  sprintf("#%02x%02x%02x", as.integer(r), as.integer(g), as.integer(b))
}

plot_dims_cm <- function(n_pathways, y_label_line_bonus = 0L) {
  x_len <- as.integer(max(1L, min(100L, as.integer(n_pathways))))
  y_label_line_bonus <- as.integer(max(0L, min(4L, as.integer(y_label_line_bonus))))
  if (x_len < 10L) {
    h <- 10
  } else if (x_len < 20L) {
    h <- 10 + (x_len - 10L) / 3
  } else if (x_len < 100L) {
    h <- 13 + (x_len - 20L) / 5
  } else {
    h <- 40
  }
  # 换行后每条目占更多垂直空间时，略增高默认画布，减轻相邻行重叠
  h <- h * (1 + 0.12 * as.numeric(y_label_line_bonus))
  w <- h * 1.5
  list(width_cm = w, height_cm = h)
}

#' 主入口：从文件路径生成 ggplot 对象与尺寸
enrichment_bubble_from_file <- function(
    file_path,
    original_filename = NULL,
    genome = "mmu",
    enrichment_type = "KEGG",
    top_pathways = 20L,
    arrange_standard = "pvalue",
    x_axis = "GeneRatio",
    arrange_way = "pvalue",
    color_low = "#487dad",
    color_high = "#bb9cc4",
    plot_title = "Enrichment bubble plot",
    x_axis_title = "Gene Ratio",
    y_axis_title = "Description",
    bubble_size_min = 2,
    bubble_size_max = 6,
    bubble_breaks_custom = NULL,
    title_size = 14,
    plot_title_bold = FALSE,
    axis_x_title_size = 12,
    axis_y_title_size = 12,
    axis_x_text_size = 9,
    axis_y_text_size = 8,
    axis_x_title_bold = FALSE,
    axis_y_title_bold = FALSE,
    axis_x_text_bold = FALSE,
    axis_y_text_bold = FALSE,
    legend_position = "right",
    colorbar_barwidth_mm = 4.5,
    legend_color_title = NULL,
    legend_color_title_size = 11,
    legend_size_title = NULL,
    legend_size_title_size = 11,
    show_grid = FALSE,
    grid_major_color = "#d3d3d3",
    grid_major_linewidth = 0.4,
    grid_minor_color = "#e0e0e0",
    grid_minor_linewidth = 0.35,
    highlight_terms = NULL,
    y_wrap_width = 60,
    axis_y_text_lineheight = 1.12
) {
  top_pathways <- as.integer(top_pathways)
  df <- read_input_data(file_path, original_filename = original_filename)
  df <- normalize_deg_df(df)
  ge <- map_genes(df$Gene, genome)
  er <- run_enrichment(ge$ENTREZID, enrichment_type, genome)
  core <- prepare_core(er)
  core <- add_neg_log(core, arrange_standard, top_pathways)
  if (nrow(core) == 0) stop("筛选后无通路可展示")

  plot_data <- run_result_processing(
    core, arrange_standard, x_axis, arrange_way
  )

  cm <- min(plot_data$Count, na.rm = TRUE)
  cx <- max(plot_data$Count, na.rm = TRUE)
  if (is.null(bubble_breaks_custom) || !nzchar(bubble_breaks_custom)) {
    sb <- bubble_breaks(cm, cx)
  } else {
    sb <- parse_bubble_breaks_custom(bubble_breaks_custom)
    if (length(sb) < 2L) {
      sb <- bubble_breaks(cm, cx)
    }
  }

  color_low <- normalize_color_hex(color_low, "#487dad")
  color_high <- normalize_color_hex(color_high, "#bb9cc4")
  grid_major_color <- normalize_color_hex(grid_major_color, "#d3d3d3")
  grid_minor_color <- normalize_color_hex(grid_minor_color, "#e0e0e0")
  grid_major_linewidth <- suppressWarnings(as.numeric(grid_major_linewidth))
  if (length(grid_major_linewidth) < 1L || !is.finite(grid_major_linewidth[[1L]])) {
    grid_major_linewidth <- 0.4
  } else {
    grid_major_linewidth <- max(0.03, min(2.5, grid_major_linewidth[[1L]]))
  }
  grid_minor_linewidth <- suppressWarnings(as.numeric(grid_minor_linewidth))
  if (length(grid_minor_linewidth) < 1L || !is.finite(grid_minor_linewidth[[1L]])) {
    grid_minor_linewidth <- 0.35
  } else {
    grid_minor_linewidth <- max(0.03, min(2.5, grid_minor_linewidth[[1L]]))
  }

  y_wrap_used <- normalize_y_wrap_width(y_wrap_width)
  lh_used <- normalize_axis_y_lineheight(axis_y_text_lineheight)
  desc_lens <- nchar(as.character(plot_data$Description), allowNA = TRUE)
  desc_lens[is.na(desc_lens)] <- 0L
  max_len <- suppressWarnings(max(desc_lens, na.rm = TRUE))
  if (!is.finite(max_len)) {
    max_len <- 0L
  }
  approx_extra_lines <- if (max_len < 1L) {
    0L
  } else {
    min(4L, max(0L, as.integer(ceiling(max_len / as.numeric(y_wrap_used))) - 1L))
  }
  dm <- plot_dims_cm(nrow(plot_data), y_label_line_bonus = approx_extra_lines)

  p <- build_plot(
    plot_data,
    arrange_standard,
    x_axis,
    color_low,
    color_high,
    x_axis_title,
    y_axis_title,
    plot_title,
    c(bubble_size_min, bubble_size_max),
    sb,
    title_size,
    plot_title_bold,
    axis_x_title_size,
    axis_y_title_size,
    axis_x_text_size,
    axis_y_text_size,
    axis_x_title_bold = axis_x_title_bold,
    axis_y_title_bold = axis_y_title_bold,
    axis_x_text_bold = axis_x_text_bold,
    axis_y_text_bold = axis_y_text_bold,
    legend_position,
    colorbar_barwidth_mm = colorbar_barwidth_mm,
    legend_color_title = legend_color_title,
    legend_color_title_size = legend_color_title_size,
    legend_size_title = legend_size_title,
    legend_size_title_size = legend_size_title_size,
    show_grid = show_grid,
    grid_major_color = grid_major_color,
    grid_major_linewidth = grid_major_linewidth,
    grid_minor_color = grid_minor_color,
    grid_minor_linewidth = grid_minor_linewidth,
    highlight_terms = highlight_terms,
    y_wrap_width = y_wrap_used,
    axis_y_text_lineheight = lh_used
  )

  n_input_genes <- length(unique(df$Gene[!is.na(df$Gene) & nzchar(as.character(df$Gene))]))
  plot_table_export <- plot_data
  if ("Description" %in% names(plot_table_export)) {
    plot_table_export$Description <- as.character(plot_table_export$Description)
  }
  list(
    plot = p,
    width_cm = dm$width_cm,
    height_cm = dm$height_cm,
    enrich_table = er,
    plot_table = plot_table_export,
    input_gene_n = as.integer(n_input_genes),
    y_wrap_width = as.integer(y_wrap_used),
    axis_y_text_lineheight = as.numeric(lh_used)
  )
}

truthy_flag <- function(x, default = FALSE) {
  if (is.null(x)) {
    return(default)
  }
  if (is.logical(x) && length(x) >= 1L) {
    return(isTRUE(x[[1L]]))
  }
  ch <- tolower(trimws(as.character(x[[1L]])))
  if (!nzchar(ch)) {
    return(default)
  }
  ch %in% c("1", "true", "yes", "on")
}

num_between <- function(x, default, min_v = -Inf, max_v = Inf) {
  v <- suppressWarnings(as.numeric(x))
  if (length(v) < 1L || !is.finite(v[[1L]])) {
    return(default)
  }
  max(min_v, min(max_v, v[[1L]]))
}

#' 条形图：按 gene_show_n 截取 geneID 字段（/ 分隔）用于默认展示
format_auto_bar_gene_ids <- function(gene_id_str, gene_show_n) {
  x <- unlist(strsplit(as.character(gene_id_str), "/", fixed = TRUE), use.names = FALSE)
  x <- x[nzchar(x)]
  n <- min(length(x), as.integer(gene_show_n))
  if (length(x) > n) {
    paste0(paste(x[seq_len(n)], collapse = ","), "...")
  } else if (length(x)) {
    paste(x, collapse = ",")
  } else {
    ""
  }
}

#' 用户自定义基因 ID 文本 → 图上逗号分隔展示
normalize_custom_bar_gene_display <- function(s) {
  parts <- unlist(strsplit(trimws(as.character(s)), "[,/\n;\r\t]+", perl = TRUE))
  parts <- trimws(parts)
  parts <- parts[nzchar(parts)]
  if (!length(parts)) {
    return("")
  }
  paste(parts, collapse = ",")
}

#' 解析前端 bar_custom_gene_ids_json：{ "通路名": "GENE1,GENE2", ... }
parse_bar_custom_gene_ids_json <- function(json_chr) {
  if (is.null(json_chr) || !length(json_chr)) {
    return(character(0))
  }
  s <- trimws(as.character(json_chr)[[1L]])
  if (!nzchar(s) || identical(s, "{}")) {
    return(character(0))
  }
  lst <- tryCatch(
    jsonlite::fromJSON(s, simplifyVector = FALSE),
    error = function(e) {
      message("parse_bar_custom_gene_ids_json: ", conditionMessage(e))
      NULL
    }
  )
  if (!is.list(lst) || !length(lst)) {
    return(character(0))
  }
  nm <- names(lst)
  if (is.null(nm)) {
    return(character(0))
  }
  out <- vapply(
    lst,
    function(x) {
      if (is.null(x)) {
        return("")
      }
      normalize_custom_bar_gene_display(paste(as.character(x), collapse = ","))
    },
    character(1L)
  )
  names(out) <- nm
  out[nzchar(out)]
}

assign_bar_plot_gene_labels <- function(plot_data, gene_show_n, custom_gene_ids = NULL) {
  if (!"geneID" %in% names(plot_data)) {
    plot_data$geneIDs <- rep("", nrow(plot_data))
    return(plot_data)
  }
  descs <- as.character(plot_data$Description)
  if (is.null(custom_gene_ids)) {
    custom_gene_ids <- character(0)
  }
  plot_data$geneIDs <- vapply(
    seq_len(nrow(plot_data)),
    function(i) {
      d <- descs[[i]]
      if (length(custom_gene_ids) && nzchar(d) && d %in% names(custom_gene_ids)) {
        cust <- trimws(as.character(custom_gene_ids[[d]]))
        if (nzchar(cust)) {
          return(normalize_custom_bar_gene_display(cust))
        }
      }
      format_auto_bar_gene_ids(plot_data$geneID[[i]], gene_show_n)
    },
    character(1L)
  )
  plot_data
}

map_gene_id_text_to_symbols <- function(gene_id_vec, gene_entrez) {
  if (!is.data.frame(gene_entrez) || !all(c("SYMBOL", "ENTREZID") %in% names(gene_entrez))) {
    return(as.character(gene_id_vec))
  }
  mp <- stats::setNames(as.character(gene_entrez$SYMBOL), as.character(gene_entrez$ENTREZID))
  vapply(
    as.character(gene_id_vec),
    function(s) {
      ids <- unlist(strsplit(s, "/", fixed = TRUE), use.names = FALSE)
      ids <- ids[nzchar(ids)]
      if (!length(ids)) {
        return("")
      }
      out <- unname(mp[ids])
      out[is.na(out) | !nzchar(out)] <- ids[is.na(out) | !nzchar(out)]
      paste(out, collapse = "/")
    },
    character(1L)
  )
}

build_bar_plot <- function(
    plot_data,
    arrange_standard,
    x_axis,
    color_low,
    color_high,
    x_label,
    y_label,
    title,
    title_size = 13,
    plot_title_bold = TRUE,
    axis_x_title_size = 13,
    axis_y_title_size = 13,
    axis_x_title_bold = TRUE,
    axis_y_title_bold = TRUE,
    axis_x_text_size = 11,
    legend_title = NULL,
    legend_title_size = 10,
    legend_position = "right",
    colorbar_barwidth_mm = 4.5,
    bar_width = 0.45,
    bar_alpha = 0.8,
    y_ticks = FALSE,
    y_tick_length_cm = 0,
    x_expand_left = 0,
    x_expand_right = 0,
    pathway_text_x = 0.001,
    pathway_text_size = 4.3,
    pathway_text_bold = FALSE,
    gene_text_x = 0.001,
    gene_text_vjust = 3,
    gene_text_size = 3,
    show_gene_id = FALSE,
    gene_show_n = 10,
    custom_gene_ids = NULL,
    highlight_terms = NULL,
    highlight_color = "#a50f15"
) {
  fill_var <- if (arrange_standard == "qvalue") "negLog10_qvalue" else "negLog10_pvalue"
  x_col <- switch(
    x_axis,
    "GeneRatio" = "GeneRatio",
    "RichFactor" = "RichFactor",
    "-log10(pvalue)" = "negLog10_pvalue",
    "negLog10_pvalue" = "negLog10_pvalue",
    "-log10(qvalue)" = "negLog10_qvalue",
    "-logFDR" = "negLog10_qvalue",
    "negLog10_qvalue" = "negLog10_qvalue",
    stop("不支持的 X 轴：", x_axis)
  )

  plot_data <- assign_bar_plot_gene_labels(
    plot_data,
    gene_show_n = gene_show_n,
    custom_gene_ids = custom_gene_ids
  )

  title_use <- trimws(as.character(title)[[1L]])
  if (!nzchar(title_use)) {
    title_use <- NULL
  }
  x_label_use <- if (nzchar(trimws(as.character(x_label)[[1L]]))) {
    trimws(as.character(x_label)[[1L]])
  } else {
    switch(
      x_axis,
      "GeneRatio" = "Gene Ratio",
      "RichFactor" = "Rich Factor",
      paste0("-log10(", ifelse(arrange_standard == "qvalue", "qvalue", "pvalue"), ")")
    )
  }
  y_label_use <- if (nzchar(trimws(as.character(y_label)[[1L]]))) trimws(as.character(y_label)[[1L]]) else " "
  legend_title_use <- resolve_legend_color_title(
    legend_title,
    arrange_standard = arrange_standard,
    style = "bar"
  )

  highlight_terms <- unique(trimws(as.character(highlight_terms)))
  highlight_terms <- highlight_terms[nzchar(highlight_terms)]
  plot_data$.pathway_color <- ifelse(as.character(plot_data$Description) %in% highlight_terms, highlight_color, "black")

  cb_mm_raw <- suppressWarnings(as.numeric(colorbar_barwidth_mm))
  cb_mm <- if (length(cb_mm_raw) >= 1L) {
    v <- cb_mm_raw[[1L]]
    if (is.finite(v)) max(1.2, min(8, v)) else 4.5
  } else {
    4.5
  }
  sz_leg <- num_between(legend_title_size, 10, 6, 40)

  p <- ggplot(plot_data, aes(x = .data[[x_col]], y = .data[["Description"]], fill = .data[[fill_var]])) +
    geom_col(width = bar_width, alpha = bar_alpha) +
    scale_x_continuous(expand = c(x_expand_left, x_expand_right)) +
    labs(x = x_label_use, y = y_label_use, title = title_use) +
    geom_text(
      aes(x = pathway_text_x, label = Description),
      hjust = 0,
      size = pathway_text_size,
      fontface = axis_face_from_flag(pathway_text_bold, default_bold = FALSE),
      color = plot_data$.pathway_color,
      inherit.aes = TRUE
    )
  if (truthy_flag(show_gene_id, FALSE)) {
    p <- p +
      geom_text(
        aes(x = gene_text_x, label = geneIDs, color = .data[[fill_var]]),
        hjust = 0,
        vjust = gene_text_vjust,
        size = gene_text_size
      )
  }
  p +
    scale_fill_gradient(
      low = color_low,
      high = color_high,
      guide = guide_colourbar(
        title = legend_title_use,
        barwidth = grid::unit(cb_mm, "mm"),
        theme = theme(legend.title = element_text(size = sz_leg))
      )
    ) +
    scale_color_gradient(low = color_low, high = color_high, guide = "none") +
    theme_classic() +
    theme(
      axis.title.x = element_text(size = axis_x_title_size, face = axis_face_from_flag(axis_x_title_bold, TRUE)),
      axis.title.y = element_text(size = axis_y_title_size, face = axis_face_from_flag(axis_y_title_bold, TRUE)),
      axis.text.x = element_text(size = axis_x_text_size),
      axis.text.y = element_blank(),
      axis.ticks.y = if (truthy_flag(y_ticks, FALSE)) element_line(color = "black") else element_blank(),
      axis.ticks.length.y = grid::unit(y_tick_length_cm, "cm"),
      plot.title = element_text(size = title_size, hjust = 0.5, face = axis_face_from_flag(plot_title_bold, TRUE)),
      legend.text = element_text(size = 11),
      plot.margin = margin(t = 5.5, r = 10, l = 5.5, b = 5.5),
      legend.position = legend_position
    )
}

enrichment_bar_from_file <- function(
    file_path,
    original_filename = NULL,
    genome = "mmu",
    enrichment_type = "KEGG",
    top_pathways = 10L,
    arrange_standard = "qvalue",
    x_axis = "GeneRatio",
    arrange_way = "qvalue",
    color_low = "#b6abbd",
    color_high = "#624c74",
    plot_title = "Enrichment bar plot",
    x_axis_title = "GeneRatio",
    y_axis_title = " ",
    title_size = 13,
    plot_title_bold = TRUE,
    axis_x_title_size = 13,
    axis_y_title_size = 13,
    axis_x_title_bold = TRUE,
    axis_y_title_bold = TRUE,
    axis_x_text_size = 11,
    legend_color_title = NULL,
    legend_color_title_size = 10,
    legend_position = "right",
    colorbar_barwidth_mm = 4.5,
    bar_width = 0.45,
    bar_alpha = 0.8,
    bar_y_ticks = FALSE,
    bar_y_tick_length_cm = 0,
    bar_x_expand_left = 0,
    bar_x_expand_right = 0,
    bar_pathway_text_x = 0.001,
    bar_pathway_text_size = 4.3,
    bar_pathway_text_bold = FALSE,
    bar_gene_text_x = 0.001,
    bar_gene_text_vjust = 3,
    bar_gene_text_size = 3,
    bar_show_gene_id = FALSE,
    bar_gene_show_n = 10,
    bar_custom_gene_ids_json = NULL,
    highlight_terms = NULL
) {
  top_pathways <- as.integer(top_pathways)
  df <- read_input_data(file_path, original_filename = original_filename)
  df <- normalize_deg_df(df)
  ge <- map_genes(df$Gene, genome)
  er <- run_enrichment(ge$ENTREZID, enrichment_type, genome)
  core <- prepare_core(er)
  core$geneID <- map_gene_id_text_to_symbols(core$geneID, ge)
  core <- add_neg_log(core, arrange_standard, top_pathways)
  if (nrow(core) == 0) stop("筛选后无通路可展示")
  plot_data <- run_result_processing(core, arrange_standard, x_axis, arrange_way)

  custom_gene_ids <- parse_bar_custom_gene_ids_json(bar_custom_gene_ids_json)

  color_low <- normalize_color_hex(color_low, "#b6abbd")
  color_high <- normalize_color_hex(color_high, "#624c74")
  dm <- plot_dims_cm(nrow(plot_data))
  p <- build_bar_plot(
    plot_data = plot_data,
    arrange_standard = arrange_standard,
    x_axis = x_axis,
    color_low = color_low,
    color_high = color_high,
    x_label = x_axis_title,
    y_label = y_axis_title,
    title = plot_title,
    title_size = num_between(title_size, 13, 6, 40),
    plot_title_bold = plot_title_bold,
    axis_x_title_size = num_between(axis_x_title_size, 13, 6, 40),
    axis_y_title_size = num_between(axis_y_title_size, 13, 6, 40),
    axis_x_title_bold = axis_x_title_bold,
    axis_y_title_bold = axis_y_title_bold,
    axis_x_text_size = num_between(axis_x_text_size, 11, 6, 40),
    legend_title = legend_color_title,
    legend_title_size = num_between(legend_color_title_size, 10, 6, 40),
    legend_position = legend_position,
    colorbar_barwidth_mm = num_between(colorbar_barwidth_mm, 4.5, 1.2, 8),
    bar_width = num_between(bar_width, 0.45, 0.05, 1),
    bar_alpha = num_between(bar_alpha, 0.8, 0.05, 1),
    y_ticks = bar_y_ticks,
    y_tick_length_cm = num_between(bar_y_tick_length_cm, 0, 0, 2),
    x_expand_left = num_between(bar_x_expand_left, 0, 0, 2),
    x_expand_right = num_between(bar_x_expand_right, 0, 0, 2),
    pathway_text_x = num_between(bar_pathway_text_x, 0.001, -Inf, Inf),
    pathway_text_size = num_between(bar_pathway_text_size, 4.3, 1, 20),
    pathway_text_bold = bar_pathway_text_bold,
    gene_text_x = num_between(bar_gene_text_x, 0.001, -Inf, Inf),
    gene_text_vjust = num_between(bar_gene_text_vjust, 3, -10, 10),
    gene_text_size = num_between(bar_gene_text_size, 3, 1, 20),
    show_gene_id = bar_show_gene_id,
    gene_show_n = as.integer(num_between(bar_gene_show_n, 10, 1, 200)),
    custom_gene_ids = custom_gene_ids,
    highlight_terms = highlight_terms
  )

  n_input_genes <- length(unique(df$Gene[!is.na(df$Gene) & nzchar(as.character(df$Gene))]))
  plot_table_export <- plot_data
  if ("Description" %in% names(plot_table_export)) {
    plot_table_export$Description <- as.character(plot_table_export$Description)
  }
  list(
    plot = p,
    width_cm = dm$width_cm,
    height_cm = dm$height_cm,
    enrich_table = er,
    plot_table = plot_table_export,
    input_gene_n = as.integer(n_input_genes),
    y_wrap_width = NA_integer_,
    axis_y_text_lineheight = NA_real_
  )
}
