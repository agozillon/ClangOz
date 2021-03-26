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

SpeedupData <- data.frame(
  problem_1 = c(0, 1.50726201827, 2.11701427645, 2.0333799154, 2.0333799154),
  problem_2 = c(0, 1.49596120972, 2.09610068989, 1.97986528465, 1.97986528465),
  problem_3 = c(0, 1.48399072025, 2.06552897051, 1.93317869837, 1.93317869837),
  problem_4 = c(0, 1.49036618622, 2.08250627164, 1.9663886974, 1.9663886974)
)

tmp <- ggplot() + geom_line(data=SpeedupData, aes(x=XAxis, y=YAxis, colour="Ideal Speedup")) + geom_point(data=SpeedupData, size=0.75, stroke = 1, shape = 16, aes(x = XAxis, y = YAxis)) + geom_line(data=SpeedupData, aes(x=XAxis, y=problem_1, colour="64x64 Image")) + geom_point(data=SpeedupData, size=0.75, stroke = 1, shape = 16, aes(x=XAxis, y=problem_1)) + geom_line(data=SpeedupData, aes(x=XAxis, y=problem_2, colour="128x128 Image")) + geom_point(data=SpeedupData, size=0.75, stroke = 1, shape = 16, aes(x=XAxis, y=problem_2)) +
geom_line(data=SpeedupData, aes(x=XAxis, y=problem_3, colour="256x256 Image")) + geom_point(data=SpeedupData, size=0.75, stroke = 1, shape = 16, aes(x=XAxis, y=problem_3)) +
geom_line(data=SpeedupData, aes(x=XAxis, y=problem_4, colour="512x512 Image")) + geom_point(data=SpeedupData, size=0.75, stroke = 1, shape = 16, aes(x=XAxis, y=problem_4)) + ggtitle("SYCL Sobel Edge Detection") + xlab("Number of Threads") + ylab("Speedup") + guides(colour=guide_legend(title="Legend")) + theme(legend.position = "bottom")

# Linear scaling
tmp + scale_x_continuous(trans="identity", breaks = scales::pretty_breaks(n = 12)) + scale_y_continuous(trans="identity", breaks = scales::pretty_breaks(n = 12))


