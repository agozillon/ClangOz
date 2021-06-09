# Uncomment to install all packages, may need sudo access and/or some extra 
# help by downloading some external packages
#install.packages("data.table")
#install.packages("curl")
#install.packages("stringi")
#install.packages("reshape2")
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
#library(data.table)
library(reshape2)

# SYCL Edge Detection 

# 2-core: 1.49036618622 or 0.49036618622 speedup
# 4-core: 2.08250627164 or 1.08250627164 speedup
# 6-core: 1.9663886974 or 0.9663886974 speedup
# 8-core: 1.93357911246 or 0.93357911246 speedup

# Blackscholes

# 2-core: 1.85963344946 or 0.85963344946 speedup
# 4-core: 3.37678319369 or 2.37678319369 speedup
# 6-core: 3.04144031049 or 2.04144031049 speedup
# 8-core: 3.14831777528 or 2.14831777528 speedup

# Mandelbrot 

# 2-core: 1.3400761651 or 0.3400761651 speedup
# 4-core: 2.21303316657 or 1.21303316657 speedup
# 6-core: 2.80714932508 or 1.80714932508 speedup
# 8-core: 3.09501885324 or 2.09501885324 speedup

# N-body 

# 2-core: 1.17600382336 or 0.17600382336 speedup
# 4-core: 1.1209578253 or 0.1209578253 speedup
# 6-core: -2.52066793972 or -1.52066793972 (slowdown) speedup
# 8-core: -2.62141143481 or -1.62141143481 (slowdown) speedup

# Swaptions 

# 2-core: 1.85509461061 or 0.85509461061 speedup
# 4-core: 2.30487722625 or 1.30487722625 speedup
# 6-core: 1.72527285517 or 0.72527285517 speedup
# 8-core: 2.32103986282 or 1.32103986282 speedup

# Data in Miliseconds for Linear

# technically not processors as I only have 4 cores
ThreadsXAxis = c(0, 2, 4, 6, 8)
SpeedupYAxis = c(0, 2, 4, 6, 8)
PerfectLine = c(0, 2, 4, 6, 8)
Blackscholes = c(0, 1.85963344946, 3.37678319369, 3.04144031049, 3.14831777528)
SyclEdgeDetect = c(0, 1.49036618622,  2.08250627164, 1.9663886974, 1.93357911246)
Mandelbrot = c(0, 1.3400761651,  2.21303316657, 2.80714932508, 3.09501885324)
NBody = c(0, 1.17600382336, 1.1209578253, 0.39672024396, 0.38147388338)
Swaptions = c(0, 1.85509461061, 2.30487722625, 1.72527285517, 2.32103986282)
DataNames=c("Ideal Speedup", "Blackscholes", "SYCL Edge Detection", "Mandelbrot", 
            "N-Body", "Swaptions")

testframe <- data.frame(
  PerfectLine,
  Blackscholes,
  SyclEdgeDetect,
  Mandelbrot,
  NBody,
  Swaptions
)

# have to rename the columns to add spaces for certain names as they'll be used
# in the legend and I can't find an easier way to do this, as trying a manual
# rename replicates the legend
colnames(testframe)[1] <- "Ideal Speedup"
colnames(testframe)[2] <- "Blackscholes"
colnames(testframe)[3] <- "SYCL Edge Detection"
colnames(testframe)[4] <- "Mandelbrot"
colnames(testframe)[5] <- "N-Body"
colnames(testframe)[6] <- "Swaptions"

print(testframe)

testframe <- melt(testframe)
testframe$rowid <- 1:5
testframe$xaxis <- seq(0, 8, by = 2)

#works <- transpose(testframe)

colnames(testframe)[1] <- "Legend"

print(testframe)

tmp <- ggplot()

tmp + geom_line(data=testframe, aes(x=xaxis, y=value, group=Legend, color=Legend, linetype=Legend)) + geom_point(data=testframe, size=0.75, stroke = 1, shape = 16, aes(x = xaxis, y = value, group=Legend, color=Legend))  + xlab("Number of Threads") + ylab("Speedup") + theme(legend.position = "bottom", text = element_text(size = 15)) + ggtitle("Benchmark Speedups")

#tmp + scale_x_continuous(trans="identity", breaks = scales::pretty_breaks(n = 12)) + scale_y_continuous(trans="identity", breaks = scales::pretty_breaks(n = 12))



