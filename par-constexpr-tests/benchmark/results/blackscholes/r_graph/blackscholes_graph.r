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

blackscholesXAxis = c(4, 16, 1000, 4000, 16000, 64000)

lr <- data.frame(
  lin_r1 = c(1, 7, 491, 1992, 7785, 31319),
  lin_r2 = c(2, 8, 489, 1954, 7808, 31552),
  lin_r3 = c(2, 7, 491, 1941, 7772, 31203),
  lin_r4 = c(1, 7, 491, 1937, 7860, 30988),
  lin_r5 = c(1, 7, 486, 1957, 7931, 30959)
)

# Create new col mean_all which averages of all rows
lr <- lr %>% mutate(mean_all = rowMeans(.))

# sample standard deviation
lr$row_std = rowSds(as.matrix(lr[,c(1,2,3,4,5)]))

FinalLinearData <- data.frame("avg" = lr$mean_all, 
                              "sd" = lr$row_std, 
                              "blackscholes_x_axis" = blackscholesXAxis)

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
par_2_r1 = c(1,4,262,1051,4145,16546),
par_2_r2 = c(1,4,258,1040,4147,16824),
par_2_r3 = c(1,4,258,1046,4175,16570),
par_2_r4 = c(1,4,261,1042,4142,16594),
par_2_r5 = c(1,4,256,1023,4106,16548)
)

# Create new col mean_all which averages of all rows
par2 <- par2 %>% mutate(mean_all = rowMeans(.))

# sample standard deviation
par2$row_std = rowSds(as.matrix(par2[,c(1,2,3,4,5)]))

FinalPar2Data <- data.frame("avg" = par2$mean_all, 
                            "sd" = par2$row_std, 
                            "blackscholes_x_axis" = blackscholesXAxis)

print(FinalPar2Data)

## Data in Miliseconds for Par 4-Core

par4 <- data.frame(
par_4_r1 = c(1,2,151,600,2420,9673),
par_4_r2 = c(1,4,179,605,2409,9733),
par_4_r3 = c(1,4,149,611,2414,9525),
par_4_r4 = c(1,4,153,602,2393,9955),
par_4_r5 = c(1,2,152,605,2408,9522)
)

par4 <- par4 %>% mutate(mean_all = rowMeans(.))

par4$row_std = rowSds(as.matrix(par4[,c(1,2,3,4,5)]))

FinalPar4Data <- data.frame("avg" = par4$mean_all, 
                            "sd" = par4$row_std, 
                            "blackscholes_x_axis" = blackscholesXAxis)

print(FinalPar4Data)

# Version with standard deviation as error bars
#ggplot() + geom_line(data=FinalLinearData, aes(x=blackscholes_x_axis, y=avg, colour="Serial")) + geom_errorbar(data=FinalLinearData, aes(x=blackscholes_x_axis, ymin=avg-sd, ymax=avg+sd)) + geom_line(data=FinalPar2Data, aes(x=blackscholes_x_axis, y=avg, colour="2-Core Parallelism")) + geom_errorbar(data=FinalPar2Data, aes(x=blackscholes_x_axis, ymin=avg-sd, ymax=avg+sd)) + geom_line(data=FinalPar4Data, aes(x=blackscholes_x_axis, y=avg, colour="4-Core Parallelism")) +  geom_errorbar(data=FinalPar4Data, aes(blackscholes_x_axis, ymin=avg-sd, ymax=avg+sd)) +
#ggtitle("Blackscholes Benchmark") + xlab("Input Size") + ylab("Time Taken (milliseconds)") +
#guides(colour=guide_legend(title="Legend")) + theme(legend.position = "bottom")

# version without standard deviation as error bars
tmp <- ggplot() + geom_line(data=FinalLinearData, aes(x=blackscholes_x_axis, y=avg, colour="Serial")) + geom_point(data=FinalLinearData, size=0.75, stroke = 1, shape = 16, aes(x = blackscholes_x_axis, y = avg)) + geom_line(data=FinalPar2Data, aes(x=blackscholes_x_axis, y=avg, colour="2-Core Parallelism")) + geom_point(data=FinalPar2Data, size=0.75, stroke = 1, shape = 16, aes(x=blackscholes_x_axis, y=avg)) + geom_line(data=FinalPar4Data, aes(x=blackscholes_x_axis, y=avg, colour="4-Core Parallelism")) + geom_point(data=FinalPar4Data, size=0.75, stroke = 1, shape = 16, aes(x=blackscholes_x_axis, y=avg)) + ggtitle("Blackscholes Benchmark") + xlab("Input Size") + ylab("Time Taken (milliseconds)") + guides(colour=guide_legend(title="Legend")) + theme(legend.position = "bottom")

tmp + scale_x_continuous(trans="log2", breaks = scales::pretty_breaks(n = 10)) + scale_y_continuous(trans="log2", breaks = scales::pretty_breaks(n = 10))

#scale_y_continuous(breaks = scales::pretty_breaks(n = 10))


