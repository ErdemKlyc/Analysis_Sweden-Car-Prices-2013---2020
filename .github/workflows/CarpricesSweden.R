#Data Source :Nybilspriser,(bilar med tillverkningsår 2013-2020) https://oppnadata.se/datamangd/#esc_entry=68529&esc_context=6

df2013 <- read.csv("SKVFS_2013_11.csv", header = TRUE, sep = ";", dec = ".")
df2014 <- read.csv("SKVFS_2014_13.csv", header = TRUE, sep = ";", dec = ".")
df2015 <- read.csv("SKVFS_2015_11.csv", header = TRUE, sep = ";", dec = ".")
df2016 <- read.csv("SKVFS_2016_10_bilaga_4.csv", header = TRUE, sep = ";", dec = ".")
df2017 <- read.csv("SKVFS2017_10_foreskrift.csv", header = TRUE, sep = ";", dec = ".")
df2018 <- read.csv("SKVFS_2018_13.csv", header = TRUE, sep = ";", dec = ".")
df2019 <- read.csv("SKVFS2019-10.csv", header = TRUE, sep = ";", dec = ".")
df2020 <- read.csv("Nybilspriser 2020 SKVFS2019_21.csv", header = TRUE, sep = ";", dec = ".")


#joning all data for years as one dataframe
swcarprice <- rbind(df2013,df2014,df2015,df2016,df2017,df2018,df2019,df2020) #joining variables
 
na.omit(swcarprice)#Remove "NAs"
library(ggplot2)
ggplot(swcarprice) +
  aes(x = Nybilspris, y = Tillverkningsar) +
  geom_point()


#saving joined file as csv
#write.csv(swcarprice, 'swcarprice.csv') #saving joined file as csv
#devtools::install_github("rubenarslan/formr")

#Remove "NAs" from 2020 data (df2020) 
na.omit(df2020)
median(df2020$Nybilspris)
head(df2020)

#Extract models and prices
library(dplyr)
modelp <- filter(df2020, Fordonstyp == "Personbil") %>%
  select(Modell, Nybilspris)


########################################################################
                                                                        #
#Creating Histogram for Median for 2020 Prices                          #
                                                                        #
########################################################################

library(ggplot2)
options(scipen=5) #avoids scientific notation numbers in x axis
coord_cartesian(xlim = c(80000, 700000), ylim = c(0, 1500))
ggplot(modelp, aes(x = Nybilspris)) +
  geom_histogram(color = 'darkgray', fill = 'white', binwidth = 100000) +
  labs(x = 'Price', y = 'Count', title = 'Sweden Car Prices 2020')+
  coord_cartesian(xlim = c(80000, 1000000), ylim = c(0, 800))+
  #geom_vline(aes(xintercept = mean(modelp$Nybilspris), color = 'mean'), show.legend = TRUE, size =2) +
  geom_vline(aes(xintercept = median(modelp$Nybilspris), color = 'Median'), show.legend = TRUE, size =2)+
  show(median(modelp$Nybilspris))
  #scale_color_manual(name ='statistics', values = c(mean = 'red', median = 'blue'))
  
########################################################################
                                                                        #
#Plotting box blot for fuel type                                        #
                                                                        #
########################################################################
library(ggplot2)
ggplot(df2020, mapping = aes(x = BransleTyp, y= Nybilspris)) +
  geom_boxplot() +
  coord_cartesian(, ylim = c(80000, 1000000))+
  labs(x = "Fuel Type", y = "Price", title = 'Price Range by Fuel Type')
  #coord_flip()

summary(df2020)

#View(df2020)
#Electric Cars in 2020
library(dplyr)
elcar2020 <- filter(df2020, BransleTyp == "El") %>%
  select(Marke, Modell, Tillverkningsar, Nybilspris, BransleTyp)

median(elcar2020$Nybilspris) #result:439500
#View(elcar2020)

#Bensin Cars in 2020
library(dplyr)
bensincar2020 <- filter(df2020, BransleTyp == "Bensin") %>%
  select(Marke, Modell, Tillverkningsar, Nybilspris, BransleTyp)

median(bensincar2020$Nybilspris) #result:359500
#View(bensincar2020)

summary(swcarprice)
library(gapminder)
attach(swcarprice)
median(swcarprice$Nybilspris) #334900
hist(log(swcarprice$Nybilspris))
boxplot(swcarprice$Nybilspris ~ swcarprice$Marke)
boxplot(swcarprice$Nybilspris ~ swcarprice$BransleTyp)
plot(swcarprice$Nybilspris ~ swcarprice$Marke)

library(dplyr)
swcarprice %>%
  select (Marke, Nybilspris) %>%
  filter(   Marke == "Audi" |
              Marke == "Mercedes Benz" |
              Marke == "BMW" |
              Marke == "Volvo") %>%
  group_by(Marke) %>%
  summarise(Average_price = mean(Nybilspris))


ort <- swcarprice %>%
  select (Marke, Nybilspris) %>%
  filter( Fordonstyp == "Personbil") %>%
  group_by(Marke) %>%
  summarise(Average_price = mean(Nybilspris))
plot(ort)
head(swcarprice)

#Extracting data (Personbil rows in Fordonstyp,Tillverkningsar, Marke, Nybilspris, BransleTyp columns) for analysis
library(dplyr)
maindata <- filter(swcarprice, Fordonstyp == "Personbil") %>%
  select(Marke, Modell, Tillverkningsar, Nybilspris, BransleTyp)

#View(maindata)
write.csv(maindata, 'Passangercar_prices_sweden.csv')


#Calculating average prices for years for each brand
carpricessweden <- read.csv("Passangercar_prices_sweden.csv", sep = ",", dec = ".")
#View(carpricessweden)
#View(is.na(carpricessweden))
library(dplyr)
average <- dput(carpricessweden)
averageout <- aggregate(. ~ Marke + Tillverkningsar, carpricessweden[-2], FUN = median)
#View(averageout)
summary(averageout)
summary(Nybilspris)

#Brands with Median Prices below 225900SEK
library(ggplot2)
averageout %>%
  filter(Nybilspris <= 225900) %>%
  ggplot(aes(x=Tillverkningsar, y=Nybilspris, col=Marke))+
  geom_point(alpha=0.5)+
  geom_smooth(aes(group=1))+
  labs(x = "Year", y = "Price", title = 'Brands with Median Prices below 225900')
#facet_wrap(~Marke)

#Brands with Median Prices range between 225900SEK to 420517SEK
library(ggplot2)
averageout %>%
  filter(Nybilspris >= 225900, Nybilspris <= 420517 ) %>%
  ggplot(aes(x=Tillverkningsar, y=Nybilspris, col=Marke))+
  geom_point(alpha=0.5)+
  geom_smooth(aes(group=1))+
  labs(x = "Year", y = "Price", title = 'Brands with Median Prices range between 22000SEK to 432000SEK')
#facet_wrap(~Marke)



#Brands with Median Prices range between 420517SEK to 1500000SEK
library(ggplot2)
averageout %>%
  filter(Nybilspris >= 420517, Nybilspris <= 1500000 ) %>%
  ggplot(aes(x=Tillverkningsar, y=Nybilspris, col=Marke))+
  geom_point(alpha=0.5)+
  geom_smooth(aes(group=1))+
  labs(x = "Year", y = "Price", title = 'Brands with Median Prices between 420517SEK to 1500000SEK')
#facet_wrap(~Marke)

#Brands with Median Prices above 1500000SEK
library(ggplot2)
averageout %>%
  filter(Nybilspris >= 1500000) %>%
  ggplot(aes(x=Tillverkningsar, y=Nybilspris, col=Marke))+
  geom_point(alpha=0.5)+
  geom_smooth(aes(group=1))+
  labs(x = "Year", y = "Price", title = 'Brands with Median Prices above 1500000SEK')
#facet_wrap(~Marke)



#Compare if BMW is really more expensive than Audi with t-test & null hyphothesis

bmwvsaudi <- swcarprice %>%
  select (Marke, Nybilspris) %>%
  filter(   Marke == "Audi" |
              Marke == "BMW")
t.test(data = bmwvsaudi, Nybilspris ~ Marke)



