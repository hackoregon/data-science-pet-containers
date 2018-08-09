#! /usr/bin/env Rscript

install.packages(c(
  "bayesQR",
  "brms",
  "greta",
  "rjags",
  "rstan",
  "rstanarm",
  "rstantools"
), quiet = TRUE, INSTALL_opt = "--no-load_test")
devtools::install_github("rmcelreath/rethinking", build_vignettes = TRUE, force = TRUE, quiet = TRUE)
