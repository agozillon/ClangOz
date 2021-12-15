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
library(reshape2)

lr <- data.frame(
  lin_r1 = c(36.0018,72.7718,110.064,143.271,183.634),
  lin_r2 = c(36.5184,73.0489,107.958,143.461,179.172),
  lin_r3 = c(36.1629,71.8516,107.987,144.059,178.502),
  lin_r4 = c(36.6236,73.3827,107.899,147.501,181.075),
  lin_r5 = c(35.8453,71.8667,108.684,144.787,180.379)
)

# Create new col mean_all which averages of all rows
lr <- lr %>% mutate(mean_all = rowMeans(.))

lr$row_std = rowSds(as.matrix(lr[,c(1,2,3,4,5)]))

par2 <- data.frame(
  core2_r1 = c(20.3572,40.5925,59.8633,80.2011,99.158),
  core2_r2 = c(20.2231,40.184,59.6719,79.2653,98.641),
  core2_r3 = c(20.3464,39.4784,59.984,79.9163,98.8543),
  core2_r4 = c(20.021,39.3594,58.8468,80.2172,100.792),
  core2_r5 = c(20.0042,40.1598,59.4735,79.4194,99.7604)
)

# Create new col mean_all which averages of all rows
par2 <- par2 %>% mutate(mean_all = rowMeans(.))

# sample standard deviation
par2$row_std = rowSds(as.matrix(par2[,c(1,2,3,4,5)]))

par4 <- data.frame(
  core4_r1 = c(19.8488,20.7479,58.4241,41.0767,79.6694),
  core4_r2 = c(19.8595,20.4857,58.6548,40.8402,79.7815),
  core4_r3 = c(19.7383,20.7441,58.5163,41.373,79.5434),
  core4_r4 = c(19.8571,20.5752,58.8218,41.3699,80.0897),
  core4_r5 = c(19.9481,20.7665,58.7747,41.068,79.7149)
)

# Create new col mean_all which averages of all rows
par4 <- par4 %>% mutate(mean_all = rowMeans(.))

par4$row_std = rowSds(as.matrix(par4[,c(1,2,3,4,5)]))

par6 <- data.frame(
  core6_r1 = c(19.8556,20.6018,31.6135,68.6402,105.827),
  core6_r2 = c(20.0454,21.0807,32.0608,71.6991,109.425),
  core6_r3 = c(19.8838,20.4234,31.3755,72.0528,105.712),
  core6_r4 = c(19.9668,20.5153,31.2881,71.0031,107.3),
  core6_r5 = c(20.0933,20.9142,32.0447,67.4124,110.434)
)

# Create new col mean_all which averages of all rows
par6 <- par6 %>% mutate(mean_all = rowMeans(.))

par6$row_std = rowSds(as.matrix(par6[,c(1,2,3,4,5)]))

par8 <- data.frame(
  core8_r1 = c(20.005,21.0262,31.7023,41.2097,79.7415),
  core8_r2 = c(19.8073,20.8189,33.1361,41.7593,80.7013),
  core8_r3 = c(20.3043,20.6025,31.0799,41.6259,81.2135),
  core8_r4 = c(20.0362,20.5338,32.4005,41.1029,79.6828),
  core8_r5 = c(20.1776,20.9668,31.0309,41.205,79.4238)
)

# Create new col mean_all which averages of all rows
par8 <- par8 %>% mutate(mean_all = rowMeans(.))

par8$row_std = rowSds(as.matrix(par8[,c(1,2,3,4,5)]))

FinalDataFrame <- data.frame("Serial" = lr$mean_all,
                             "2 Threads" = par2$mean_all, 
                             "4 Threads" = par4$mean_all,
                             "6 Threads" = par6$mean_all,
                             "8 Threads" = par8$mean_all)

print(FinalDataFrame)

# Sadly still have to rename these...
colnames(FinalDataFrame)[1] <- "Serial"
colnames(FinalDataFrame)[2] <- "2 Threads"
colnames(FinalDataFrame)[3] <- "4 Threads"
colnames(FinalDataFrame)[4] <- "6 Threads"
colnames(FinalDataFrame)[5] <- "8 Threads"

FinalDataFrame <- melt(FinalDataFrame)
FinalDataFrame$rowid <- 1:5
FinalDataFrame$xaxis <- c(2, 4, 6, 8, 10)

colnames(FinalDataFrame)[1] <- "Legend"

tmp <- ggplot()

tmp + geom_line(data=FinalDataFrame, aes(x=xaxis, y=value, group=Legend, color=Legend, linetype=Legend)) + geom_point(data=FinalDataFrame, size=0.75, stroke = 1, shape = 16, aes(x = xaxis, y = value, group=Legend, color=Legend))  + xlab("Number of Swaptions") + ylab("Time Taken (Seconds)") + theme(legend.position = "bottom", text = element_text(size = 15)) + ggtitle("Swaptions")

