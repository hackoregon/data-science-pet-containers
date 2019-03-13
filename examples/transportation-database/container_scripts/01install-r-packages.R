#! /usr/bin/env Rscript

# make library directory if we're not 'root'
if (as.list(Sys.info())$user != 'root') {
  if (!dir.exists(Sys.getenv('R_LIBS_USER'))) {
    dir.create(Sys.getenv('R_LIBS_USER'), recursive = TRUE, mode = '0755')
  }
}

if (!require(stplanr)) {
  install.packages(
    c(
      "codetools",
      "devtools",
      "Hmisc",
      "sf",
      "snakecase",
      "stplanr",
      "sp",
      "tidytext",
      "tidyverse",
      "tmap",
      "topicmodels",
      "RPostgres"
    ),
    quiet = TRUE,
    lib = Sys.getenv('R_LIBS_USER'),
    repos = "https://cran.rstudio.com/"
  )
}
