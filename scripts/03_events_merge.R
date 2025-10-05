# 03_events_merge.R

suppressPackageStartupMessages({
  library(tidyverse)
  library(readxl)
  library(yaml)
  source("R/functions/utils.R")
})

cfg <- yaml::read_yaml("config/config.yml")
load("outputs/02_my.data.meanimpute.RData")

# Attach BP class & systolic BP from FORM5
form5 <- read.csv(file.path(cfg$data_dir, cfg$forms$form5))
form1 <- read.csv(file.path(cfg$data_dir, cfg$forms$form1))
form4 <- read.csv(file.path(cfg$data_dir, cfg$forms$form4))
form9 <- read.csv(file.path(cfg$data_dir, cfg$forms$form9))
markers <- read.csv(file.path(cfg$data_dir, cfg$forms$formxx_markers))

# helper to map first non-missing per ID
attach_first <- function(df, id, src, var) {
  df[[var]] <- NA
  for (i in unique(src[[id]])) {
    if (sum(df$CLIENT_IDENTIFIER == i) != 0) {
      df[df$CLIENT_IDENTIFIER == i, var] <- find_first_non_na(src[src[[id]] == i, var])
    }
  }
  df
}

dat <- my.data.meanimpute
dat <- attach_first(dat, "IDNUM", form5, "PE_BP_CLASS")
dat <- attach_first(dat, "IDNUM", form5, "PE_SYSTOLIC")
dat <- attach_first(dat, "IDNUM", form1, "SCR_CURSMOKE")
dat$SCR_CURSMOKE <- as_factor_safe(dat$SCR_CURSMOKE)
dat <- attach_first(dat, "IDNUM", form4, "DEMO_DIABETES")
dat$DEMO_DIABETES <- as_factor_safe(dat$DEMO_DIABETES)

# inflammatory markers
for (v in c("HS_hsCRP", "HS_IL6")) {
  dat <- attach_first(dat, "IDNUM", markers, v)
}
dat$HS_hsCRP.log <- log(dat$HS_hsCRP)
dat$HS_IL6.log   <- log(dat$HS_IL6)

# lipids from FORM9
for (v in c("LAB_CHOL_VAP", "LAB_HDL_VAP")) {
  dat <- attach_first(dat, "IDNUM", form9, v)
}

# Build MACE3 event panel (2017–2021)
events_list <- list(
  `2017` = read_excel(file.path(cfg$data_dir, cfg$events$y2017)),
  `2018` = read_excel(file.path(cfg$data_dir, cfg$events$y2018)),
  `2019` = read.csv(file.path(cfg$data_dir, cfg$events$y2019)),
  `2020` = read_excel(file.path(cfg$data_dir, cfg$events$y2020)),
  `2021` = read_excel(file.path(cfg$data_dir, cfg$events$y2021))
)

dat$MACE3.count <- 0
for (yr in names(events_list)) {
  ev <- events_list[[yr]]
  col <- paste0("MACE3", yr)
  dat[[col]] <- NA
  for (i in unique(ev$IDNUM)) {
    if (sum(dat$CLIENT_IDENTIFIER == i) != 0) {
      val <- find_first_non_na(ev[ev$IDNUM == i, "MACE3"][[1]])
      if (!is.null(val)) {
        if (is.character(val)) {
          val <- ifelse(val %in% c("Yes", "1"), 1, ifelse(val %in% c("No","0"), 0, NA))
        }
        dat[dat$CLIENT_IDENTIFIER == i, col] <- val
        if (!is.na(val) && val == 1) dat[dat$CLIENT_IDENTIFIER == i, "MACE3.count"] <- dat[dat$CLIENT_IDENTIFIER == i, "MACE3.count"] + 1
      }
    }
  }
}
dat$MACE3 <- ifelse(dat$MACE3.count > 0, 1, 0)

save(dat, file = "outputs/03_dat_with_events.RData")