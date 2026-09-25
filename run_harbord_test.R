#!/usr/bin/env Rscript

# ============================================================
# Harbord's Test for Funnel-Plot Asymmetry
#
# RevMan Meta Skill
#
# Binary outcomes only.
#
# Required input columns:
#   study
#   event.e
#   n.e
#   event.c
#   n.c
#
# Usage:
#
# Rscript run_harbord_test.R data.csv OR
# Rscript run_harbord_test.R data.csv RR
#
# Harbord's test is NOT performed when fewer than
# 10 studies are available.
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

args <- commandArgs(
  trailingOnly = TRUE
)


if (length(args) < 1) {

  stop(
    paste0(
      "\nUsage:\n",
      "Rscript run_harbord_test.R ",
      "<input.csv> [effect_measure]\n\n",
      "Required columns:\n",
      "study, event.e, n.e, event.c, n.c\n\n",
      "Examples:\n",
      "Rscript run_harbord_test.R data.csv OR\n",
      "Rscript run_harbord_test.R data.csv RR\n"
    )
  )
}


input_file <- args[1]


sm <- if (length(args) >= 2) {

  toupper(
    args[2]
  )

} else {

  "OR"
}


# ------------------------------------------------------------
# Validate effect measure
# ------------------------------------------------------------

allowed_sm <- c(
  "OR",
  "RR"
)


if (!(sm %in% allowed_sm)) {

  stop(
    paste0(
      "Harbord's test in this skill is restricted ",
      "to binary outcomes.\n",
      "Allowed effect measures: OR or RR."
    )
  )
}


# ------------------------------------------------------------
# Check file
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
  "event.e",
  "n.e",
  "event.c",
  "n.c"
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
# Convert numeric columns
# ------------------------------------------------------------

numeric_cols <- c(
  "event.e",
  "n.e",
  "event.c",
  "n.c"
)


for (x in numeric_cols) {

  dat[[x]] <- suppressWarnings(
    as.numeric(
      dat[[x]]
    )
  )
}


# ------------------------------------------------------------
# Remove incomplete observations
# ------------------------------------------------------------

valid <- (
  !is.na(dat$study) &
  dat$study != "" &
  complete.cases(
    dat[, numeric_cols]
  )
)


removed <- sum(!valid)


dat <- dat[
  valid,
  ,
  drop = FALSE
]


if (removed > 0) {

  cat(
    "\n",
    removed,
    " row(s) with missing data were excluded.\n",
    sep = ""
  )
}


# ------------------------------------------------------------
# Validate event counts and sample sizes
# ------------------------------------------------------------

if (
  any(dat$event.e < 0) ||
  any(dat$event.c < 0)
) {

  stop(
    "Event counts cannot be negative."
  )
}


if (
  any(dat$n.e <= 0) ||
  any(dat$n.c <= 0)
) {

  stop(
    "Sample sizes must be greater than zero."
  )
}


if (
  any(dat$event.e > dat$n.e) ||
  any(dat$event.c > dat$n.c)
) {

  stop(
    "Event counts cannot exceed sample sizes."
  )
}


# ------------------------------------------------------------
# Number of studies
# ------------------------------------------------------------

k <- nrow(dat)


cat("\n")
cat("============================================\n")
cat("Harbord's Test\n")
cat("============================================\n\n")

cat(
  "Number of studies:",
  k,
  "\n"
)

cat(
  "Outcome type: Binary\n"
)

cat(
  "Effect measure:",
  sm,
  "\n"
)


# ------------------------------------------------------------
# Mandatory k >= 10 rule
# ------------------------------------------------------------

if (k < 10) {

  cat("\n")

  cat(
    "Fewer than 10 studies were included; therefore, ",
    "Harbord's test for funnel-plot asymmetry was not performed.\n",
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
# Construct binary meta-analysis object
# ------------------------------------------------------------

m <- metabin(
  event.e = event.e,
  n.e = n.e,
  event.c = event.c,
  n.c = n.c,
  studlab = study,
  data = dat,
  sm = sm,
  common = FALSE,
  random = TRUE
)


# ------------------------------------------------------------
# Harbord's test
#
# Score-based test for binary outcomes
# ------------------------------------------------------------

harbord <- metabias(
  m,
  method.bias = "score",
  k.min = 10
)


# ------------------------------------------------------------
# Results
# ------------------------------------------------------------

cat("\n")

cat(
  "Test: Harbord's test\n"
)


if (!is.null(harbord$statistic)) {

  statistic <- as.numeric(
    harbord$statistic
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


if (!is.null(harbord$df)) {

  df <- as.numeric(
    harbord$df
  )

  cat(
    "Degrees of freedom:",
    df,
    "\n"
  )
}


if (!is.null(harbord$p.value)) {

  p_value <- as.numeric(
    harbord$p.value
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
# Interpretation
# ------------------------------------------------------------

cat("\n")
cat("Interpretation note:\n")

cat(
  "Harbord's test evaluates funnel-plot asymmetry / ",
  "small-study effects in meta-analyses of binary outcomes.\n",
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

output_file <- "harbord_funnel_plot.png"


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
