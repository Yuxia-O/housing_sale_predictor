rm(list = ls())
library(readr)
data <- read_csv("C:/Users/oriaz/Google Drive/Ms O/Job App/Industry job/Data Incubator/Arrest_Data_from_2010_to_Present.csv")

data$year<-substring(data$`Arrest Date`,7,10)

## number of bookings of arrestees in 2018
data2018<-data[data$year==2018,]
nrow(data2018)

## number of bookings of arrestees in the area with the most arrests in 2018
max(table(data2018$`Area Name`))

## 95% quantile of the age of arresttees in the 4 charge groups in 2018
sub1<-subset(data2018,`Charge Group Code`=="03")
sub2<-subset(data2018,`Charge Group Code`=="05")
sub3<-subset(data2018,`Charge Group Code`=="07")
sub4<-subset(data2018,`Charge Group Code`=="11")
data2018qt<-rbind(sub1,sub2,sub3,sub4)
quantile(data2018qt$Age, probs = c(0.05, 0.95),na.rm = T)

## Z-score of average age for each charge group
data2018agez<-subset(data2018,`Charge Group Description`!="Pre-Delinquency")
data2018agez<-subset(data2018agez,`Charge Group Description`!="Non-Criminal Detention")

data2018agez$std_age<-scale(data2018agez$Age)
agetable<-tapply(data2018agez$std_age,data2018agez$`Charge Group Description`,mean,na.rm=T)
format(max(abs(agetable)),digits=10)

## Felony arrest prediction in 2019
data$yearnum<-as.numeric(factor(data$year))
data1018<-data[data$year<2019,]
lntrend<-table(data1018$yearnum)
lntrend <- as.data.frame(lntrend)
colnames(lntrend)<-c("Yearnum","FelonyArrests")
lntrend$Yearnum<-as.numeric(lntrend$Yearnum)
reg<-lm(FelonyArrests~Yearnum,data = lntrend)
summary(reg)
round(predict(reg,data.frame(Yearnum=c(10,11,12,13))),0)


## number of arrest within 2km from Bradbury Building in 2018
#extract latitude
library(stringr)
numextract <- function(string){ 
  str_extract(string, "\\-*\\d+\\.*\\d*")
} 
a<-numextract(data2018$Location)
data2018$a<-as.numeric(a)

#extract longitude
b<-gsub(".*, ","",data2018$Location)
library(taRifx)
b<-destring(b, keep="0-9.-")
data2018$b<-as.numeric(b)

data2018rad<-subset(data2018,a!=0 & b!=0)

a1=34.050536
b1=-118.247861
data2018rad$dlat=data2018rad$a-a1
data2018rad$dlog=data2018rad$b-b1
data2018rad$d1=(data2018rad$dlat)^2+(cos(0.5*data2018rad$a+0.5*a1)*data2018rad$dlog)^2
data2018rad$d=6371*sqrt(data2018rad$d1)
nrow(data2018rad[data2018rad$d<2,])


## number of arrests per km on Pico
library(tidyr)
data2018pico<-unite("AddStr",Address:`Cross Street`,data=data2018rad,remove=FALSE)
picosubset<-data2018pico[grep("PICO",data2018pico$AddStr),]
picosubset$std_a<-scale(picosubset$a)
picosubset$std_b<-scale(picosubset$b)
picoclean<-picosubset[picosubset$std_a<2 & picosubset$std_b<2,]
picoclean<-picosubset[picosubset$std_a>-2 & picosubset$std_b>-2,]
maxa=max(picoclean$a)
mina=min(picoclean$a)
maxb=picoclean$b[which.max(picoclean$a)]
minb=picoclean$b[which.min(picoclean$a)]
l1=(maxa-mina)^2+(cos(0.5*maxa+mina)*(maxb-minb))^2
picolength=6371*sqrt(l1)
picodense=nrow(picoclean)/picolength
format(picodense,digits=11)


## ratio of conditional prob to unconditional prob
data1018cdt<-subset(data1018,!`Charge Group Code`==99)
data1018cdt<-data[!is.na(data$`Charge Group Code`),]
cdt<-table(data1018cdt$`Charge Group Description`,data1018cdt$`Area Name`)
cdtprop<-prop.table(cdt)
cdtprop<-as.data.frame(cdtprop)
colnames(cdtprop)<-c("ChargeGroup","Area","Cdtprob")
cdtcity<-table(data1018cdt$`Charge Group Description`)
cdtcityprop<-prop.table(cdtcity)
cdtcityprop<-as.data.frame(cdtcityprop)
colnames(cdtcityprop)<-c("ChargeGroup","Uncdtprob")
cdtdata<-merge(cdtprop,cdtcityprop,by='ChargeGroup',all.x = T)
cdtdata$ratio<-cdtdata$Cdtprob/cdtdata$Uncdtprob
top5<-sort(cdtdata$ratio,decreasing=T)
format(mean(top5[1:5]),digits = 11)