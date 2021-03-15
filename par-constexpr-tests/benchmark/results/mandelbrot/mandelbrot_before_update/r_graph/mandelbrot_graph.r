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

# Data in Miliseconds for Linear

# 128 iterations
mandelbrotXAxis = c(25, 50, 75, 100, 125)

lr <- data.frame(
  lin_r1 = c(3874,15781,35290,61395,97856),
  lin_r2 = c(3904,16128,35578,62085,96417),
  lin_r3 = c(3927,15404,34933,62998,96821),
  lin_r4 = c(3897,15257,34624,61550,95960),
  lin_r5 = c(3902,15697,34518,61563,98938)
)

# Create new col mean_all which averages of all rows
lr <- lr %>% mutate(mean_all = rowMeans(.))

# sample standard deviation
lr$row_std = rowSds(as.matrix(lr[,c(1,2,3,4,5)]))

FinalLinearData <- data.frame("avg" = lr$mean_all, 
                              "sd" = lr$row_std, 
                              "mandelbrot_x_axis" = mandelbrotXAxis)

#print(FinalLinearData)

#print(NewFrame)

#dfnew4 &lt;- lr[,c("mean_all")]

#ggplot(data=df, aes(x=dose, y=len, group=1)) +
#  geom_line()+
#  geom_point()
## Change the line type
#ggplot(data=df, aes(x=dose, y=len, group=1)) +
#  geom_line(linetype = "dashed")+
#  geom_point()
## Change the color
#ggplot(data=df, aes(x=dose, y=len, group=1)) +
#  geom_line(color="red")+
#  geom_point()

# Data in Miliseconds for Par 2-Core
par2 <- data.frame(
par_2_r1 = c(3039,11666,26612,46436,70360),
par_2_r2 = c(2966,11337,26184,46211,72799),
par_2_r3 = c(2955,11543,25934,45982,71889),
par_2_r4 = c(2928,11274,26081,45211,72367),
par_2_r5 = c(2946,11576,25708,45817,72457)
)

# Create new col mean_all which averages of all rows
par2 <- par2 %>% mutate(mean_all = rowMeans(.))

# sample standard deviation
par2$row_std = rowSds(as.matrix(par2[,c(1,2,3,4,5)]))

FinalPar2Data <- data.frame("avg" = par2$mean_all, 
                            "sd" = par2$row_std, 
                            "mandelbrot_x_axis" = mandelbrotXAxis)

print(FinalPar2Data)

## Data in Miliseconds for Par 4-Core

par4 <- data.frame(
par_4_r1 = c(1630,6598,15159,28997,44786),
par_4_r2 = c(1732,6719,14860,27896,43341),
par_4_r3 = c(1583,6539,15437,28271,44981),
par_4_r4 = c(1617,6858,15482,28051,45575),
par_4_r5 = c(1657,6631,15036,27762,44333)
)

par4 <- par4 %>% mutate(mean_all = rowMeans(.))

par4$row_std = rowSds(as.matrix(par4[,c(1,2,3,4,5)]))

FinalPar4Data <- data.frame("avg" = par4$mean_all, 
                            "sd" = par4$row_std, 
                            "mandelbrot_x_axis" = mandelbrotXAxis)

print(FinalPar4Data)

# Version with standard deviation as error bars
#ggplot() + geom_line(data=FinalLinearData, aes(x=mandelbrot_x_axis, y=avg, colour="Serial")) + geom_errorbar(data=FinalLinearData, aes(x=mandelbrot_x_axis, ymin=avg-sd, ymax=avg+sd)) + geom_line(data=FinalPar2Data, aes(x=mandelbrot_x_axis, y=avg, colour="2-Core Parallelism")) + geom_errorbar(data=FinalPar2Data, aes(x=mandelbrot_x_axis, ymin=avg-sd, ymax=avg+sd)) + geom_line(data=FinalPar4Data, aes(x=mandelbrot_x_axis, y=avg, colour="4-Core Parallelism")) +  geom_errorbar(data=FinalPar4Data, aes(mandelbrot_x_axis, ymin=avg-sd, ymax=avg+sd)) +
#ggtitle("Blackscholes Benchmark") + xlab("Input Size") + ylab("Time Taken (milliseconds)") +
#guides(colour=guide_legend(title="Legend")) + theme(legend.position = "bottom")

# version without standard deviation as error bars
ggplot() + geom_line(data=FinalLinearData, aes(x=mandelbrot_x_axis, y=avg, colour="Serial")) + geom_point(data=FinalLinearData, size=0.75, stroke = 1, shape = 16, aes(x = mandelbrot_x_axis, y = avg)) + geom_line(data=FinalPar2Data, aes(x=mandelbrot_x_axis, y=avg, colour="2-Core Parallelism")) + geom_point(data=FinalPar2Data, size=0.75, stroke = 1, shape = 16, aes(x=mandelbrot_x_axis, y=avg)) + geom_line(data=FinalPar4Data, aes(x=mandelbrot_x_axis, y=avg, colour="4-Core Parallelism")) + geom_point(data=FinalPar4Data, size=0.75, stroke = 1, shape = 16, aes(x=mandelbrot_x_axis, y=avg)) + ggtitle("Mandelbrot Benchmark") + xlab("Image Width x Height") + ylab("Time Taken (milliseconds)") + guides(colour=guide_legend(title="Legend")) + theme(legend.position = "bottom")

#tmp + scale_x_continuous(trans='log2') +
#      scale_y_continuous(trans='log2')

#tmp + scale_x_continuous(breaks=c(0, 6400, 12800, 19200, 25600, 32000, 38400, 44800, 51200, 57600, 64000)) + scale_y_continuous(breaks = c(0, 3200, 6400, 9600, 12800, 16000, 19200, 22400, 25600, 28800, 32000))

#scale_y_continuous(breaks = scales::pretty_breaks(n = 10))


