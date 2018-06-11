#! /usr/bin/env Rscript

library(tidyverse)

cat("\nStacking the 'crosswalk' files\n")
xwalk <- bind_rows(
  read_csv(
    "~/Raw/LODES/or_xwalk.csv",
    col_types = cols(.default = col_character())
  ),
  read_csv(
    "~/Raw/LODES/wa_xwalk.csv",
    col_types = cols(.default = col_character())
  )
)

# filter down to metro area
xwalk <- xwalk %>%
  filter(cbsaname == "Portland-Vancouver-Hillsboro, OR-WA")
xwalk %>% write_csv("~/Raw/LODES/xwalk.csv")

cat("\nStacking the 'origin_destination' files\n")
origin_destination <- tibble()
for (ixyear in 2002:2015) {
  for (state in c("or", "wa")) {
    cat(ixyear, state, "\n")
    for (part in c("main", "aux")) {
      file <- paste(
        "~/Raw/LODES/",
        state, "_od_", part, "_JT00_", ixyear, ".csv",
        sep = ""
      )
      temp <- read_csv(file, progress = FALSE, col_types = cols(
        h_geocode = col_character(),
        w_geocode = col_character()
      ))
      temp <- temp %>% select(w_geocode, h_geocode, commuters = S000)
      temp <- temp %>% mutate(year = ixyear)
      temp <- temp %>% semi_join(
        xwalk, by = c("w_geocode" = "tabblk2010"))
      temp <- temp %>% semi_join(
        xwalk, by = c("h_geocode" = "tabblk2010"))
      origin_destination <- origin_destination %>% bind_rows(temp)
      rm(temp); gc()
    }
  }
}
origin_destination %>% write_csv("~/Raw/LODES/origin_destination.csv")

cat("\nStacking the 'workplace_area_characteristics' files\n")
workplace_area_characteristics <- tibble()
for (ixyear in 2002:2015) {
  for (state in c("or", "wa")) {
    cat(ixyear, state, "\n")
    file <- paste(
      "~/Raw/LODES/",
      state, "_wac_S000_JT00_", ixyear, ".csv", sep = ""
    )
    temp <- read_csv(file, progress = FALSE, col_types = cols(
      w_geocode = col_character()
    ))
    temp <- temp %>% select(-createdate)
    temp <- temp %>% mutate(year = ixyear)
    temp <- temp %>% semi_join(
      xwalk, by = c("w_geocode" = "tabblk2010"))
    workplace_area_characteristics <- workplace_area_characteristics %>%
      bind_rows(temp)
    rm(temp); gc()
  }
}
workplace_area_characteristics %>%
  write_csv("~/Raw/LODES/workplace_area_characteristics.csv")

cat("\nStacking the 'residence_area_characteristics' files\n")
residence_area_characteristics <- tibble()
for (ixyear in 2002:2015) {
  for (state in c("or", "wa")) {
    cat(ixyear, state, "\n")
    file <- paste(
      "~/Raw/LODES/",
      state, "_rac_S000_JT00_", ixyear, ".csv", sep = ""
    )
    temp <- read_csv(file, progress = FALSE, col_types = cols(
      h_geocode = col_character()
    ))
    temp <- temp %>% select(-createdate)
    temp <- temp %>% mutate(year = ixyear)
    temp <- temp %>% semi_join(
      xwalk, by = c("h_geocode" = "tabblk2010"))
    residence_area_characteristics <- residence_area_characteristics %>%
      bind_rows(temp)
    rm(temp); gc()
  }
}
residence_area_characteristics %>%
  write_csv("~/Raw/LODES/residence_area_characteristics.csv")
