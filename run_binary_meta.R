# ==============================================================================
# R包 meta: 二分类变量 RevMan 5 风格 Meta 分析脚本
# ==============================================================================

suppressPackageStartupMessages({
  if (!requireNamespace("meta", quietly = TRUE)) install.packages("meta")
  library(meta)
})

# 1. 启用 RevMan 5 预设
settings.meta("revman5")

# 2. 读取终端参数
args <- commandArgs(trailingOnly = TRUE)
file_path  <- ifelse(length(args) >= 1, args[1], "4白细胞RR.csv")
sm_param   <- ifelse(length(args) >= 2, args[2], "OR")      # "OR" 或 "RR"
model_type <- ifelse(length(args) >= 3, args[3], "fixed")   # "fixed" 或 "random"

use_common <- ifelse(tolower(model_type) == "fixed", TRUE, FALSE)
use_random <- ifelse(tolower(model_type) == "random", TRUE, FALSE)

# 3. 读取数据
df_binary <- read.csv(file_path, stringsAsFactors = FALSE)

# 4. 运行 Meta 分析
meta_revman <- metabin(
  event.e = event.e,
  n.e     = n.e,
  event.c = event.c,
  n.c     = n.c,
  studlab = paste(Author, Year),
  data    = df_binary,
  sm      = sm_param,
  common  = use_common,
  random  = use_random
)

# 5. 输出汇总信息与森林图
summary(meta_revman)

png("forest_plot.png", width = 800, height = 600, res = 120)
forest(
  meta_revman,
  sortvar = Year
)
dev.off()
