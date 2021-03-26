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

XAxis = c(0, 2, 4, 6, 8)
YAxis = c(0, 2, 4, 6, 8)

# replace negatives with < 0 values
SpeedupData <- data.frame(
  problem_1 = c(0, 1.83540513436, 0.94509973464, 0.94529519225, 0.94529519225),
  problem_2 = c(0, 1.82837556877, 3.50628267574, 0.94665297086, 0.94665297086),
  problem_3 = c(0, 1.8616315421, 1.88226505898, 3.44558354224, 3.44558354224),
  problem_4 = c(0, 1.8403492264, 3.53598706136, 2.16103512623, 2.16103512623),
  problem_5 = c(0, 1.85509461061, 2.30487722625, 1.72527285517, 1.72527285517)
)

tmp <- ggplot() + geom_line(data=SpeedupData, aes(x=XAxis, y=YAxis, colour="Ideal Speedup")) + geom_point(data=SpeedupData, size=0.75, stroke = 1, shape = 16, aes(x = XAxis, y = YAxis)) + geom_line(data=SpeedupData, aes(x=XAxis, y=problem_1, colour="2 Swaptions")) + geom_point(data=SpeedupData, size=0.75, stroke = 1, shape = 16, aes(x=XAxis, y=problem_1)) + geom_line(data=SpeedupData, aes(x=XAxis, y=problem_2, colour="4 Swaptions")) + geom_point(data=SpeedupData, size=0.75, stroke = 1, shape = 16, aes(x=XAxis, y=problem_2)) +
geom_line(data=SpeedupData, aes(x=XAxis, y=problem_3, colour="6 Swaptions")) + geom_point(data=SpeedupData, size=0.75, stroke = 1, shape = 16, aes(x=XAxis, y=problem_3)) +
geom_line(data=SpeedupData, aes(x=XAxis, y=problem_4, colour="8 Swaptions")) + geom_point(data=SpeedupData, size=0.75, stroke = 1, shape = 16, aes(x=XAxis, y=problem_4)) +
geom_line(data=SpeedupData, aes(x=XAxis, y=problem_5, colour="10 Swaptions")) + geom_point(data=SpeedupData, size=0.75, stroke = 1, shape = 16, aes(x=XAxis, y=problem_5)) + ggtitle("Swaptions Speedup") + xlab("Number of Threads") + ylab("Speedup") + guides(colour=guide_legend(title="Legend")) + theme(legend.position = "bottom")

# Linear scaling
tmp + scale_x_continuous(trans="identity", breaks = scales::pretty_breaks(n = 12)) + scale_y_continuous(trans="identity", breaks = scales::pretty_breaks(n = 12))
