# Uncomment to install all packages, may need sudo access and/or some extra 
# help by downloading some external packages
#install.packages("curl")
#install.packages("httr")
#install.packages("stats")
#install.packages("graphics")
#install.packages("ggplot2")
#install.packages("plotly")
#install.packages("tinytex")
#install.packages("knitr")
#install.packages("webshot")
#install.packages("ggrepel")
#install.packages("matrixStats")

library(ggplot2)
library(ggrepel)
library(plotly)
library(knitr)
library(scales)
library(matrixStats)

# NOTE: R calculates the sample standard deviation 

# Data in Miliseconds for Linear

# 128 iterations

# technically not processors as I only have 4 cores
ThreadsXAxis = c(0, 2, 4, 6, 8)
SpeedupYAxis = c(0, 2, 4, 6, 8)


lr <- data.frame(
  lin_r1 = c(3.52486,14.1434,56.4598,224.762),
  lin_r2 = c(3.58273,14.4014,57.3698,226.776),
  lin_r3 = c(3.56317,14.212,56.1636,226.657),
  lin_r4 = c(3.55078,14.0785,56.7417,225.676),
  lin_r5 = c(3.53015,14.2365,56.6482,226.917)
)

2_core_par <- data.frame(
  2_core_r1 = c(2.30436, 9.21934, 37.2148, 148.77),
  2_core_r2 = c(2.29531,9.30696,37.3325,155.849),
  2_core_r3 = c(2.27015,9.17289,36.616,148.527),
  2_core_r4 = c(2.3128,9.29375,37.2441,149.53),
  2_core_r5 = c(2.31736,9.20864,37.0625,147.747)
)

4_core_par <- data.frame(
  4_core_r1 = c(1.6334,6.46796,26.1558,106.386),
  4_core_r2 = c(1.6041,6.50722,26.5091,105.746),
  4_core_r3 = c(1.65978,6.47859,26.1246,105.118),
  4_core_r4 = c(1.59988,6.5402,26.3226,106.925),
  4_core_r5 = c()
)

6_core_par <- data.frame(
  6_core_r1 = c(),
  6_core_r2 = c(),
  6_core_r3 = c(),
  6_core_r4 = c(),
  6_core_r5 = c()
)

8_core_par <- data.frame(
  8_core_r1 = c(1.72688,6.9909,29.0058,115.014),
  8_core_r2 = c(1.74478,6.98622,28.5228,113.633),
  8_core_r3 = c(),
  8_core_r4 = c(),
  8_core_r5 = c()
)

