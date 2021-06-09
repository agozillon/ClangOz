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

#Blackscholes
#Use a log scale on both axes for blackscholes; and use seconds on the y axis
#Add more data points for small data
#Consider a graph of SpeedUp - this would show the speedup relative to the unmodified serial Clang compiler on the y axis instead of time. Perhaps one speedup graph could show more than one benchmark?

library(ggplot2)
library(ggrepel)
library(plotly)
library(knitr)
library(scales)
library(matrixStats)
library(reshape2)

# NOTE: R calculates the sample standard deviation 

# Data in Miliseconds for Linear

XAxis = c(64, 128, 256, 512)

lr <- data.frame(
  lin_r1 = c(3.47606,13.6732,55.5267,225.34),
  lin_r2 = c(3.48015,13.8969,55.4952,225.308),
  lin_r3 = c(3.5009,14.0305,54.8867,222.056),
  lin_r4 = c(3.45055,13.9575,55.3591,223.336),
  lin_r5 = c(3.46566,13.9953,55.5169,222.143)
)

# Create new col mean_all which averages of all rows
lr <- lr %>% mutate(mean_all = rowMeans(.))

# sample standard deviation
lr$row_std = rowSds(as.matrix(lr[,c(1,2,3,4,5)]))

# Data in Floating Seconds for Par 2-Core
par2 <- data.frame(
  core_2_r1 = c(2.30989,9.25477,37.0433,149.88),
  core_2_r2 = c(2.29359,9.25265,37.5051,149.578),
  core_2_r3 = c(2.30627,9.22105,37.0138,149.937),
  core_2_r4 = c(2.31366,9.44116,37.6293,150.31),
  core_2_r5 = c(2.303,9.32449,37.3222,150.569)
)

# Create new col mean_all which averages of all rows
par2 <- par2 %>% mutate(mean_all = rowMeans(.))

# sample standard deviation
par2$row_std = rowSds(as.matrix(par2[,c(1,2,3,4,5)]))

# Data in Floating Seconds for Par 4-Core

par4 <- data.frame(
  core_4_r1 = c(1.65346,6.6297,27.0516,106.324),
  core_4_r2 = c(1.59497,6.66412,26.6631,107.962),
  core_4_r3 = c(1.64269,6.67385,26.8856,107.683),
  core_4_r4 = c(1.67722,6.63111,26.695,107.126),
  core_4_r5 = c(1.63818,6.5835,26.7065,107.846)
)

par4 <- par4 %>% mutate(mean_all = rowMeans(.))

par4$row_std = rowSds(as.matrix(par4[,c(1,2,3,4,5)]))

# Data in Floating Seconds for Par 6-Core

par6 <- data.frame(
  core_6_r1 = c(1.69978,7.00345,28.7298,113.901),
  core_6_r2 = c(1.73172,6.97685,28.5395,113.903),
  core_6_r3 = c(1.68734,7.07393,28.4587,113.56),
  core_6_r4 = c(1.74008,7.00473,28.8943,113.141),
  core_6_r5 = c(1.68514,7.07141,28.5536,114.143)
)

par6 <- par6 %>% mutate(mean_all = rowMeans(.))

par6$row_std = rowSds(as.matrix(par6[,c(1,2,3,4,5)]))

# Data in Floating Seconds for Par 8-Core

par8 <- data.frame(
  core_8_r1 = c(1.7425,7.11349,28.7797,115.818),
  core_8_r2 = c(1.76742,7.04906,29.0046,115.215),
  core_8_r3 = c(1.7648,7.10523,29.3025,116.731),
  core_8_r4 = c(1.75935,7.09542,28.4501,115.961),
  core_8_r5 = c(1.77764,7.03874,28.7157,114.572)
)

# Create new col mean_all which averages of all rows
par8 <- par8 %>% mutate(mean_all = rowMeans(.))

par8$row_std = rowSds(as.matrix(par8[,c(1,2,3,4,5)]))

FinalDataFrame <- data.frame("Serial" = lr$mean_all,
                             "2 Threads" = par2$mean_all, 
                             "4 Threads" = par4$mean_all,
                             "6 Threads" = par6$mean_all,
                             "8 Threads" = par8$mean_all)

# Sadly still have to rename these...
colnames(FinalDataFrame)[1] <- "Serial"
colnames(FinalDataFrame)[2] <- "2 Threads"
colnames(FinalDataFrame)[3] <- "4 Threads"
colnames(FinalDataFrame)[4] <- "6 Threads"
colnames(FinalDataFrame)[5] <- "8 Threads"

FinalDataFrame <- melt(FinalDataFrame)
FinalDataFrame$rowid <- 1:4
FinalDataFrame$xaxis <- c(64, 128, 256, 512)

colnames(FinalDataFrame)[1] <- "Legend"

tmp <- ggplot()

tmp + geom_line(data=FinalDataFrame, aes(x=xaxis, y=value, group=Legend, color=Legend, linetype=Legend)) + geom_point(data=FinalDataFrame, size=0.75, stroke = 1, shape = 16, aes(x = xaxis, y = value, group=Legend, color=Legend))  + xlab("Input Image Size (Height x Width)") + ylab("Time Taken (Seconds)") + theme(legend.position = "bottom", text = element_text(size = 15)) + ggtitle("SYCL Sobel Edge Detection")

