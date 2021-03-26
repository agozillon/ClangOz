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
  problem_1 = c(0, 1.17447098327, 1.12483199893, 0.38471324229, 0.38471324229),
  problem_2 = c(0, 1.18706029091, 1.12677242954,  0.39562540557, 0.39562540557), 
  problem_3 = c(0, 1.18098686791, 1.12919506537, 0.39734898467, 0.39734898467),
  problem_4 = c(0, 1.17256830084, 1.12249896037, 0.3927638425, 0.3927638425),
  problem_5 = c(0, 1.17600382336, 1.1209578253, 0.39672024396, 0.39672024396)
)

tmp <- ggplot() + geom_line(data=SpeedupData, aes(x=XAxis, y=YAxis, colour="Ideal Speedup")) + geom_point(data=SpeedupData, size=0.75, stroke = 1, shape = 16, aes(x = XAxis, y = YAxis)) + geom_line(data=SpeedupData, aes(x=XAxis, y=problem_1, colour="10000 Iterations")) + geom_point(data=SpeedupData, size=0.75, stroke = 1, shape = 16, aes(x=XAxis, y=problem_1)) + geom_line(data=SpeedupData, aes(x=XAxis, y=problem_2, colour="20000 Iterations")) + geom_point(data=SpeedupData, size=0.75, stroke = 1, shape = 16, aes(x=XAxis, y=problem_2)) +
geom_line(data=SpeedupData, aes(x=XAxis, y=problem_3, colour="30000 Iterations")) + geom_point(data=SpeedupData, size=0.75, stroke = 1, shape = 16, aes(x=XAxis, y=problem_3)) +
geom_line(data=SpeedupData, aes(x=XAxis, y=problem_4, colour="40000 Iterations")) + geom_point(data=SpeedupData, size=0.75, stroke = 1, shape = 16, aes(x=XAxis, y=problem_4)) +
geom_line(data=SpeedupData, aes(x=XAxis, y=problem_5, colour="50000 Iterations")) + geom_point(data=SpeedupData, size=0.75, stroke = 1, shape = 16, aes(x=XAxis, y=problem_5)) + ggtitle("N-Body Speedup") + xlab("Number of Threads") + ylab("Speedup") + guides(colour=guide_legend(title="Legend")) + theme(legend.position = "bottom")

# Linear scaling
tmp + scale_x_continuous(trans="identity", breaks = scales::pretty_breaks(n = 12)) + scale_y_continuous(trans="identity", breaks = scales::pretty_breaks(n = 12))
