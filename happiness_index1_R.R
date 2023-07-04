library(dplyr)
library(ggplot2)

#loading data into datasets
year_2015 = read.csv('2015.csv')
year_2016 = read.csv('2016.csv')
year_2017 = read.csv('2017.csv')
year_2018 = read.csv('2018.csv')
year_2019 = read.csv('2019.csv')

#unification of dataframes
year_2015_1 = subset(year_2015, select= -c(Standard.Error))
year_2016_1 = subset(year_2016, select= -c(Lower.Confidence.Interval,Upper.Confidence.Interval))
year_2017_1 = subset(year_2017, select= -c(Whisker.high, Whisker.low))

year_2017_2 = year_2017_1 %>% select(Country, Happiness.Rank, Happiness.Score, Economy..GDP.per.Capita., Family, Health..Life.Expectancy., Freedom, Trust..Government.Corruption.,Generosity, Dystopia.Residual)


#preparing data to combine it into one data frame                     
RANK_2015 = data.frame(countryid_ph= c(year_2015_1$Country),
                  regionid_ph=c(year_2015_1$Region),
                  happiness_rank= c(year_2015_1$Happiness.Rank),
                  happiness_score= c(year_2015_1$Happiness.Score),
                  gdppc = c(year_2015_1$Economy..GDP.per.Capita.),
                  family = c(year_2015_1$Family),
                  health = c(year_2015_1$Health..Life.Expectancy.),
                  freedom = c(year_2015_1$Freedom),
                  trust_in_gov = c(year_2015_1$Trust..Government.Corruption.),
                  generosity = c(year_2015_1$Generosity),
                  dystopia = c(year_2015_1$Dystopia.Residual),
                  year_of_study="2015")
  
RANK_2016 = data.frame(countryid_ph= c(year_2016_1$Country),
                       regionid_ph=c(year_2016_1$Region),
                       happiness_rank= c(year_2016_1$Happiness.Rank),
                       happiness_score= c(year_2016_1$Happiness.Score),
                       gdppc = c(year_2016_1$Economy..GDP.per.Capita.),
                       family = c(year_2016_1$Family),
                       health = c(year_2016_1$Health..Life.Expectancy.),
                       freedom = c(year_2016_1$Freedom),
                       trust_in_gov = c(year_2016_1$Trust..Government.Corruption.),
                       generosity = c(year_2016_1$Generosity),
                       dystopia = c(year_2016_1$Dystopia.Residual),
                       year_of_study="2016")

RANK_2017 = data.frame(countryid_ph= c(year_2017_2$Country),
                       regionid_ph="5",
                       happiness_rank= c(year_2017_2$Happiness.Rank),
                       happiness_score= c(year_2017_2$Happiness.Score),
                       gdppc = c(year_2017_2$Economy..GDP.per.Capita.),
                       family = c(year_2017_2$Family),
                       health = c(year_2017_2$Health..Life.Expectancy.),
                       freedom = c(year_2017_2$Freedom),
                       trust_in_gov = c(year_2017_2$Trust..Government.Corruption.),
                       generosity = c(year_2017_2$Generosity),
                       dystopia = c(year_2017_2$Dystopia.Residual),
                       year_of_study="2017")

#creating one data frame for all 3 years
RANK_ALL= rbind(RANK_2015, RANK_2016, RANK_2017)

nazwy_niepowtarzajace_sie <- character(0) 
unikalne_nazwy = unique(RANK_ALL$countryid_ph)

#checking for country names that don't appear in the df exactly 3 times
for (nazwa in unikalne_nazwy) {
  liczba_wystapien = sum(RANK_ALL$countryid_ph == nazwa)
  if (liczba_wystapien != 3) {
    cat("Nazwa", nazwa, "nie powtarza się dokładnie 3 razy\n")
    nazwy_niepowtarzajace_sie = c(nazwy_niepowtarzajace_sie, nazwa)
  }
}

# dropping rows with incomplete data for 3 years
df1 = RANK_ALL[!(RANK_ALL$countryid_ph %in% nazwy_niepowtarzajace_sie), , drop = FALSE]


#creating data frame with countries and their region
lista_unikalnych_krajow = character(0)

for (kraj in df1$countryid_ph) {
  if (!(kraj %in% lista_unikalnych_krajow)) {
    lista_unikalnych_krajow = c(lista_unikalnych_krajow, kraj)
  }
}

countries = data.frame(country_name=lista_unikalnych_krajow,
                       region_name=c(df1$regionid_ph),
                       countryid= "1",
                       regionid="2")

countries_done = countries[!duplicated(countries$country_name), ]




#data analysis

#creating a correlation heat map
heat_m = data.frame(happiness_rank= c(RANK_ALL$happiness_rank),
                 happiness_score= c(RANK_ALL$happiness_score),
                 gdppc = c(RANK_ALL$gdppc),
                 family = c(RANK_ALL$family),
                 health = c(RANK_ALL$health),
                 freedom = c(RANK_ALL$freedom),
                 trust_in_gov = c(RANK_ALL$trust_in_gov),
                 generosity = c(RANK_ALL$generosity),
                 dystopia = c(RANK_ALL$dystopia)
)
cor_matrix = round(cor(heat_m), 2)
cor_df = as.data.frame(as.table(cor_matrix))

heatmap_plot = ggplot(data = cor_df, aes(x = Var1, y = Var2, fill = Freq)) +
  geom_tile() +
  scale_fill_gradient(low = "blue", high = "red") +
  labs(title = "Macierz Korelacji") +
  xlab("") +
  ylab("") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5))
print(heatmap_plot)

#histogram 
histogram = hist(RANK_ALL$health, 
                 col= "#de4362",
                 xlab = "Healthy_life_expectancy",
                 main = " ",
                 )

mean_health <- mean(RANK_ALL$health)
sd_health <- sd(RANK_ALL$health)
curve(dnorm(x, mean = mean_health, sd = sd_health), 
      col = "#009fff", lwd = 2, add = TRUE)
print(historgam)


#saving the data into csv
write.csv(df1, "RANK_ALL1.csv", row.names=FALSE)
write.csv(countries_done, "countries_done.csv", row.names=FALSE)
write.csv(RANK_ALL, "RANK_ALL.csv", row.names=FALSE)
write.table(RANK_ALL, "RANK_ALL.txt", sep=',', row.names=FALSE)