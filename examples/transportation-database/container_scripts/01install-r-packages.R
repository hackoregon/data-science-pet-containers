#! /usr/bin/env Rscript

# make library directory if we're not 'root'
if (as.list(Sys.info())$user != 'root') {
  if (!dir.exists(Sys.getenv('R_LIBS_USER'))) {
    dir.create(Sys.getenv('R_LIBS_USER'), recursive = TRUE, mode = '0755')
  }
}

install.packages(
  c(
    "devtools",
    "Hmisc",
    "tidyverse",
    "RPostgres"
  ),
  quiet = TRUE
)