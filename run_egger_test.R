#!/usr/bin/env Rscript

# ============================================================
# Egger's Regression Test for Funnel-Plot Asymmetry
#
# RevMan Meta Skill
#
# Required input columns:
#   study
#   TE
#   seTE
#
# TE:
#   Treatment effect on the analysis scale.
#
# Examples:
#   OR / RR -> log(OR) / log(RR)
#   MD      -> MD
#   SMD     -> SMD
#
# Usage:
#
# Rscript run_egger_test.R data.csv OR
# Rscript run_egger_test.R data.csv RR
# Rscript run_egger_test.R data.csv MD
# Rscript run_egger_test.R data.csv SMD
#
# Egger's test is NOT performed when fewer than 10 studies
# are available.
# ============================================================


# ------------------------------------------------------------
# Load packages
# ------------------------------------------------------------

suppressPackageStartupMessages({
  library(meta)
})


# ------------------------------------------------------------
# Command-line arguments
# ------------------------------------------------------------

args <- commandArgs(trailingOnly = TRUE)

if (length(args) < 1) {

  stop(
    paste0(
      "\nUsage:\n",
      "Rscript run_egger_test.R <input.csv> [effect_measure]\n\n",
      "Required columns:\n",
      "study, TE, seTE\n\n",
      "Examples:\n",
      "Rscript run_egger_test.R data.csv OR\n",
      "Rscript run_egger_test.R data.csv RR\n",
      "Rscript run_egger_test.R data.csv MD\n",
      "Rscript run_egger_test.R data.csv SMD\n"
    )
  )
}


input_file <- args[1]

sm <- if (length(args) >= 2) {
  toupper(args[2])
} else {
  "OR"
}


# ------------------------------------------------------------
# Check input file
# ------------------------------------------------------------

if (!file.exists(input_file)) {
  stop(
    paste(
      "Input file does not exist:",
      input_file
    )
  )
}


# ------------------------------------------------------------
# Read data
# ------------------------------------------------------------

dat <- read.csv(
  input_file,
  stringsAsFactors = FALSE,
  check.names = FALSE
)


# ------------------------------------------------------------
# Required columns
# ------------------------------------------------------------

required_cols <- c(
  "study",
  "TE",
  "seTE"
)

missing_cols <- setdiff(
  required_cols,
  names(dat)
)

if (length(missing_cols) > 0) {

  stop(
    paste0(
      "Missing required column(s): ",
      paste(
        missing_cols,
        collapse = ", "
      )
    )
  )
}


# ------------------------------------------------------------
# Convert numerical variables
# ------------------------------------------------------------

dat$TE <- suppressWarnings(
  as.numeric(dat$TE)
)

dat$seTE <- suppressWarnings(
  as.numeric(dat$seTE)
)


# ------------------------------------------------------------
# Remove incomplete / invalid observations
# ------------------------------------------------------------

valid <- (
  !is.na(dat$study) &
  dat$study != "" &
  is.finite(dat$TE) &
  is.finite(dat$seTE) &
  dat$seTE > 0
)

removed <- sum(!valid)

dat <- dat[valid, , drop = FALSE]


if (removed > 0) {

  cat(
    "\n",
    removed,
    " row(s) with missing or invalid data were excluded.\n",
    sep = ""
  )
}


# ------------------------------------------------------------
# Number of studies
# ------------------------------------------------------------

k <- nrow(dat)


cat("\n")
cat("============================================\n")
cat("Egger's Regression Test\n")
cat("============================================\n\n")

cat(
  "Number of studies:",
  k,
  "\n"
)


# ------------------------------------------------------------
# Mandatory k >= 10 rule
# ------------------------------------------------------------

if (k < 10) {

  cat("\n")

  cat(
    "Fewer than 10 studies were included; therefore, ",
    "Egger's test for funnel-plot asymmetry was not performed.\n",
    sep = ""
  )

  cat("\n")

  cat(
    "No test statistic or P value was calculated.\n"
  )

  cat(
    "This result should not be interpreted as evidence ",
    "for or against publication bias.\n"
  )

  cat("\n")
  cat("============================================\n")

  quit(
    save = "no",
    status = 0
  )
}


# ------------------------------------------------------------
# Construct generic meta-analysis object
# ------------------------------------------------------------

m <- metagen(
  TE = TE,
  seTE = seTE,
  studlab = study,
  data = dat,
  sm = sm,
  common = FALSE,
  random = TRUE
)


# ------------------------------------------------------------
# Egger's regression test
# ------------------------------------------------------------

egger <- metabias(
  m,
  method.bias = "linreg",
  k.min = 10
)


# ------------------------------------------------------------
# Extract results
# ------------------------------------------------------------

cat("\n")
cat(
  "Test: Egger's regression test\n"
)

cat(
  "Effect measure:",
  sm,
  "\n"
)


if (!is.null(egger$statistic)) {

  statistic <- as.numeric(
    egger$statistic
  )

  cat(
    "Test statistic:",
    format(
      statistic,
      digits = 4
    ),
    "\n"
  )
}


if (!is.null(egger$df)) {

  df <- as.numeric(
    egger$df
  )

  cat(
    "Degrees of freedom:",
    df,
    "\n"
  )
}


if (!is.null(egger$p.value)) {

  p_value <- as.numeric(
    egger$p.value
  )

  cat(
    "P value:",
    format.pval(
      p_value,
      digits = 4,
      eps = 0.0001
    ),
    "\n"
  )
}


# ------------------------------------------------------------
# Interpretation note
# ------------------------------------------------------------

cat("\n")
cat("Interpretation note:\n")

cat(
  "Egger's test evaluates funnel-plot asymmetry / ",
  "small-study effects.\n",
  sep = ""
)

cat(
  "A statistically significant result does not by itself ",
  "prove publication bias.\n",
  sep = ""
)

cat(
  "A nonsignificant result should not be interpreted as ",
  "evidence that publication bias is absent.\n",
  sep = ""
)


# ------------------------------------------------------------
# Funnel plot
# ------------------------------------------------------------

output_file <- "egger_funnel_plot.png"

png(
  filename = output_file,
  width = 1800,
  height = 1800,
  res = 220
)

funnel(
  m,
  studlab = FALSE,
  xlab = sm
)

dev.off()


cat("\n")

cat(
  "Funnel plot saved as:",
  output_file,
  "\n"
)

cat("\n")
cat("============================================\n")
