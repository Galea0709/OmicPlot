# 在 backend 目录下执行：Rscript run_api.R
# 依赖：install.packages(c("plumber", "jsonlite", "ggplot2", "dplyr", "stringr", "readxl"))  # readxl：上传 .xlsx / .xls
# readr 常随 plumber 一并安装，用于解析 multipart 中的 CSV
#       BiocManager::install(c("clusterProfiler", "org.Mm.eg.db", "org.Hs.eg.db"))
if (!requireNamespace("plumber", quietly = TRUE)) {
  stop("请先安装 plumber：install.packages('plumber')")
}
host <- Sys.getenv("API_HOST", unset = "127.0.0.1")
port <- as.integer(Sys.getenv("API_PORT", unset = "8787"))
plumber::pr("plumber.R")$run(host = host, port = port)
