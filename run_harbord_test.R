suppressPackageStartupMessages({
  if (!requireNamespace("meta", quietly = TRUE)) stop("R package 'meta' is required.")
  library(meta)
})

settings.meta("RevMan5")
cfg <- settings.meta()
stopifnot(cfg$method.tau == "DL", isTRUE(cfg$RR.Cochrane), cfg$layout == "RevMan5")

args <- commandArgs(trailingOnly = TRUE)
if (length(args) < 1) stop("Usage: Rscript run_harbord_test.R <binary.csv> [OR|RR]")
file_path <- args[1]
sm_param <- if (length(args) >= 2) toupper(args[2]) else "OR"
d <- read.csv(file_path, check.names = TRUE, stringsAsFactors = FALSE)

required <- c("event.e", "n.e", "event.c", "n.c")
if (!all(required %in% names(d))) stop("Harbord's test requires binary outcome columns: event.e, n.e, event.c, n.c.")
d <- d[complete.cases(d[, required]), , drop = FALSE]
k <- nrow(d)
if (k < 10) {
  cat("Fewer than 10 studies were included; therefore, the test for funnel-plot asymmetry was not performed.\n")
  quit(status = 0)
}

m <- metabin(event.e, n.e, event.c, n.c, data = d, sm = sm_param,
             studlab = paste(Author, Year))
test <- metabias(m, method.bias = "score", k.min = 10)
print(test)
png("harbord_funnel_plot.png", width = 1800, height = 1600, res = 200)
funnel(m)
dev.off()
