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

# last two are slower, should they be -ve?
SpeedupData <- data.frame(
  problem_1 = c(0, 1.28823042612, 2.34444935124, 2.93532999775, 2.93532999775),
  problem_2 = c(0, 1.35581491921, 2.29365209869, 2.83631801344, 2.83631801344),
  problem_3 = c(0, 1.33452005078, 2.28116406116, 1.56489454277, 1.56489454277),
  problem_4 = c(0, 1.35181786855, 2.1526779665, 2.77388096358, 2.77388096358),
  problem_5 = c(0, 1.3400761651, 2.21303316657, 2.80714932508, 2.80714932508)
)

tmp <- ggplot() + geom_line(data=SpeedupData, aes(x=XAxis, y=YAxis, colour="Ideal Speedup")) + geom_point(data=SpeedupData, size=0.75, stroke = 1, shape = 16, aes(x = XAxis, y = YAxis)) + geom_line(data=SpeedupData, aes(x=XAxis, y=problem_1, colour="25x25 Image")) + geom_point(data=SpeedupData, size=0.75, stroke = 1, shape = 16, aes(x=XAxis, y=problem_1)) + geom_line(data=SpeedupData, aes(x=XAxis, y=problem_2, colour="50x50 Image")) + geom_point(data=SpeedupData, size=0.75, stroke = 1, shape = 16, aes(x=XAxis, y=problem_2)) +
geom_line(data=SpeedupData, aes(x=XAxis, y=problem_3, colour="75x75 Image")) + geom_point(data=SpeedupData, size=0.75, stroke = 1, shape = 16, aes(x=XAxis, y=problem_3)) +
geom_line(data=SpeedupData, aes(x=XAxis, y=problem_4, colour="100x100 Image")) + geom_point(data=SpeedupData, size=0.75, stroke = 1, shape = 16, aes(x=XAxis, y=problem_4)) +
geom_line(data=SpeedupData, aes(x=XAxis, y=problem_5, colour="125x125 Image")) + geom_point(data=SpeedupData, size=0.75, stroke = 1, shape = 16, aes(x=XAxis, y=problem_5)) + ggtitle("Mandelbrot Speedup") + xlab("Number of Threads") + ylab("Speedup") + guides(colour=guide_legend(title="Legend")) + theme(legend.position = "bottom")

# Linear scaling
tmp + scale_x_continuous(trans="identity", breaks = scales::pretty_breaks(n = 12)) + scale_y_continuous(trans="identity", breaks = scales::pretty_breaks(n = 12))
