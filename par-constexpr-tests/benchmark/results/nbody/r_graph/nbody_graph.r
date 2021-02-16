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

nbodyXAxis = c(10000, 20000, 30000, 40000, 50000)

lr <- data.frame(
  lin_r1 = c(24253,48492,72625,95658,119123),
  lin_r2 = c(23406,47220,70496,94345,117145),
  lin_r3 = c(23420,47291,69965,93969,119742),
  lin_r4 = c(23422,47231,69889,93446,121073),
  lin_r5 = c(25381,49265,74569,101234,124207)
)

# Create new col mean_all which averages of all rows
lr <- lr %>% mutate(mean_all = rowMeans(.))

# sample standard deviation
lr$row_std = rowSds(as.matrix(lr[,c(1,2,3,4,5)]))

FinalLinearData <- data.frame("avg" = lr$mean_all, 
                              "sd" = lr$row_std, 
                              "nbody_x_axis" = nbodyXAxis)

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
par_2_r1 = c(20577,40783,60748,86204,102642),
par_2_r2 = c(19654,39623,59063,79053,98706),
par_2_r3 = c(19673,39509,59108,78943,98286),
par_2_r4 = c(20015,39126,59644,79197,99055),
par_2_r5 = c(20764,41241,63406,82441,102736)
)

# Create new col mean_all which averages of all rows
par2 <- par2 %>% mutate(mean_all = rowMeans(.))

# sample standard deviation
par2$row_std = rowSds(as.matrix(par2[,c(1,2,3,4,5)]))

FinalPar2Data <- data.frame("avg" = par2$mean_all, 
                            "sd" = par2$row_std, 
                            "nbody_x_axis" = nbodyXAxis)

print(FinalPar2Data)

## Data in Miliseconds for Par 4-Core

par4 <- data.frame(
par_4_r1 = c(20491,40957,61541,84072,102177),
par_4_r2 = c(20259,40697,61131,81308,101593),
par_4_r3 = c(20937,41828,61857,81985,103152),
par_4_r4 = c(20402,40350,60681,81144,101260),
par_4_r5 = c(21136,41921,62936,84473,105803)
)

par4 <- par4 %>% mutate(mean_all = rowMeans(.))

par4$row_std = rowSds(as.matrix(par4[,c(1,2,3,4,5)]))

FinalPar4Data <- data.frame("avg" = par4$mean_all, 
                            "sd" = par4$row_std, 
                            "nbody_x_axis" = nbodyXAxis)

print(FinalPar4Data)

# Version with standard deviation as error bars
#ggplot() + geom_line(data=FinalLinearData, aes(x=nbody_x_axis, y=avg, colour="Serial")) + geom_errorbar(data=FinalLinearData, aes(x=nbody_x_axis, ymin=avg-sd, ymax=avg+sd)) + geom_line(data=FinalPar2Data, aes(x=nbody_x_axis, y=avg, colour="2-Core Parallelism")) + geom_errorbar(data=FinalPar2Data, aes(x=nbody_x_axis, ymin=avg-sd, ymax=avg+sd)) + geom_line(data=FinalPar4Data, aes(x=nbody_x_axis, y=avg, colour="4-Core Parallelism")) +  geom_errorbar(data=FinalPar4Data, aes(nbody_x_axis, ymin=avg-sd, ymax=avg+sd)) +
#ggtitle("Blackscholes Benchmark") + xlab("Input Size") + ylab("Time Taken (milliseconds)") +
#guides(colour=guide_legend(title="Legend")) + theme(legend.position = "bottom")

# version without standard deviation as error bars
ggplot() + geom_line(data=FinalLinearData, aes(x=nbody_x_axis, y=avg, colour="Serial")) + geom_point(data=FinalLinearData, size=0.75, stroke = 1, shape = 16, aes(x = nbody_x_axis, y = avg)) + geom_line(data=FinalPar2Data, aes(x=nbody_x_axis, y=avg, colour="2-Core Parallelism")) + geom_point(data=FinalPar2Data, size=0.75, stroke = 1, shape = 16, aes(x=nbody_x_axis, y=avg)) + geom_line(data=FinalPar4Data, aes(x=nbody_x_axis, y=avg, colour="4-Core Parallelism")) + geom_point(data=FinalPar4Data, size=0.75, stroke = 1, shape = 16, aes(x=nbody_x_axis, y=avg)) + ggtitle("N-Body Benchmark") + xlab("Input Size") + ylab("Time Taken (milliseconds)") + guides(colour=guide_legend(title="Legend")) + theme(legend.position = "bottom")

#tmp + scale_x_continuous(breaks=c(0, 6400, 12800, 19200, 25600, 32000, 38400, 44800, 51200, 57600, 64000)) + scale_y_continuous(breaks = c(0, 3200, 6400, 9600, 12800, 16000, 19200, 22400, 25600, 28800, 32000))

#scale_y_continuous(breaks = scales::pretty_breaks(n = 10))


