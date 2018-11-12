# ----------NOTES----------
# After fitting the model, try to track back the features that
# contributed to the negative or lower ratings as we progress week by week.
rm(list = setdiff(ls(), lsf.str()))
library(tidyverse)
library(ggplot2)
library(lubridate)

sentiFileName <- "sentiment_data.csv"
lenData <- read.csv(sentiFileName, header = TRUE)
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
filterProducts <- c('N23 CHROME', 'X1 CARBON 2017', 'T470','X270','THINKPAD 25')
lenData <- lenData %>% filter(Product %in% filterProducts)

#Arranging by date
lenData <- lenData %>% arrange(comment_date)
lenData %>% group_by(comment_id,Product,Stars.Rating,comment_date,vTaxonomyLevel) %>% count(Sentiment)

#Including the taxonomy for a dataframe of negative sentiment issues
z1 <- lenData %>% group_by(comment_id,Product,Stars.Rating,comment_date) %>% count(Sentiment)


z <- lenData %>% group_by(comment_id,Product,Stars.Rating,comment_date,vTaxonomyLevel) %>% count(Sentiment)

#Group by comment id and count positive and negative

#z <- lenData  %>%  group_by(comment_id) %>% count(Sentiment)

#Percentage contributed by each sentiment to the star rating
z1 <- z1 %>%  mutate(perN = n / sum(n)) %>%  group_by(comment_id)

#Weighted Score (-1 for Negative 1 for Neutral and 2 for positive)
#These are the values to be weighted against for dfferent trends
wNegative <- -3
wNeutral <- 0
wPositive <- 1

z1['senMul']  <- ifelse(z1$Sentiment == 'NEGATIVE', z1$perN*wNegative, 
                       ifelse(z1$Sentiment == 'POSITIVE', z1$perN*wPositive,z1$perN*wNeutral))

startDate = min(z1$comment_date)

z1 <- z1 %>% mutate(weekNum = ceiling(as.numeric((comment_date-startDate),units="weeks")+1))

myNPS <- z1 %>%  group_by(Product,weekNum) %>% summarise(newScore = round(mean(senMul),2))

#myNPS$comment_id <- NULL

#Manipulating Z yet again to get the table with Product,Negative Issue and Week of Occurance.
z<-z[,-c(1,3,7)]

startDate <- min(z$comment_date)

z <-  z %>% mutate(weekNum = ceiling(as.numeric((comment_date - startDate), units ='weeks') +1))
z %>% group_by(Product,Sentiment,weekNum)%>% count(vTaxonomyLevel)

issueDF <- z[,-c(2)]

issueDF <- issueDF %>% filter(Sentiment =="NEGATIVE")

#Dropping Comment ID
#Scaling new score for each product from 1-10.

a <- 0

b <- 10

myNPS <- myNPS %>% group_by(Product) %>% mutate(newNPS = (((b-a) * (newScore- min(newScore))) / (max(newScore) - min(newScore))) + a)

#Defining the range of the data as Date objects
#Adding a NEW column to indicate the week number.
#This might allow us to optially drop off the comment date also.

#Dropping comment date and newScore.
#Keeping only the newNPS, weekNumber and Product as these are the factors of interest.

#Now that you have newNPS, plot the actual survey data for the same product over the same scale of time
# and fit the model.
#same operations on survey data to get product, nps and week number focussing on product NPS

surFileName <- "survey_data.csv"
surData <- read.csv(surFileName, header = TRUE)
surData <- tbl_df(surData)

surData <- surData[,-c(1,3,4,5,7,8,9,10,11,12,13,14)]
surData <- surData[, -c(4:78)]


surData$Date.Survey <- as.Date(surData$Date.Survey, "%m/%d/%Y")
levels(surData$Product.NPS)[1] <- '0'
na.omit(surData)
surData$Product.NPS<- as.character(surData$Product.NPS)
surData$Product.NPS<- as.numeric(surData$Product.NPS)
surData <- surData %>% filter(Product %in% filterProducts)

surData <- surData %>% arrange(Date.Survey)
startDate = min(surData$Date.Survey)
endDate = max(surData$Date.Survey)

surData <- surData %>%  mutate(weekNum = ceiling(as.numeric((Date.Survey - startDate), units ='weeks') +1))

surData$Date.Survey <- NULL

avgSur <- surData %>% group_by(Product,weekNum) %>% summarise(avgNPS  = round(mean(Product.NPS),2))

#selectedProduct <- "T470"
productPlot <- ggplot() +  geom_line(data = avgSur,aes(weekNum,avgNPS,color='avgNPS'))+
            facet_wrap(.~Product) +
            geom_line(data = myNPS,aes(weekNum,newScore,color='newScore'))+
            facet_wrap(.~Product) +
            #geom_line(data = myNPS%>% filter(Product == selectedProduct),aes(weekNum,newNPS,color='newNPS'))+
            #facet_wrap(.~Product) +
            scale_colour_discrete("Type") +
            scale_x_discrete(limits=c(1:66)) + scale_y_discrete(limits = c(0:10)) +
            ggtitle(paste0("Trend vs survey weighted at ","(",wNegative, ",",wNeutral,",",wPositive,") for (Negative, Positive and Neutral)")) +
            theme_minimal() +
            theme(plot.title = element_text(size=8)) +
            coord_fixed()

issuegg <- ggplot(issueDF,aes(weekNum,vTaxonomyLevel)) + guides(color= 'legend')

issuePlot <- issuegg + labs(x="Week Number", y= "Issue",title ="Count of issues across products week over week") + 
          geom_count(aes(color=..n..,size = ..n..)) + 
          scale_x_discrete(limits=c(1:66)) +
          scale_y_discrete(limits=names(issueDF$vTaxonomyLevel))+
          facet_wrap(.~Product) + 
          theme_minimal()+
          coord_fixed()

ggsave("issues.png", issuePlot, width=50, height=25, units="in", dpi=600,limitsize = FALSE)   
ggsave("productPLot.png", productPlot, width=50, height=25, units="in", dpi=600,limitsize = FALSE)   
