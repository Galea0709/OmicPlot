# R 绘图 API（首次构建需下载 Bioconductor 包，可能 15–40 分钟，视网络而定）
FROM rocker/r-ver:4.4.1

RUN apt-get update && apt-get install -y --no-install-recommends \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    libfontconfig1-dev \
    libharfbuzz-dev \
    libfribidi-dev \
    libfreetype6-dev \
    libpng-dev \
    libtiff5-dev \
    libjpeg-dev \
    libcairo2-dev \
    && rm -rf /var/lib/apt/lists/*

RUN R -e "install.packages('BiocManager', repos='https://cloud.r-project.org')" \
 && R -e "install.packages(c( \
      'plumber', 'jsonlite', 'ggplot2', 'dplyr', 'stringr', 'readxl', \
      'ggtext', 'Cairo', 'ragg', 'readr' \
    ), repos='https://cloud.r-project.org')" \
 && R -e "BiocManager::install(c( \
      'clusterProfiler', 'org.Mm.eg.db', 'org.Hs.eg.db' \
    ), ask=FALSE, update=FALSE)"

WORKDIR /app
COPY enrichment_logic.R plumber.R run_api.R ./

ENV API_HOST=0.0.0.0
ENV API_PORT=8787
EXPOSE 8787

CMD ["Rscript", "run_api.R"]
