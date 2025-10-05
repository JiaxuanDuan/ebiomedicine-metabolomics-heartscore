# 07_figures_tables.R

suppressPackageStartupMessages({
  library(tidyverse)
  library(cowplot)
})

# Example: read screening results and produce a volcano-like scatter (placeholder)
screen <- read.csv("outputs/tables/04_screen_unadjusted.csv")

png("outputs/figures/07_volcano_placeholder.png", width = 1200, height = 800, res = 150)
plot(-log10(screen$pvalue), -log10(screen$padj),
     xlab = "-log10(p)", ylab = "-log10(FDR)",
     main = "Screening summary (placeholder)")
abline(h = -log10(0.05), lty = 2)
dev.off()