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
XAxis = c(10000, 20000, 30000, 40000, 50000)

lr <- data.frame(
  lin_r1 = c(22.104,44.3425,67.4381,89.1488,111.311),
  lin_r2 = c(22.1712,44.351,67.1728,88.0206,112.338),
  lin_r3 = c(22.3026,45.8407,67.7193,88.6728,111.14),
  lin_r4 = c(22.4543,44.2362,66.9709,88.7636,111.163),
  lin_r5 = c(22.195,44.9799,66.4576,88.8831,109.667)
)

# Create new col mean_all which averages of all rows
lr <- lr %>% mutate(mean_all = rowMeans(.))

lr$row_std = rowSds(as.matrix(lr[,c(1,2,3,4,5)]))

par2 <- data.frame(
  core2_r1 = c(19.0724,37.6041,56.7582,75.3986,94.7843),
  core2_r2 = c(18.9094,37.6561,56.6469,75.947,94.696),
  core2_r3 = c(18.9543,37.6366,56.6537,76.6766,93.5292),
  core2_r4 = c(18.9947,37.8857,56.5124,74.8567,94.7596),
  core2_r5 = c(18.7732,37.7086,57.7323,75.3412,94.6945)
)

# Create new col mean_all which averages of all rows
par2 <- par2 %>% mutate(mean_all = rowMeans(.))

# sample standard deviation
par2$row_std = rowSds(as.matrix(par2[,c(1,2,3,4,5)]))

par4 <- data.frame(
  core4_r1 = c(19.8834,39.9827,59.6749,78.7245,98.9808),
  core4_r2 = c(19.7436,39.4368,59.7443,78.5579,99.1633),
  core4_r3 = c(19.8101,39.6821,58.957,79.9542,98.4094),
  core4_r4 = c(19.7451,39.7324,58.9813,78.3262,99.9899),
  core4_r5 = c(19.7011,39.7423,59.9859,79.5279,99.1211)
)

# Create new col mean_all which averages of all rows
par4 <- par4 %>% mutate(mean_all = rowMeans(.))

# Create sd
par4$row_std = rowSds(as.matrix(par4[,c(1,2,3,4,5)]))

par6 <- data.frame(
  core6_r1 = c(59.5751,108.392,169.479,231.085,289.711),
  core6_r2 = c(56.2796,113.325,165.243,233.169,292.81),
  core6_r3 = c(58.1981,110.575,172.724,207.462,239.779),
  core6_r4 = c(57.34,117.844,170.348,225.852,288.139),
  core6_r5 = c(57.7241,115.425,167.203,231.581,290.092)
)

# Create new col mean_all which averages of all rows
par6 <- par6 %>% mutate(mean_all = rowMeans(.))

# Create sd
par6$row_std = rowSds(as.matrix(par6[,c(1,2,3,4,5)]))

par8 <- data.frame(
  core8_r1 = c(57.4557,118.127,176.933,233.995,289.039),
  core8_r2 = c(60.2524,115.085,169.663,228.822,295.859),
  core8_r3 = c(55.7983,113.151,167.788,229.809,289.597),
  core8_r4 = c(58.6992,114.297,177.163,235.33,291.729),
  core8_r5 = c(55.2538,117.032,180.673,225.815,290.282)
)

# Create new col mean_all which averages of all rows
par8 <- par8 %>% mutate(mean_all = rowMeans(.))

# Create sd
par8$row_std = rowSds(as.matrix(par8[,c(1,2,3,4,5)]))

#lr$mean_all <- log(lr$mean_all)
#par2$mean_all <- log(par2$mean_all)
#par4$mean_all <- log(par2$mean_all)
#par6$mean_all <- log(par2$mean_all)
#par8$mean_all <- log(par2$mean_all)

FinalDataFrame <- data.frame("Serial" = lr$mean_all,
                             "2 Threads" = par2$mean_all, 
                             "4 Threads" = par4$mean_all,
                             "6 Threads" = par6$mean_all,
                             "8 Threads" = par8$mean_all)

#print(par2$row_std)
#print(par4$row_std)
#print(par6$row_std)
#print(par8$row_std)

print(FinalDataFrame)

# Sadly still have to rename these...
colnames(FinalDataFrame)[1] <- "Serial"
colnames(FinalDataFrame)[2] <- "2 Threads"
colnames(FinalDataFrame)[3] <- "4 Threads"
colnames(FinalDataFrame)[4] <- "6 Threads"
colnames(FinalDataFrame)[5] <- "8 Threads"

FinalDataFrame <- melt(FinalDataFrame)
FinalDataFrame$rowid <- 1:5
FinalDataFrame$xaxis <- seq(10000, 50000, by = 10000)

#FinalDataFrame$xaxis <- log(FinalDataFrame$xaxis)

colnames(FinalDataFrame)[1] <- "Legend"

#print(FinalDataFrame)

tmp <- ggplot()

tmp + geom_line(data=FinalDataFrame, aes(x=xaxis, y=value, group=Legend, color=Legend, linetype=Legend)) + geom_point(data=FinalDataFrame, size=0.75, stroke = 1, shape = 16, aes(x = xaxis, y = value, group=Legend, color=Legend))  + xlab("Input Size") + ylab("Time Taken (Seconds)") + theme(legend.position = "bottom", text = element_text(size = 15)) + ggtitle("N-Body")

#tmp + scale_x_continuous(trans="log",breaks=FinalDataFrame$xaxis)


#+ scale_y_continuous(trans="log", breaks = scales::pretty_breaks(n = 8))

 
# Linear scaling
#tmp + scale_x_continuous(trans="identity", breaks = scales::pretty_breaks(n = 6)) + scale_y_continuous(trans="identity", breaks = scales::pretty_breaks(n = 12))


