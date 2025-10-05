# 06_models.R

suppressPackageStartupMessages({
  library(tidyverse)
  library(pROC)
})

load("outputs/03_dat_with_events.RData")

set.seed(100)
n <- nrow(dat)
train_idx <- sample(n, floor(n * 0.7))
test_idx  <- setdiff(seq_len(n), train_idx)

train <- dat[train_idx, ]
test  <- dat[test_idx, ]

# Baseline model
m_base <- glm(as.factor(MACE3) ~ AGE + GENDER + RACE2 + PE_BP_CLASS + PE_SYSTOLIC +
                SCR_CURSMOKE + DEMO_DIABETES + HS_hsCRP.log + HS_IL6.log +
                LAB_CHOL_VAP + LAB_HDL_VAP,
              family = "binomial", data = train)

prob <- predict(m_base, newdata = test, type = "response")
roc_obj <- roc(test$MACE3 ~ prob, quiet = TRUE)
png("outputs/figures/06_roc_baseline.png", width = 1200, height = 800, res = 150)
plot.roc(roc_obj, main = sprintf("Baseline ROC (AUC = %.3f)", auc(roc_obj)))
dev.off()

save(m_base, roc_obj, file = "outputs/06_models_baseline.RData")