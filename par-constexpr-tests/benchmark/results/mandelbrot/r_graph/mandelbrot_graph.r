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

# need to fix the axises
#XAxis = c(25, 50, 75, 100, 125)

lr <- data.frame(
  lin_r1 = c(3.65399,14.7067,33.0163,58.6812,91.4158),
  lin_r2 = c(3.72927,14.7187,33.1423,58.7949,91.961),
  lin_r3 = c(3.69895,14.871,33.7974,58.3238,93.6657),
  lin_r4 = c(3.65381,14.6626,33.0978,59.3499,92.1634),
  lin_r5 = c(3.6326,14.8296,32.9294,59.0666,90.5347)
)

# Create new col mean_all which averages of all rows
lr <- lr %>% mutate(mean_all = rowMeans(.))

lr$row_std = rowSds(as.matrix(lr[,c(1,2,3,4,5)]))

par2 <- data.frame(
  core2_r1 = c(2.8727,10.9373,24.6032,43.8578,70.7875),
  core2_r2 = c(2.83861,10.8072,25.2404,43.9454,67.7859),
  core2_r3 = c(2.81648,10.932,24.8967,43.3169,67.7473),
  core2_r4 = c(2.84475,10.9565,24.8788,43.2556,68.0527),
  core2_r5 = c(2.88626,10.7908,24.7576,43.2693,68.6971)
)

# Create new col mean_all which averages of all rows
par2 <- par2 %>% mutate(mean_all = rowMeans(.))

# sample standard deviation
par2$row_std = rowSds(as.matrix(par2[,c(1,2,3,4,5)]))

par4 <- data.frame(
  core4_r1 = c(1.73065,6.9127,15.9813,30.0727,41.8114),
  core4_r2 = c(1.52569,6.24521,14.1228,26.5246,41.5961),
  core4_r3 = c(1.5565,6.33876,14.2608,26.8155,41.3828),
  core4_r4 = c(1.49803,6.2845,14.18,26.78,41.5002),
  core4_r5 = c(1.52407,6.38962,14.2176,26.4818,41.4518)
)

# Create new col mean_all which averages of all rows
par4 <- par4 %>% mutate(mean_all = rowMeans(.))

par4$row_std = rowSds(as.matrix(par4[,c(1,2,3,4,5)]))

par6 <- data.frame(
  core6_r1 = c(1.20494,5.19069,11.9749,21.382,32.3077),
  core6_r2 = c(1.20688,5.38059,12.1035,20.627,32.6853),
  core6_r3 = c(1.1476,5.31067,12.0111,21.2648,32.4742),
  core6_r4 = c(1.32832,4.96638,11.9125,21.5361,33.4874),
  core6_r5 = c(1.37003,5.1673,12.5218,21.2568,32.8203)
)

# Create new col mean_all which averages of all rows
par6 <- par6 %>% mutate(mean_all = rowMeans(.))

par6$row_std = rowSds(as.matrix(par6[,c(1,2,3,4,5)]))

par8 <- data.frame(
  core8_r1 = c(1.1024,4.71202,10.8564,18.7941,30.1474),
  core8_r2 = c(1.09578,4.62396,9.77974,19.3026,28.8047),
  core8_r3 = c(1.17885,4.41912,9.99082,18.6709,30.0265),
  core8_r4 = c(1.17122,4.64414,10.5159,18.1512,29.7932),
  core8_r5 = c(1.1846,4.55835,11.1016,18.5705,29.7703)
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
FinalDataFrame$rowid <- 1:5
FinalDataFrame$xaxis <- c(25, 50, 75, 100, 125)

colnames(FinalDataFrame)[1] <- "Legend"

tmp <- ggplot()

tmp + geom_line(data=FinalDataFrame, aes(x=xaxis, y=value, group=Legend, color=Legend, linetype=Legend)) + geom_point(data=FinalDataFrame, size=0.75, stroke = 1, shape = 16, aes(x = xaxis, y = value, group=Legend, color=Legend))  + xlab("Image Output Size (Height x Width)") + ylab("Time Taken (Seconds)") + theme(legend.position = "bottom", text = element_text(size = 15)) + ggtitle("Mandelbrot")

