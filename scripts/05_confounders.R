# 05_confounders.R

suppressPackageStartupMessages({
  library(tidyverse)
  library(sva)
  # library(cate)  # optional
  # library(BCconf) # optional (may require GitHub install)
})

load("outputs/03_dat_with_events.RData")

# build model matrix
metab <- as.matrix(dat[, 13:(which(colnames(dat) == "LAB_HDL_VAP") - 1)])
mod <- model.matrix(~ MACE3 + AGE + GENDER + RACE2 + PE_BP_CLASS + PE_SYSTOLIC + SCR_CURSMOKE +
                      DEMO_DIABETES + HS_hsCRP.log + HS_IL6.log + LAB_CHOL_VAP + LAB_HDL_VAP,
                    data = dat)

# Parallel analysis via sva::num.sv (be/leek) as reference
# (This is an example; you can plug in your own lantent confounder estimator here.)
# k_pa <- num.sv(t(metab), mod, method = "be")

# saveRDS(k_pa, "outputs/05_num_sv_be.rds")
