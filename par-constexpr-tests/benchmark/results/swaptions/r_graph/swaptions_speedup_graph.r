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
problem_1 = c(0, 1.79443873766, 1.82517596658, 1.81433403208, 1.8055544481)
problem_2 = c(0, 1.81666041794, 3.5126191209, 3.50529094397, 3.49137070195)
problem_3 = c(0, 1.82175970615, 1.85063901877, 3.42583086778, 3.40503935684)
problem_4 = c(0, 1.81214041526, 3.51473646245, 2.06118396523, 3.49477629109)
problem_5 = c(0, 1.81567105928, 2.26370233218, 1.67582207471, 2.25260871203)

# replace negatives with < 0 values
SpeedupData <- data.frame(
  XAxis,
  problem_1,
  problem_2,
  problem_3,
  problem_4,
  problem_5
)

colnames(SpeedupData)[1] <- "Ideal Speedup"
colnames(SpeedupData)[2] <- "2 Swaptions"
colnames(SpeedupData)[3] <- "4 Swaptions"
colnames(SpeedupData)[4] <- "6 Swaptions"
colnames(SpeedupData)[5] <- "8 Swaptions"
colnames(SpeedupData)[6] <- "10 Swaptions"

SpeedupData <- melt(SpeedupData)
SpeedupData$rowid <- 1:5
SpeedupData$xaxis <- seq(0, 8, by = 2)

colnames(SpeedupData)[1] <- "Legend"

tmp <- ggplot()

tmp + geom_line(data=SpeedupData, aes(x=xaxis, y=value, group=Legend, color=Legend, linetype=Legend)) + geom_point(data=SpeedupData, size=0.75, stroke = 1, shape = 16, aes(x = xaxis, y = value, group=Legend, color=Legend))  + xlab("Number of Threads") + ylab("Speedup") + 
theme(legend.position = "bottom", text = element_text(size = 15)) + ggtitle("Swaptions Speedup")
