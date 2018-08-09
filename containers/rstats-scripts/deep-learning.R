#! /usr/bin/env Rscript

install.packages(c(
  "lime",
  "reticulate",
  "sparklyr",
  "tensorflow",
  "keras",
  "tfestimators",
  "tfdatasets"
), quiet = TRUE)
devtools::install_github("thomasp85/lime", force = TRUE, build_vignettes = TRUE, quiet = TRUE)
devtools::install_github("rstudio/reticulate", force = TRUE, build_vignettes = TRUE, quiet = TRUE)
devtools::install_github("rstudio/sparklyr", force = TRUE, build_vignettes = TRUE, quiet = TRUE)
devtools::install_github("rstudio/tensorflow", force = TRUE, build_vignettes = TRUE, quiet = TRUE)
devtools::install_github("rstudio/keras", force = TRUE, build_vignettes = TRUE, quiet = TRUE)
devtools::install_github("rstudio/tfestimators", force = TRUE, build_vignettes = TRUE, quiet = TRUE)
devtools::install_github("rstudio/tfdatasets", force = TRUE, build_vignettes = TRUE, quiet = TRUE)
library(keras)
install_keras()
is_keras_available()
