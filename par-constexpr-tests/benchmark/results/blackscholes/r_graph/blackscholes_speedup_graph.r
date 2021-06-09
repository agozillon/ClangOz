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
problem_1 = c(0, 1.10144723053, 1.37631826953, 0.74906663037, 0.74906663037)
problem_2 = c(0, 1.68341127752, 2.0770477889, 1.60273139547, 1.60273139547)
problem_3 = c(0, 1.87958175342, 2.83931712284, 3.06087146954, 3.06087146954)
problem_4 = c(0, 1.86455521883, 3.21580355045, 3.16243469109, 3.16243469109)
problem_5 = c(0, 1.8667163746, 3.36893693804, 3.09448021223, 3.09448021223)
problem_6 = c(0, 1.85963344946, 3.37678319369, 3.04144031049, 3.04144031049)
  
# last two are slower, should they be -ve?
SpeedupData <- data.frame(
  XAxis,
  problem_1,
  problem_2,
  problem_3,
  problem_4,
  problem_5,
  problem_6
)

colnames(SpeedupData)[1] <- "Ideal Speedup"
colnames(SpeedupData)[2] <- "4 Inputs"
colnames(SpeedupData)[3] <- "16 Inputs"
colnames(SpeedupData)[4] <- "1000 Inputs"
colnames(SpeedupData)[5] <- "4000 Inputs"
colnames(SpeedupData)[6] <- "16000 Inputs"
colnames(SpeedupData)[7] <- "64000 Inputs"

SpeedupData <- melt(SpeedupData)
SpeedupData$rowid <- 1:5
SpeedupData$xaxis <- seq(0, 8, by = 2)

colnames(SpeedupData)[1] <- "Legend"

tmp <- ggplot()

tmp + geom_line(data=SpeedupData, aes(x=xaxis, y=value, group=Legend, color=Legend, linetype=Legend)) + geom_point(data=SpeedupData, size=0.75, stroke = 1, shape = 16, aes(x = xaxis, y = value, group=Legend, color=Legend))  + xlab("Number of Threads") + ylab("Speedup") + 
theme(legend.position = "bottom", text = element_text(size = 15)) + ggtitle("Blackscholes Speedup")
