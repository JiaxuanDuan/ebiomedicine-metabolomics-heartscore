# 02_preprocess.R
# Factorize covariates; missingness diagnostics; mean impute

suppressPackageStartupMessages({
  library(tidyverse)
  source("R/functions/utils.R")
})

load("outputs/01_my.data.filtered.RData")

# Factorize observed covariates (adjust column names to your data object)
my.data.proc <- my.data.filtered
my.data.proc$GENDER <- as.factor(my.data.proc$GENDER)
my.data.proc$RACE2  <- as.factor(my.data.proc$RACE2)

# Missingness histogram of metabolite block
int_start <- 13
int_end <- ncol(my.data.proc)
missing <- vapply(int_start:int_end, function(i) sum(is.na(my.data.proc[, i])), numeric(1))
png("outputs/figures/02_missingness_hist.png", width = 1200, height = 800, res = 150)
hist(missing, main = "Missing values per metabolite", xlab = "Count")
dev.off()

# Mean impute the metabolite block
my.data.meanimpute <- my.data.proc
for (i in int_start:int_end) {
  my.data.meanimpute[, i] <- mean_impute(my.data.proc[, i])
}

save(my.data.meanimpute, file = "outputs/02_my.data.meanimpute.RData")