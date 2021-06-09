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

XAxis = c(0, 2, 4, 6, 8)
problem_1 = c(0, 1.50726201827, 2.11701427645, 2.0333799154, 2.0333799154)
problem_2 = c(0, 1.49596120972, 2.09610068989, 1.97986528465, 1.97986528465)
problem_3 = c(0, 1.48399072025, 2.06552897051, 1.93317869837, 1.93317869837)
problem_4 = c(0, 1.49036618622, 2.08250627164, 1.9663886974, 1.9663886974)

SpeedupData <- data.frame(
  XAxis,
  problem_1,
  problem_2,
  problem_3,
  problem_4
)

colnames(SpeedupData)[1] <- "Ideal Speedup"
colnames(SpeedupData)[2] <- "64x64 Image"
colnames(SpeedupData)[3] <- "128x128 Image"
colnames(SpeedupData)[4] <- "256x256 Image"
colnames(SpeedupData)[5] <- "512x512 Image"

SpeedupData <- melt(SpeedupData)
SpeedupData$rowid <- 1:5
SpeedupData$xaxis <- seq(0, 8, by = 2)

colnames(SpeedupData)[1] <- "Legend"

tmp <- ggplot()

tmp + geom_line(data=SpeedupData, aes(x=xaxis, y=value, group=Legend, color=Legend, linetype=Legend)) + geom_point(data=SpeedupData, size=0.75, stroke = 1, shape = 16, aes(x = xaxis, y = value, group=Legend, color=Legend))  + xlab("Number of Threads") + ylab("Speedup") + 
theme(legend.position = "bottom", text = element_text(size = 15)) + ggtitle("SYCL Sobel Edge Detection Speedup")


