suppressPackageStartupMessages({
  if (!requireNamespace("meta", quietly = TRUE)) stop("R package 'meta' is required.")
  library(meta)
})

settings.meta("RevMan5")
cfg <- settings.meta()
stopifnot(cfg$method.tau == "DL", cfg$layout == "RevMan5")

args <- commandArgs(trailingOnly = TRUE)
if (length(args) < 1) stop("Usage: Rscript run_egger_test.R <csv> [OR|RR|MD|SMD]")
file_path <- args[1]
sm_param <- if (length(args) >= 2) toupper(args[2]) else NA_character_
d <- read.csv(file_path, check.names = TRUE, stringsAsFactors = FALSE)

is_binary <- all(c("event.e", "n.e", "event.c", "n.c") %in% names(d))
is_continuous <- all(c("m_e", "sd_e", "n_e", "m_c", "n_c") %in% names(d)) && any(c("sd_c", "s_c") %in% names(d))
if (!is_binary && !is_continuous) stop("CSV columns do not identify binary or continuous outcome data.")

if (is_binary) {
  if (is.na(sm_param)) sm_param <- "OR"
  required <- c("event.e", "n.e", "event.c", "n.c")
  d <- d[complete.cases(d[, required]), , drop = FALSE]
} else {
  if (is.na(sm_param)) sm_param <- "MD"
  sd_c_name <- if ("sd_c" %in% names(d)) "sd_c" else "s_c"
  required <- c("m_e", "sd_e", "n_e", "m_c", sd_c_name, "n_c")
  d <- d[complete.cases(d[, required]), , drop = FALSE]
}

k <- nrow(d)
if (k < 10) {
  cat("Fewer than 10 studies were included; therefore, the test for funnel-plot asymmetry was not performed.\n")
  quit(status = 0)
}

if (is_binary) {
  m <- metabin(event.e, n.e, event.c, n.c, data = d, sm = sm_param,
               studlab = paste(Author, Year))
} else {
  sd_c <- d[[sd_c_name]]
  m <- metacont(n_e, m_e, sd_e, n_c, m_c, sd_c, data = d, sm = sm_param,
                studlab = paste(Author, Year))
}

test <- metabias(m, method.bias = "linreg", k.min = 10)
print(test)
png("egger_funnel_plot.png", width = 1800, height = 1600, res = 200)
funnel(m)
dev.off()
