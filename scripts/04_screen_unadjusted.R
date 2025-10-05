# 04_screen_unadjusted.R

suppressPackageStartupMessages({
  library(tidyverse)
})

load("outputs/03_dat_with_events.RData")

int_start <- 13
int_end   <- which(colnames(dat) == "LAB_HDL_VAP") - 1  # heuristic; adjust if needed

# container for p-values
pvals <- numeric(length = int_end - int_start + 1)
names(pvals) <- colnames(dat)[int_start:int_end]

for (i in int_start:int_end) {
  fit <- lm(dat[, i] ~ as.factor(MACE3) + AGE + GENDER + RACE2 + PE_BP_CLASS + PE_SYSTOLIC +
              SCR_CURSMOKE + DEMO_DIABETES + HS_hsCRP.log + HS_IL6.log + LAB_CHOL_VAP + LAB_HDL_VAP,
            data = dat)
  pvals[i - int_start + 1] <- summary(fit)$coefficients[2, 4]
}

# BH-FDR
padj <- p.adjust(pvals, method = "BH")
screen_tbl <- tibble(
  metabolite = names(pvals),
  pvalue = pvals,
  padj = padj
) %>% arrange(padj)

write.csv(screen_tbl, "outputs/tables/04_screen_unadjusted.csv", row.names = FALSE)