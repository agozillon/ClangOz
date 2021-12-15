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
problem_1 = c(0, 1.83540513436, 0.94509973464, 0.94529519225, 0.94453356154)
problem_2 = c(0, 1.82837556877, 3.50628267574, 0.94665297086, 0.94285072682)
problem_3 = c(0, 1.8616315421, 1.88226505898, 3.44558354224, 0.96067876954)
problem_4 = c(0, 1.8403492264, 3.53598706136, 2.16103512623, 3.53096993639)
problem_5 = c(0, 1.85509461061, 2.30487722625, 1.72527285517, 2.32103986282)

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
