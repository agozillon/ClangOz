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

c(16, 32, 64, 128, 256)

XAxis = c(0, 2, 4, 6, 8)
YAxis = c(0, 2, 4, 6, 8)
Bodies_16 = c(0, 1.69395102823, 2.43313753956, 1.66425516931, 2.50665869839)
Bodies_32 = c(0, 1.78208095794, 3.0187682044, 2.57043132346, 3.04324700299)
Bodies_64 = c(0, 1.81468446526, 3.31358115347, 2.86882085093, 3.26436284073)
Bodies_128 = c(0, 1.84825676151, 3.42560470497, 3.23502365306, 3.42068381717)
Bodies_256 = c(0, 1.88177780104, 3.46840194162, 3.27536049665, 3.51546899)

# data is problem size ran on each core, so problem_1 is the smallest data set
# ran on 0, 2, 4, 6 and 8 threads. problem_1 is the second data set and so on. 
# It's the averaged values across each run 
SpeedupData <- data.frame(
  XAxis,
  Bodies_16,
  Bodies_32,
  Bodies_64,
  Bodies_128,
  Bodies_256
)

colnames(SpeedupData)[1] <- "Ideal Speedup"
colnames(SpeedupData)[2] <- "16 Bodies"
colnames(SpeedupData)[3] <- "32 Bodies"
colnames(SpeedupData)[4] <- "64 Bodies"
colnames(SpeedupData)[5] <- "128 Bodies"
colnames(SpeedupData)[6] <- "256 Bodies"

SpeedupData <- melt(SpeedupData)
SpeedupData$rowid <- 1:5
SpeedupData$xaxis <- seq(0, 8, by = 2)

colnames(SpeedupData)[1] <- "Legend"

print(SpeedupData)

tmp <- ggplot()

tmp + geom_line(data=SpeedupData, aes(x=xaxis, y=value, group=Legend, color=Legend, linetype=Legend)) + geom_point(data=SpeedupData, size=0.75, stroke = 1, shape = 16, aes(x = xaxis, y = value, group=Legend, color=Legend))  + xlab("Number of Threads") + ylab("Speedup") + 
theme(legend.position = "bottom", text = element_text(size = 15)) + ggtitle("N-Body Speedup")

## Linear scaling
#tmp + scale_x_continuous(trans="identity", breaks = scales::pretty_breaks(n = 12)) + scale_y_continuous(trans="identity", breaks = scales::pretty_breaks(n = 12))
