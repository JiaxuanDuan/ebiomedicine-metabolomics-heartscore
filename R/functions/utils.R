# ---- Utility helpers ----

# first non-missing value in a vector (used for panel records)
find_first_non_na <- function(x) {
  for (v in x) {
    if (!is.na(v)) return(v)
  }
  return(NA)
}

# safe factorize
as_factor_safe <- function(x) {
  x <- as.character(x)
  x[x == ""] <- NA
  factor(x)
}

# log1p transform helper for columns by index range
log_transform_range <- function(df, start_col, end_col) {
  df[, start_col:end_col] <- log(df[, start_col:end_col])
  df
}

# mean impute a numeric vector
mean_impute <- function(v) {
  v[is.na(v)] <- mean(v, na.rm = TRUE)
  v
}

# apply mean impute to a column range
mean_impute_range <- function(df, start_col, end_col, ref_df = NULL) {
  if (is.null(ref_df)) ref_df <- df
  for (i in start_col:end_col) {
    df[, i] <- replace(df[, i], is.na(df[, i]), mean(ref_df[, i], na.rm = TRUE))
  }
  df
}