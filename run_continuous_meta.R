# ============================================================================== 
# R包 meta: 连续变量 RevMan 5 风格 Meta 分析脚本
# ============================================================================== 

suppressPackageStartupMessages({
  if (!requireNamespace("meta", quietly = TRUE)) install.packages("meta")
  library(meta)
})

settings.meta("RevMan5")
cfg <- settings.meta()
stopifnot(
  cfg$method.tau == "DL",
  cfg$method.random.ci == "classic",
  cfg$method.smd == "Hedges",
  identical(cfg$exact.smd, FALSE),
  cfg$layout == "RevMan5"
)

args <- commandArgs(trailingOnly = TRUE)
file_path  <- ifelse(length(args) >= 1, args[1], "13CD8MD.csv")
sm_param   <- ifelse(length(args) >= 2, args[2], "MD")
model_type <- ifelse(length(args) >= 3, args[3], "fixed")

use_common <- ifelse(tolower(model_type) == "fixed", TRUE, FALSE)
use_random <- ifelse(tolower(model_type) == "random", TRUE, FALSE)

df_continuous <- read.csv(file_path, stringsAsFactors = FALSE)

sd_c_col <- if ("sd_c" %in% colnames(df_continuous)) df_continuous$sd_c else df_continuous$s_c

meta_revman <- metacont(
  n.e     = n_e,
  mean.e  = m_e,
  sd.e    = sd_e,
  n.c     = n_c,
  mean.c  = m_c,
  sd.c    = sd_c_col,
  studlab = paste(df_continuous$Author, df_continuous$Year),
  data    = df_continuous,
  sm      = sm_param,
  common  = use_common,
  random  = use_random
)

summary(meta_revman)

png("forest_plot.png", width = 800, height = 600, res = 120)
forest(meta_revman, sortvar = Year)
dev.off()
