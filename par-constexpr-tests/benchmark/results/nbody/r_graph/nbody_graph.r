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
XAxis = c(16, 32, 64, 128, 256)

lr <- data.frame(
  lin_r1 = c(0.651333,2.71557,11.0975,46.3218,189.335),
  lin_r2 = c(0.638982,2.67746,11.0443,45.1432,183.631),
  lin_r3 = c(0.638237,2.6566,10.9755,45.2787,184.59),
  lin_r4 = c(0.635594,2.66388,10.9741,45.1092,184.609),
  lin_r5 = c(0.640374,2.67489,10.9611,44.843,185.234)
)

# Create new col mean_all which averages of all rows
lr <- lr %>% mutate(mean_all = rowMeans(.))

lr$row_std = rowSds(as.matrix(lr[,c(1,2,3,4,5)]))

par2 <- data.frame(
  core2_r1 = c(0.377569,1.50441,6.04573,24.4259,97.7243),
  core2_r2 = c(0.376344,1.49015,6.06949,24.7908,98.4472),
  core2_r3 = c(0.377258,1.50237,6.20563,24.5258,98.1778),
  core2_r4 = c(0.386742,1.51749,6.02482,24.4414,99.2288),
  core2_r5 = c(0.37383,1.49837,5.99156,24.47,99.2532)
)

# Create new col mean_all which averages of all rows
par2 <- par2 %>% mutate(mean_all = rowMeans(.))

# sample standard deviation
par2$row_std = rowSds(as.matrix(par2[,c(1,2,3,4,5)]))

par4 <- data.frame(
  core4_r1 = c(0.256058,0.8906,3.30746,13.1775,53.7679),
  core4_r2 = c(0.273122,0.893387,3.29489,13.2191,53.631),
  core4_r3 = c(0.259503,0.884644,3.37623,13.2636,52.8828),
  core4_r4 = c(0.268553,0.885195,3.3376,13.246,53.5919),
  core4_r5 = c(0.259796,0.881228,3.29802,13.2707,53.5115)
)

# Create new col mean_all which averages of all rows
par4 <- par4 %>% mutate(mean_all = rowMeans(.))

# Create sd
par4$row_std = rowSds(as.matrix(par4[,c(1,2,3,4,5)]))

par6 <- data.frame(
  core6_r1 = c(0.385927,1.05017,3.81188,14.0904,57.1447),
  core6_r2 = c(0.385102,1.02272,3.86458,14.0341,56.5842),
  core6_r3 = c(0.38374,1.03561,3.82418,14.0124,56.6634),
  core6_r4 = c(0.385652,1.03966,3.8087,13.9752,56.6737),
  core6_r5 = c(0.385077,1.06046,3.8806,13.9634,56.0781)
)

# Create new col mean_all which averages of all rows
par6 <- par6 %>% mutate(mean_all = rowMeans(.))

# Create sd
par6$row_std = rowSds(as.matrix(par6[,c(1,2,3,4,5)]))

par8 <- data.frame(
  core8_r1 = c(0.255144,0.87899,3.33474,13.2987,52.597),
  core8_r2 = c(0.25287,0.855318,3.43531,13.2857,52.5812),
  core8_r3 = c(0.252656,0.881717,3.39463,13.0829,52.6372),
  core8_r4 = c(0.255906,0.889358,3.35374,13.2795,53.2195),
  core8_r5 = c(0.261827,0.893997,3.34628,13.3253,52.7703)
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
FinalDataFrame$xaxis <- c(16, 32, 64, 128, 256)

#FinalDataFrame$xaxis <- log(FinalDataFrame$xaxis)

colnames(FinalDataFrame)[1] <- "Legend"

#print(FinalDataFrame)

tmp <- ggplot()

tmp + geom_line(data=FinalDataFrame, aes(x=xaxis, y=value, group=Legend, color=Legend, linetype=Legend)) + geom_point(data=FinalDataFrame, size=0.75, stroke = 1, shape = 16, aes(x = xaxis, y = value, group=Legend, color=Legend))  + xlab("Number of Bodies") + ylab("Time Taken (Seconds)") + theme(legend.position = "bottom", text = element_text(size = 15)) + ggtitle("N-Body")

#tmp + scale_x_continuous(trans="log",breaks=FinalDataFrame$xaxis)


#+ scale_y_continuous(trans="log", breaks = scales::pretty_breaks(n = 8))

 
# Linear scaling
#tmp + scale_x_continuous(trans="identity", breaks = scales::pretty_breaks(n = 6)) + scale_y_continuous(trans="identity", breaks = scales::pretty_breaks(n = 12))


