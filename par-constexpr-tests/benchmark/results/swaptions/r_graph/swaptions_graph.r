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

XAxis = c(2, 4, 6, 8, 10)

lr <- data.frame(
  lin_r1 = c(36.4152,71.8454,108.734,144.024,182.561),
  lin_r2 = c(36.1008,72.6915,109.077,145.138,182.893),
  lin_r3 = c(36.5019,72.3433,110.67,143.799,179.786),
  lin_r4 = c(35.925,72.4256,108.909,146.808,183.697),
  lin_r5 = c(36.0609,71.7768,111.416,145.649,183.477)
)

# Create new col mean_all which averages of all rows
lr <- lr %>% mutate(mean_all = rowMeans(.))

lr$row_std = rowSds(as.matrix(lr[,c(1,2,3,4,5)]))

FinalLinearData <- data.frame("avg" = lr$mean_all, 
                              "sd" = lr$row_std, 
                              "x_axis" = XAxis)

print(FinalLinearData)

par2 <- data.frame(
  core2_r1 = c(19.9863,39.4198,58.7356,78.1842,98.8265),
  core2_r2 = c(19.5875,39.6269,58.6702,78.7494,98.0425),
  core2_r3 = c(20.0183,39.2055,59.0139,78.0843,97.6818),
  core2_r4 = c(19.4113,39.2301,59.1405,78.4417,98.8268),
  core2_r5 = c(19.6145,40.0059,59.2382,80.7145,98.4647)
)

# Create new col mean_all which averages of all rows
par2 <- par2 %>% mutate(mean_all = rowMeans(.))

# sample standard deviation
par2$row_std = rowSds(as.matrix(par2[,c(1,2,3,4,5)]))

FinalPar2Data <- data.frame("avg" = par2$mean_all, 
                            "sd" = par2$row_std, 
                            "x_axis" = XAxis)

print(FinalPar2Data)

par4 <- data.frame(
  core4_r1 = c(38.5619,20.3988,57.8331,41.6446,78.8191),
  core4_r2 = c(38.3905,20.4098,58.7538,40.8762,78.7647),
  core4_r3 = c(38.0282,20.7468,58.1764,40.9385,80.2169),
  core4_r4 = c(38.2935,20.7573,58.1379,40.8935,79.9749),
  core4_r5 = c(38.2441,20.6689,58.6656,40.8001,78.0867)
)

# Create new col mean_all which averages of all rows
par4 <- par4 %>% mutate(mean_all = rowMeans(.))

par4$row_std = rowSds(as.matrix(par4[,c(1,2,3,4,5)]))

FinalPar4Data <- data.frame("avg" = par4$mean_all, 
                            "sd" = par4$row_std, 
                            "x_axis" = XAxis)

print(FinalPar4Data)

par6 <- data.frame(
  core6_r1 = c(38.6794,75.659,32.502,69.7372,105.753),
  core6_r2 = c(38.3009,76.071,32.2634,65.8162,105.007),
  core6_r3 = c(37.7627,75.823,32.1452,66.4259,107.408),
  core6_r4 = c(38.3859,77.3252,31.1087,67.2389,105.283),
  core6_r5 = c(38.3497,76.5526,31.2588,66.4626,105.401)
)

# Create new col mean_all which averages of all rows
par6 <- par6 %>% mutate(mean_all = rowMeans(.))

par6$row_std = rowSds(as.matrix(par6[,c(1,2,3,4,5)]))

FinalPar6Data <- data.frame("avg" = par6$mean_all, 
                            "sd" = par6$row_std, 
                            "x_axis" = XAxis)

print(FinalPar6Data)

par8 <- data.frame(
  core8_r1 = c(38.8939,76.3578,114.355,40.8769,78.3154),
  core8_r2 = c(38.4185,76.7113,113.776,41.2503,78.9505),
  core8_r3 = c(38.0306,77.3318,113.918,41.1574,78.837),
  core8_r4 = c(38.3457,76.7528,116.36,40.8852,77.8818),
  core8_r5 = c(37.9443,75.8153,112.86,41.2746,79.121)
)

# Create new col mean_all which averages of all rows
par8 <- par8 %>% mutate(mean_all = rowMeans(.))

par8$row_std = rowSds(as.matrix(par8[,c(1,2,3,4,5)]))

FinalPar8Data <- data.frame("avg" = par6$mean_all, 
                            "sd" = par6$row_std, 
                            "x_axis" = XAxis)

print(FinalPar8Data)

tmp <- ggplot() + geom_line(data=FinalLinearData, aes(x=x_axis, y=avg, colour="Serial")) + geom_point(data=FinalLinearData, size=0.75, stroke = 1, shape = 16, aes(x = x_axis, y = avg)) + geom_line(data=FinalPar2Data, aes(x=x_axis, y=avg, colour="2-Core")) + geom_point(data=FinalPar2Data, size=0.75, stroke = 1, shape = 16, aes(x=x_axis, y=avg)) + geom_line(data=FinalPar4Data, aes(x=x_axis, y=avg, colour="4-Core")) + geom_point(data=FinalPar4Data, size=0.75, stroke = 1, shape = 16, aes(x=x_axis, y=avg)) +
geom_line(data=FinalPar6Data, aes(x=x_axis, y=avg, colour="6-Core")) + geom_point(data=FinalPar6Data, size=0.75, stroke = 1, shape = 16, aes(x=x_axis, y=avg)) +
geom_line(data=FinalPar8Data, aes(x=x_axis, y=avg, colour="8-Core")) + geom_point(data=FinalPar8Data, size=0.75, stroke = 1, shape = 16, aes(x=x_axis, y=avg)) + ggtitle("Swaptions") + xlab("Number of Swaptions") + ylab("Time Taken (Seconds)") + guides(colour=guide_legend(title="Legend")) + theme(legend.position = "bottom")

tmp + scale_x_continuous(trans="log", breaks = scales::pretty_breaks(n = 12)) + scale_y_continuous(trans="log", breaks = scales::pretty_breaks(n = 8))

# Linear scaling
#tmp + scale_x_continuous(trans="identity", breaks = scales::pretty_breaks(n = 6)) + scale_y_continuous(trans="identity", breaks = scales::pretty_breaks(n = 12))
