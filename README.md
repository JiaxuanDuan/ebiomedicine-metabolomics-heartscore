# Mid-life anti-inflammatory metabolites and ASCVD (Heart SCORE) — reproducible analysis

This repository provides a reproducible skeleton for the **eBioMedicine** paper analysis (Heart SCORE), organized into clean, modular scripts and functions ready for GitHub.

> **Note**: No participant-level data are included. See `data/README.md` for how to wire your local data paths. Use a **private** repo if your IRB or journal policy requires it.

## Folder layout
```
R/                      # function definitions
R/functions/            # helpers (I/O, imputation, QC, PA wrappers)
scripts/                # pipeline steps (01_... -> 07_...)
config/                 # YAML config (file paths, toggles)
data/                   # your local data (excluded by .gitignore)
outputs/figures, tables # generated artifacts
.github/workflows/      # optional R CMD check / lint
```

## Pipeline
1. `scripts/01_data_ingest.R` — Load raw Metabolon matrices & forms, coerce IDs, basic QC.
2. `scripts/02_preprocess.R` — Feature filtering, log-transform, missingness summaries, mean-impute (or `mice`).
3. `scripts/03_events_merge.R` — Merge MACE3/MACE endpoints (2017–2021) + covariates (BP class, smoking, diabetes, lipids, IL-6, hsCRP).
4. `scripts/04_screen_unadjusted.R` — Marginal regressions metabolite ↔ event, BH-FDR, QQ plots.
5. `scripts/05_confounders.R` — Confounder estimation (PA / DPA / DDPA / BCV; `BCconf::Correction`).
6. `scripts/06_models.R` — Adjusted models with latent C (LM/GLM), effect-size tables, ROC (train/test split).
7. `scripts/07_figures_tables.R` — Publication-quality figures/tables.

## Getting started
```r
# optional: reproducible env
install.packages("renv")
renv::init()
renv::install(c("tidyverse","readxl","pROC","mice","sva","cate","BCconf","cowplot","ggplot2","gridExtra"))

# configure paths
yaml::write_yaml(list(
  data_dir = "data",
  outputs_dir = "outputs",
  forms = list(
    form1 = "FORM1_SCREENING.csv",
    form4 = "FORM4_DEMO_MEDHX.csv",
    form5 = "FORM5_PE_VISITS.csv",
    form9 = "FORM9_VAP_BASE.csv",
    formxx_markers = "FORMXX_BASE_MARKERS.csv",
    formxx_finger = "FORMXX_FINGER_VISITS.csv"
  ),
  events = list(
    y2017 = "EVENTS_NOV_2017.xlsx",
    y2018 = "EVENTS_SEP3_2018.xlsx",
    y2019 = "EVENTS_APR_2019.csv",
    y2020 = "EVENTS_DEC_2020.xlsx",
    y2021 = "EVENTS_OCT_2021.xlsx"
  ),
  metabolon_rdata = "Metabolon_OrigScale.RData",
  metabolomics_index = "Metabolomics_Index.RData"
), "config/config.yml")
```

Then run scripts 01 → 07.

## Citation
If you use this code, please cite the eBioMedicine paper (see `CITATION.cff`).

## License
MIT (see `LICENSE`). If journal policy differs, switch to "No license" or a restricted license.