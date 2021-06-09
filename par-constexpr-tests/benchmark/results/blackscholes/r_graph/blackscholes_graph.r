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

lr <- data.frame(
  lin_r1 = c(0.00172861,0.00703313,0.442669,1.75686,7.19318,28.4583),
  lin_r2 = c(0.00169421,0.00695473,0.440182,1.74604,7.13057,28.1439),
  lin_r3 = c(0.00173892,0.00687877,0.442652,1.76267,7.03645,28.2089),
  lin_r4 = c(0.00172461,0.00680858,0.44079,1.76736,6.95658,28.0693),
  lin_r5 = c(0.00170083,0.00690263,0.442037,1.74066,6.93362,27.8336)
)

lr <- lr %>% mutate(mean_all = rowMeans(.))

lr$row_std = rowSds(as.matrix(lr[,c(1,2,3,4,5,6)]))

par2 <- data.frame(
  core2_r1 = c(0.00223721,0.00413664,0.235767,0.940747,3.78224,15.0428),
  core2_r2 = c(0.00140249,0.00412585,0.234801,0.93568,3.80489,15.4446),
  core2_r3 = c(0.0013819,0.0041269,0.235552,0.942371,3.78241,15.0724),
  core2_r4 = c(0.00139921,0.00409223,0.233847,0.948623,3.73976,15.0078),
  core2_r5 = c(0.00137546,0.00405872,0.234938,0.938039,3.77434,15.1)
)

par2 <- par2 %>% mutate(mean_all = rowMeans(.))

par2$row_std = rowSds(as.matrix(par2[,c(1,2,3,4,5,6)]))

par4 <- data.frame(
  core4_r1 = c(0.00113226,0.00280108,0.169898,0.53248,2.12521,8.32108),
  core4_r2 = c(0.00135463,0.00420588,0.13461,0.571015,2.08691,8.2579),
  core4_r3 = c(0.0013299,0.0027779,0.144932,0.518959,2.09746,8.3454),
  core4_r4 = c(0.00105977,0.00268711,0.181912,0.541326,2.09296,8.34639),
  core4_r5 = c(0.00136268,0.00417562,0.146416,0.564493,2.06082,8.40025)
)

par4 <- par4 %>% mutate(mean_all = rowMeans(.))

par4$row_std = rowSds(as.matrix(par4[,c(1,2,3,4,5,6)]))

par6 <- data.frame(
  core6_r1 = c(0.0022513,0.0043693,0.137747,0.542166,2.33273,9.2723),
  core6_r2 = c(0.00227689,0.00427253,0.145269,0.540451,2.2419,9.2522),
  core6_r3 = c(0.00230722,0.00434141,0.147139,0.551965,2.22536,9.20991),
  core6_r4 = c(0.0023171,0.0043042,0.144605,0.560072,2.28368,9.21791),
  core6_r5 = c(0.00231133,0.00428688,0.146711,0.579661,2.30771,9.31326)
)

par6 <- par6 %>% mutate(mean_all = rowMeans(.))

par6$row_std = rowSds(as.matrix(par6[,c(1,2,3,4,5,6)]))

par8 <- data.frame(
  core8_r1 = c(0.0024052,0.00348273,0.146032,0.557346,2.23726,8.8998),
  core8_r2 = c(0.00237971,0.00359041,0.141206,0.558437,2.26299,8.80361),
  core8_r3 = c(0.00230835,0.00358222,0.145353,0.572157,2.22797,8.8868),
  core8_r4 = c(0.00232584,0.00356053,0.144359,0.555161,2.22703,8.91216),
  core8_r5 = c(0.00232406,0.00361889,0.156125,0.583178,2.23157,9.19261)
)

# Create new col mean_all which averages of all rows
par8 <- par8 %>% mutate(mean_all = rowMeans(.))

par8$row_std = rowSds(as.matrix(par8[,c(1,2,3,4,5,6)]))

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
FinalDataFrame$rowid <- 1:6
FinalDataFrame$xaxis <- c(4, 16, 1000, 4000, 16000, 64000)

colnames(FinalDataFrame)[1] <- "Legend"

tmp <- ggplot()

tmp + geom_line(data=FinalDataFrame, aes(x=xaxis, y=value, group=Legend, color=Legend, linetype=Legend)) + geom_point(data=FinalDataFrame, size=0.75, stroke = 1, shape = 16, aes(x = xaxis, y = value, group=Legend, color=Legend))  + xlab("Number of Input Data Points") + ylab("Time Taken (Seconds)") + theme(legend.position = "bottom", text = element_text(size = 15)) + ggtitle("Blackscholes")

warnings()

