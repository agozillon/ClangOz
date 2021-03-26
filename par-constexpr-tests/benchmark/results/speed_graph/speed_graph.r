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

# NOTE: R calculates the sample standard deviation 

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

perfectline <- data.frame(
  dat = c(0, 2, 4, 6, 8)
)

blackscholes <- data.frame(
  dat = c(0, 1.85963344946, 3.37678319369, 3.04144031049, 3.14831777528)
)

sycledgedetect <- data.frame(
  dat = c(0, 1.49036618622,  2.08250627164, 1.9663886974, 1.93357911246)
)

mandelbrot <- data.frame(
  dat = c(0, 1.3400761651,  2.21303316657, 2.80714932508, 3.09501885324)
)

nbody <- data.frame(
  dat = c(0, 1.17600382336, 1.1209578253, -2.52066793972, -2.62141143481)
)

swaptions <- data.frame(
  dat = c(0, 1.85509461061, 2.30487722625, 1.72527285517, 2.32103986282)
)

tmp <- ggplot() + geom_line(data=perfectline, aes(x=ThreadsXAxis, y=dat, colour="Ideal Speedup")) + geom_point(data=perfectline, size=0.75, stroke = 1, shape = 16, aes(x = ThreadsXAxis, y = dat)) + geom_line(data=blackscholes, aes(x=ThreadsXAxis, y=dat, colour="Blackscholes")) + geom_point(data=blackscholes, size=0.75, stroke = 1, shape = 16, aes(x=ThreadsXAxis, y=dat)) + geom_line(data=sycledgedetect, aes(x=ThreadsXAxis, y=dat, colour="SYCL Edge Detection")) + geom_point(data=sycledgedetect, size=0.75, stroke = 1, shape = 16, aes(x=ThreadsXAxis, y=dat)) + geom_line(data=mandelbrot, aes(x=ThreadsXAxis, y=dat, colour="Mandelbrot")) + geom_point(data=mandelbrot, size=0.75, stroke = 1, shape = 16, aes(x=ThreadsXAxis, y=dat)) + geom_line(data=nbody, aes(x=ThreadsXAxis, y=dat, colour="N-Body")) + geom_point(data=nbody, size=0.75, stroke = 1, shape = 16, aes(x=ThreadsXAxis, y=dat)) + geom_line(data=swaptions, aes(x=ThreadsXAxis, y=dat, colour="Swaptions")) + geom_point(data=swaptions, size=0.75, stroke = 1, shape = 16, aes(x=ThreadsXAxis, y=dat)) + ggtitle("Benchmarks Speedup (4-Core CPU)") + xlab("Number of Threads") + ylab("Speedup") + guides(colour=guide_legend(title="Legend")) + theme(legend.position = "bottom")

tmp + scale_x_continuous(trans="identity", breaks = scales::pretty_breaks(n = 12)) + scale_y_continuous(trans="identity", breaks = scales::pretty_breaks(n = 12))



