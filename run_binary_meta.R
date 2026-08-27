# ==============================================================================
# R包 meta + magick: 二分类变量 RevMan 5 风格 Meta 分析脚本
# ==============================================================================

suppressPackageStartupMessages({
  if (!requireNamespace("meta", quietly = TRUE)) install.packages("meta")
  if (!requireNamespace("magick", quietly = TRUE)) install.packages("magick")
  library(meta)
  library(magick)
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

# 5. 输出汇总信息
summary(meta_revman)

# 6. 先将森林图渲染为临时高分辨率图像
temp_file <- tempfile(fileext = ".png")
png(temp_file, width = 2400, height = 1400, res = 200)

forest(
  meta_revman,
  sortvar  = Year,
  spacing  = 1.25,     # 增加垂直行距，避免上下文本重叠
  fontsize = 10,       # 设置适中的字号
  col.gap  = "0.6cm"   # 拉开列与列之间的距离
)

dev.off()

# 7. 使用 magick 包进行图像智能裁切与留白优化
img <- image_read(temp_file)

# 自动裁切图像边缘无效的空白区，随后加上 50px 均匀的白色边框 Padding
img_processed <- img %>%
  image_trim() %>%
  image_border(geometry = "50x50", color = "white")

# 保存为终版 forest_plot.png
image_write(img_processed, path = "forest_plot.png", format = "png")

# 清理临时文件
unlink(temp_file)
