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
problem_1 = c(0, 1.28823042612, 2.34444935124, 2.93532999775, 2.93532999775)
problem_2 = c(0, 1.35581491921, 2.29365209869, 2.83631801344, 2.83631801344)
problem_3 = c(0, 1.33452005078, 2.28116406116, 2.74244512076, 3.1770488201)
problem_4 = c(0, 1.35181786855, 2.1526779665, 2.77388096358, 2.77388096358)
problem_5 = c(0, 1.3400761651, 2.21303316657, 2.80714932508, 2.80714932508)
  
# last two are slower, should they be -ve?
SpeedupData <- data.frame(
  XAxis,
  problem_1,
  problem_2,
  problem_3,
  problem_4,
  problem_5
)

colnames(SpeedupData)[1] <- "Ideal Speedup"
colnames(SpeedupData)[2] <- "25x25 Image"
colnames(SpeedupData)[3] <- "50x50 Image"
colnames(SpeedupData)[4] <- "75x75 Image"
colnames(SpeedupData)[5] <- "100x100 Image"
colnames(SpeedupData)[6] <- "125x125 Image"

SpeedupData <- melt(SpeedupData)
SpeedupData$rowid <- 1:5
SpeedupData$xaxis <- seq(0, 8, by = 2)

colnames(SpeedupData)[1] <- "Legend"

tmp <- ggplot()

tmp + geom_line(data=SpeedupData, aes(x=xaxis, y=value, group=Legend, color=Legend, linetype=Legend)) + geom_point(data=SpeedupData, size=0.75, stroke = 1, shape = 16, aes(x = xaxis, y = value, group=Legend, color=Legend))  + xlab("Number of Threads") + ylab("Speedup") + 
theme(legend.position = "bottom", text = element_text(size = 15)) + ggtitle("Mandelbrot Speedup")
