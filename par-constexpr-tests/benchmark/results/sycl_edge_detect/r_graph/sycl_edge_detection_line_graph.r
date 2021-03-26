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

FinalLinearData <- data.frame("avg" = lr$mean_all, 
                              "sd" = lr$row_std, 
                              "x_axis" = XAxis)

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

FinalPar2Data <- data.frame("avg" = par2$mean_all, 
                            "sd" = par2$row_std, 
                            "x_axis" = XAxis)

print(FinalPar2Data)

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

FinalPar4Data <- data.frame("avg" = par4$mean_all, 
                            "sd" = par4$row_std, 
                            "x_axis" = XAxis)

print(FinalPar4Data)

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

FinalPar6Data <- data.frame("avg" = par6$mean_all, 
                            "sd" = par6$row_std, 
                            "x_axis" = XAxis)

print(FinalPar6Data)

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

FinalPar8Data <- data.frame("avg" = par6$mean_all, 
                            "sd" = par6$row_std, 
                            "x_axis" = XAxis)
                            
print(FinalPar8Data)

             

memory_box = c("114.74 kB", "213.05 kB", "606.27 kB", "2179.13 kB")
# not exactly the same presumably because the path through SYCL is slightly 
# modified based on lin or par
steps_lin = c("3209854 Steps", "12832218 Steps", "51300223 Steps", "205129657 Steps")
steps_par = c("3209804 Steps", "12832168 Steps", "51300173 Steps", "205129607 Steps")

# log with text
#tmp <- ggplot() + geom_line(data=FinalLinearData, aes(x=x_axis, y=avg, colour="Serial")) + geom_point(data=FinalLinearData, size=0.75, stroke = 1, shape = 16, aes(x = x_axis, y = avg)) + geom_text(aes(x=XAxis, y=FinalLinearData$avg, label=memory_box), nudge_x=-0.20, nudge_y=0.05, size=2.5, hjust=0, vjust=0) + geom_text(aes(x=XAxis, y=FinalLinearData$avg, label=steps_lin), nudge_x=-0.20, nudge_y=0.15, size=2.5, hjust=0, vjust=0) + geom_line(data=FinalPar2Data, aes(x=x_axis, y=avg, colour="2-Core")) + geom_point(data=FinalPar2Data, size=0.75, stroke = 1, shape = 16, aes(x=x_axis, y=avg)) + geom_text(aes(x=XAxis, y=FinalPar2Data$avg, label=steps_par), nudge_x=-0.20, nudge_y=0.05, size=2.5, hjust=0, vjust=0) + geom_line(data=FinalPar4Data, aes(x=x_axis, y=avg, colour="4-Core")) + geom_point(data=FinalPar4Data, size=0.75, stroke = 1, shape = 16, aes(x=x_axis, y=avg)) +
#geom_line(data=FinalPar6Data, aes(x=x_axis, y=avg, colour="6-Core")) + geom_point(data=FinalPar6Data, size=0.75, stroke = 1, shape = 16, aes(x=x_axis, y=avg)) +
#geom_line(data=FinalPar8Data, aes(x=x_axis, y=avg, colour="8-Core")) + geom_point(data=FinalPar8Data, size=0.75, stroke = 1, shape = 16, aes(x=x_axis, y=avg)) + ggtitle("SYCL Sobel Edge Detection") + xlab("Input Image Size (Height x Width)") + ylab("Time Taken (Seconds)") + guides(colour=guide_legend(title="Legend")) + theme(legend.position = "bottom")

tmp <- ggplot() + geom_line(data=FinalLinearData, aes(x=x_axis, y=avg, colour="Serial")) + geom_point(data=FinalLinearData, size=0.75, stroke = 1, shape = 16, aes(x = x_axis, y = avg)) + geom_line(data=FinalPar2Data, aes(x=x_axis, y=avg, colour="2-Core")) + geom_point(data=FinalPar2Data, size=0.75, stroke = 1, shape = 16, aes(x=x_axis, y=avg)) + geom_line(data=FinalPar4Data, aes(x=x_axis, y=avg, colour="4-Core")) + geom_point(data=FinalPar4Data, size=0.75, stroke = 1, shape = 16, aes(x=x_axis, y=avg)) +
geom_line(data=FinalPar6Data, aes(x=x_axis, y=avg, colour="6-Core")) + geom_point(data=FinalPar6Data, size=0.75, stroke = 1, shape = 16, aes(x=x_axis, y=avg)) +
geom_line(data=FinalPar8Data, aes(x=x_axis, y=avg, colour="8-Core")) + geom_point(data=FinalPar8Data, size=0.75, stroke = 1, shape = 16, aes(x=x_axis, y=avg)) + ggtitle("SYCL Sobel Edge Detection") + xlab("Input Image Size (Height x Width)") + ylab("Time Taken (Seconds)") + guides(colour=guide_legend(title="Legend")) + theme(legend.position = "bottom")


#tmp <- ggplot() + geom_line(data=FinalLinearData, aes(x=x_axis, y=avg, colour="Serial")) + geom_point(data=FinalLinearData, size=0.75, stroke = 1, shape = 16, aes(x = x_axis, y = avg)) + geom_text(aes(x=XAxis, y=FinalLinearData$avg, label=memory_box), nudge_x=-0.20, nudge_y=0.05, size=2.5, hjust=0, vjust=0) + geom_text(aes(x=XAxis, y=FinalLinearData$avg, label=steps_lin), nudge_x=-0.20, nudge_y=0.15, size=2.5, hjust=0, vjust=0) + geom_line(data=FinalPar2Data, aes(x=x_axis, y=avg, colour="2-Core")) + geom_point(data=FinalPar2Data, size=0.75, stroke = 1, shape = 16, aes(x=x_axis, y=avg)) + geom_text(aes(x=XAxis, y=FinalPar2Data$avg, label=memory_box), nudge_x=-0.20, nudge_y=0.05, size=2.5, hjust=0, vjust=0) + geom_text(aes(x=XAxis, y=FinalPar2Data$avg, label=steps_par), nudge_x=-0.20, nudge_y=0.15, size=2.5, hjust=0, vjust=0) + geom_line(data=FinalPar4Data, aes(x=x_axis, y=avg, colour="4-Core")) + geom_point(data=FinalPar4Data, size=0.75, stroke = 1, shape = 16, aes(x=x_axis, y=avg)) + geom_text(aes(x=XAxis, y=FinalPar4Data$avg, label=memory_box), nudge_x=-0.07, nudge_y=-0.15, size=2.5, hjust=0, vjust=0) +
#geom_line(data=FinalPar6Data, aes(x=x_axis, y=avg, colour="6-Core")) + geom_point(data=FinalPar6Data, size=0.75, stroke = 1, shape = 16, aes(x=x_axis, y=avg)) + geom_text(aes(x=XAxis, y=FinalPar6Data$avg, label=memory_box), nudge_x=-0.07, nudge_y=0.10, size=2.5, hjust=0, vjust=0) +
#geom_line(data=FinalPar8Data, aes(x=x_axis, y=avg, colour="8-Core")) + geom_point(data=FinalPar8Data, size=0.75, stroke = 1, shape = 16, aes(x=x_axis, y=avg)) + geom_text(aes(x=XAxis, y=FinalPar8Data$avg, label=memory_box), nudge_x=-0.20, nudge_y=0.05, size=2.5, hjust=0, vjust=0) + geom_text(aes(x=XAxis, y=FinalPar2Data$avg, label=steps_par), nudge_x=-0.20, nudge_y=0.15, size=2.5, hjust=0, vjust=0) + ggtitle("SYCL Sobel Edge Detection") + xlab("Input Image Size (Height x Width)") + ylab("Time Taken (Seconds)") + guides(colour=guide_legend(title="Legend")) + theme(legend.position = "bottom")

# Log scaling
#tmp + scale_x_continuous(trans="log", breaks = scales::pretty_breaks(n = 18)) + scale_y_continuous(trans="log", breaks = scales::pretty_breaks(n = 8))

 
# Linear scaling
tmp + scale_x_continuous(trans="identity", breaks = scales::pretty_breaks(n = 12)) + scale_y_continuous(trans="identity", breaks = scales::pretty_breaks(n = 12))

#scale_y_continuous(breaks = scales::pretty_breaks(n = 10))


