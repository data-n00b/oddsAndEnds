library(tidyverse)
library(ggplot2)
library(lubridate)


lenData <- read.csv("sentiment_data.csv", header = TRUE)
lenData <- tbl_df(lenData)
#lenData %>% drop_na()

#names(lenData)
names(lenData)[1] <- 'comment_id'
names(lenData)[2] <- 'comment_date'
lenData$comment_date <- as.Date(lenData$comment_date, "%m/%d/%Y")
lenData$Comment <- as.character(lenData$Comment)

# Dropping the Terms and Sub-Category Beyond this point
lenData$Terms <- NULL
lenData$Sub.category <- NULL

#Counting number of products before categorizing drop
numProducts <- lenData %>% group_by(Product,Business.Group) %>%  count()

#Subsetting only the discussed products
lenData <- lenData %>% filter(Product %in% c('X1 CARBON 2017','T470', 'THINKPAD P51','THINKPAD P71','X1 YOGA GENERAL'))

#Arranging by date
lenData <- lenData %>% arrange(comment_date)
lenData %>% group_by(comment_id,Product,Stars.Rating,comment_date) %>% count(Sentiment)

z <- lenData %>% group_by(comment_id,Product,Stars.Rating,comment_date) %>% count(Sentiment)

#Group by comment id and count positive and negative

#z <- lenData  %>%  group_by(comment_id) %>% count(Sentiment)

#Percentage contributed by each sentiment to the star rating
z <- z %>%  mutate(perN = n / sum(n)) %>%  group_by(comment_id)

#Expected value of negatuve neutral and positive
z <- z %>%  mutate(wSenti = n * perN)

#Weighted Score (-1 for Negative 1 for Neutral and 2 for positive)

wNegative = -1
wPositive = 3
wNeutral = 1
z['senMul']  <- ifelse(z$Sentiment == 'NEGATIVE', z$wSenti*wNegative, ifelse(z$Sentiment == 'POSITIVE', z$wSenti*wPositive,z$wSenti*wNeutral))



myNPS <- z %>%  group_by(comment_id,Product,comment_date) %>% summarise(newScore = sum(senMul)) 

myNPS$comment_id <- NULL

#Dropping Comment ID
#Scaling new score for each product from 1-10.

a <- 1

b <- 10

myNPS <- myNPS %>% group_by(Product) %>% mutate(newNPS = (((b-a) * (newScore- min(newScore))) / (max(newScore) - min(newScore))) + a)

#Defining the range of the data as Date objects
#Adding a NEW column to indicate the week number.
#This might allow us to optially drop off the comment date also.

startDate = min(myNPS$comment_date)
endDate = max(myNPS$comment_date)

as.numeric((endDate-startDate),units = "weeks")

myNPS <- myNPS %>%  mutate(weekNum = ceiling(as.numeric((comment_date - startDate), units ='weeks') +1))

#Dropping comment date and newScore.
#Keeping only the newNPS, weekNumber and Product as these are the factors of interest.

myNPS$comment_date <- NULL
myNPS$newScore <- NULL

#Transforming to the average NPS of the product each week.

avgNPS <- myNPS %>% group_by(Product,weekNum) %>% summarise(newNPS  = round(mean(newNPS),2))

#write.csv(myNPS,file="myNPS_R.csv")

#Now that you have newNPS, plot the actual survey data for the same product over the same scale of time
# and fit the model.
#same operations on survey data to get product, nps and week number focussing on product NPS
surData <- read.csv("survey_data.csv", header = TRUE)
surData <- tbl_df(surData)

surData <- surData[,-c(1,3,4,5,7,8,9,10,11,12,13,14)]
surData <- surData[, -c(4:78)]

surData$Date.Survey <- as.Date(surData$Date.Survey, "%m/%d/%Y")
levels(surData$Product.NPS)[1] <- '0'
na.omit(surData)
surData$Product.NPS<- as.character(surData$Product.NPS)
surData$Product.NPS<- as.numeric(surData$Product.NPS)
surData <- surData %>% filter(Product %in% c('X1 CARBON 2017','T470', 'THINKPAD P51','THINKPAD P71','X1 YOGA GENERAL'))

surData <- surData %>% arrange(Date.Survey)
startDate = min(surData$Date.Survey)
endDate = max(surData$Date.Survey)

surData <- surData %>%  mutate(weekNum = ceiling(as.numeric((Date.Survey - startDate), units ='weeks') +1))

surData$Date.Survey <- NULL

avgSur <- surData %>% group_by(Product,weekNum) %>% summarise(avgNPS  = round(mean(Product.NPS),2))

ggplot() + geom_line(data = avgNPS,aes(weekNum,newNPS,color='newNPS')) +   facet_wrap(.~Product) +
           geom_line(data = avgSur,aes(weekNum,avgNPS,color='avgNPS'))+ facet_wrap(.~Product) +
          scale_colour_discrete("Type") +
           scale_x_discrete(limits=c(1:66)) +
           ggtitle("Trend vs survey for T470") + 
           theme_minimal()
           



#startOnly <- lenData %>% select(comment_id,Stars.Rating)

#Weighted Score Attempt 1
# Unused Code

# gg1 <- ggplot(avgSur,aes(weekNum,avgNPS))
# 
# gg1 + geom_line() + facet_wrap(.~Product) + theme_minimal() + scale_x_discrete(limits=c(1:66))
# 
# gg1 <- ggplot(avgSur %>% filter(Product=="T470"),aes(weekNum,avgNPS))
# 
# gg1 <- gg1 + geom_line() + facet_wrap(.~Product) + theme_minimal() + scale_x_discrete(limits=c(1:66))
# 
# gg <- ggplot(avgNPS,aes(weekNum,newNPS))
# 
# gg + geom_line() + facet_wrap(.~Product) + theme_minimal() + scale_x_discrete(limits=c(1:66))
# 
# gg <- ggplot(avgNPS %>% filter(Product=="T470"),aes(weekNum,newNPS))
# 
# gg <- gg + geom_line() + facet_wrap(.~Product) + theme_minimal() + scale_x_discrete(limits=c(1:66))

