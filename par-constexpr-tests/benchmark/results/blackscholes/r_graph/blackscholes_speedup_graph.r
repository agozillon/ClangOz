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
  problem_1 = c(0, 1.10144723053, 1.37631826953, 0.74906663037, 0.74906663037),
  problem_2 = c(0, 1.68341127752, 2.0770477889, 1.60273139547, 1.60273139547),
  problem_3 = c(0, 1.87958175342, 2.83931712284, 3.06087146954, 3.06087146954),
  problem_4 = c(0, 1.86455521883, 3.21580355045, 3.16243469109, 3.16243469109),
  problem_5 = c(0, 1.8667163746, 3.36893693804, 3.09448021223, 3.09448021223), 
  problem_6 = c(0, 1.85963344946, 3.37678319369, 3.04144031049, 3.04144031049)
)

tmp <- ggplot() + geom_line(data=SpeedupData, aes(x=XAxis, y=YAxis, colour="Ideal Speedup")) + geom_point(data=SpeedupData, size=0.75, stroke = 1, shape = 16, aes(x = XAxis, y = YAxis)) + geom_line(data=SpeedupData, aes(x=XAxis, y=problem_1, colour="4 Inputs")) + geom_point(data=SpeedupData, size=0.75, stroke = 1, shape = 16, aes(x=XAxis, y=problem_1)) + geom_line(data=SpeedupData, aes(x=XAxis, y=problem_2, colour="16 Inputs")) + geom_point(data=SpeedupData, size=0.75, stroke = 1, shape = 16, aes(x=XAxis, y=problem_2)) +
geom_line(data=SpeedupData, aes(x=XAxis, y=problem_3, colour="1000 Inputs")) + geom_point(data=SpeedupData, size=0.75, stroke = 1, shape = 16, aes(x=XAxis, y=problem_3)) +
geom_line(data=SpeedupData, aes(x=XAxis, y=problem_4, colour="4000 Inputs")) + geom_point(data=SpeedupData, size=0.75, stroke = 1, shape = 16, aes(x=XAxis, y=problem_4)) +
geom_line(data=SpeedupData, aes(x=XAxis, y=problem_5, colour="16000 Inputs")) + geom_point(data=SpeedupData, size=0.75, stroke = 1, shape = 16, aes(x=XAxis, y=problem_5)) +
geom_line(data=SpeedupData, aes(x=XAxis, y=problem_6, colour="64000 Inputs")) + geom_point(data=SpeedupData, size=0.75, stroke = 1, shape = 16, aes(x=XAxis, y=problem_6)) + ggtitle("Blackscholes Speedup") + xlab("Number of Threads") + ylab("Speedup") + guides(colour=guide_legend(title="Legend")) + theme(legend.position = "bottom")

# Linear scaling
tmp + scale_x_continuous(trans="identity", breaks = scales::pretty_breaks(n = 12)) + scale_y_continuous(trans="identity", breaks = scales::pretty_breaks(n = 12))
