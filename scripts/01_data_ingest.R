# 01_data_ingest.R
# Load raw matrices and forms; coerce IDs; remove duplicates

suppressPackageStartupMessages({
  library(tidyverse)
  library(readxl)
  library(yaml)
})

cfg <- yaml::read_yaml("config/config.yml")

# Load metabolomics matrices
load(file.path(cfg$data_dir, cfg$metabolon_rdata))            # expects an object like 'my.data'
load(file.path(cfg$data_dir, cfg$metabolomics_index))         # expects 'data.m.info' or similar

# Remove duplicate participants by CLIENT_IDENTIFIER rule (example: keep those with 5th char == "1")
my.data$CLIENT_IDENTIFIER <- as.character(my.data$CLIENT_IDENTIFIER)
my.data.rmdup <- my.data[substr(my.data$CLIENT_IDENTIFIER, 5, 5) == "1", ]
my.data.rmdup$CLIENT_IDENTIFIER <- as.numeric(substr(my.data.rmdup$CLIENT_IDENTIFIER, 1, 4))

# Keep metabolites with <= 50% missing (adjust threshold as needed); log-transform intensity columns
# Note: adjust 13:999 to your matrix layout (metadata columns vs metabolite columns)
keep <- colSums(is.na(my.data.rmdup)) <= floor(nrow(my.data.rmdup) * 0.5)
my.data.filtered <- my.data.rmdup[, keep]
int_start <- 13
int_end <- ncol(my.data.filtered)
my.data.filtered[, int_start:int_end] <- log(my.data.filtered[, int_start:int_end])

# Persist intermediate
save(my.data.filtered, file = file.path("outputs", "01_my.data.filtered.RData"))