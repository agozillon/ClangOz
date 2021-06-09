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
YAxis = c(0, 2, 4, 6, 8)
Iterations_10000 = c(0, 1.17447098327, 1.12483199893, 0.38471324229, 0.38471324229)
Iterations_20000 = c(0, 1.18706029091, 1.12677242954,  0.39562540557, 0.39562540557) 
Iterations_30000 = c(0, 1.18098686791, 1.12919506537, 0.39734898467, 0.39734898467)
Iterations_40000 = c(0, 1.17256830084, 1.12249896037, 0.3927638425, 0.3927638425)
Iterations_50000 = c(0, 1.17600382336, 1.1209578253, 0.39672024396, 0.39672024396)
  
# data is problem size ran on each core, so problem_1 is the smallest data set
# ran on 0, 2, 4, 6 and 8 threads. problem_1 is the second data set and so on. 
# It's the averaged values across each run 
SpeedupData <- data.frame(
  XAxis,
  Iterations_10000,
  Iterations_20000,
  Iterations_30000,
  Iterations_40000,
  Iterations_50000
)

colnames(SpeedupData)[1] <- "Ideal Speedup"
colnames(SpeedupData)[2] <- "10000 Iterations"
colnames(SpeedupData)[3] <- "20000 Iterations"
colnames(SpeedupData)[4] <- "30000 Iterations"
colnames(SpeedupData)[5] <- "40000 Iterations"
colnames(SpeedupData)[6] <- "50000 Iterations"

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
