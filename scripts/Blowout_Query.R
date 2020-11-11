#install.packages("RMariaDB")
#install.packages("ggplot2")
#install.packages("gridExtra")
#install.packages("psych")
#install.packages("gridExtra")
#install.packages("qwraps2")
library(ggplot2)          #for clean plots
library(psych)            #for summarizing data (not used?)
library(RMariaDB)         #for db connection
library(gridExtra)        #for summary table grid plotting
require(ggplot2)          #for grid plotting

#select season, if running aggregate data, set to "All".  Otherwise, enter season as int
season <- 2018
sql_insert <- if (season != "All"){ paste("AND Season =",season)} else {}

#--------------------------------->
#connect to database--------------
devenvironment <- dbConnect(RMariaDB::MariaDB(), user='root', password='', 
  dbname='devenvironment', host='localhost', port=3308)

#list tables to confirm database connection
#dbListTables(devenvironment)

#query SQL Table - pull all records with Spread_Error > 9 (blowouts)
query <- paste("SELECT *, if  (Spread_Error < 0, TRUE, FALSE) as Away_Covered from seasons_spreads WHERE abs(Spread_Error) > 9",sql_insert,";")
#print(query)    #print query to confirm syntax

rsInsert <- dbSendQuery(devenvironment, query)       #insert query into database 
dbRows <- dbFetch(rsInsert, n=-1)                    #fetch result, store in var dbRows

#convert Spread_Error data from int64 to int, int64 cannot plot in histogram
SpreadError <- as.integer(dbRows$Spread_Error)

#Get relevant statistics
minx <- round(min(dbRows$RoadClose),2)
miny <- round(as.integer(min(dbRows$Spread_Error)),2)
maxx <- round(max(dbRows$RoadClose),2)
maxy <- round(as.integer(max(dbRows$Spread_Error)),2)
SpreadErrorMean <- round(mean(dbRows$Spread_Error),2)

#run t test on RoadClose and save key variables
#RoadClose_t_test <- t.test(x=dbRows$RoadClose, y=NULL, alternative=c("two.sided", "less", "greater"), 
#       mu=0, paired=FALSE, var.equal=FALSE, conf.level=0.65)         
#RoadCloseUpperBound <- round(RoadClose_t_test$conf.int[2],2)
#RoadCloseLowerBound <- round(RoadClose_t_test$conf.int[1],2)
#RoadCloseMean <- round(RoadClose_t_test$estimate,2)

#run single sample proportion test on RoadClose, see if bias leans toward Road Dogs or Home Favorites
n <- length(dbRows$RoadClose)
x <- sum(dbRows$RoadClose > 0)

RoadCloseProp <- prop.test(x, n, p=0.5, alternative = "two.sided", conf.level = 0.95, correct = FALSE)
RoadCloseUpperBound <- round(RoadCloseProp$conf.int[2],2)
RoadCloseLowerBound <- round(RoadCloseProp$conf.int[1],2)
RoadCloseMean <- round(RoadCloseProp$estimate,2)
RoadClosep <- round(RoadCloseProp$p.value,6)


#run single sample proportion test on Away Covered, filtered for Road Dogs
#query SQL Table - pull all records with Spread_Error > 9 (blowouts) and Road Dogs (RoadClose > 0)
#query<-"SELECT if  (Spread_Error < 0, TRUE, FALSE) as Away_Covered from seasons_spreads WHERE abs(Spread_Error) > 9 AND RoadClose > 0;"
#print(query)    #print query to confirm syntax
#rsInsert2 <- dbSendQuery(devenvironment, query)       #insert query into database 
#RoadCover <- dbFetch(rsInsert2, n=-1)                    #fetch result, store in var dbRows
              #get count of number of instances the road team covered

x <- sum(dbRows$RoadClose > 0 & dbRows$Away_Covered>0)  #get number of times Away / Home Team Covered
n <- sum(dbRows$RoadClose > 0)                          #get number of total occurrences
#Based on sample results, analyze if bias toward home or road covering
which_side <- if (x/n > 0.5) { 'greater'} else {'less'}
AwayCoveredProp <- prop.test(x, n, p=0.5, alternative = "g" , conf.level=0.65, correct=FALSE) 
AwayCoveredLowerBound <- round(AwayCoveredProp$conf.int[1],2)
AwayCoveredUpperBound <- round(AwayCoveredProp$conf.int[2],2)
AwayCoveredMean <- round(AwayCoveredProp$estimate,2)
AwayCoveredp <- round(AwayCoveredProp$p.value,2)

#standard scatter plot - not using
#scatter <-plot(dbRows$RoadClose, dbRows$Spread_Error, main="Scatterplot Example", 
#     xlab="Road Closing Spread", ylab="Spread Error")
#abline(v=0, col="black")
#abline(h=0, col="black")

#----------------------------->
#create figures and plot in grid

#hist_top is histogram for CloseSpread values (continuous)
hist_top <- ggplot(dbRows, aes(RoadClose))+geom_histogram(binwidth=1)

#hist_right is histogram for Spread_Error (does not exist for 0<abs(10))
hist_right <- ggplot()+geom_histogram(aes(SpreadError), binwidth=1)+coord_flip()

empty <- ggplot()+geom_point(aes(100,100), colour="white")+
  theme(axis.ticks=element_blank(), 
        panel.background=element_blank(), 
        axis.text.x=element_blank(), axis.text.y=element_blank(),           
        axis.title.x=element_blank(), axis.title.y=element_blank())

#create summary table to summarize key statistics
SummaryTable <- data.frame(
  Statistic=c("Min", "Max", "u","95% p-val"), 
  Closing_Spread_Vals = c(minx, maxx, RoadCloseMean, 
                          #paste(c(RoadCloseLowerBound,RoadCloseUpperBound), collapse = " - ")),
                          RoadClosep),
  Spread_Error_Vals = c(miny, maxy, AwayCoveredMean, 
                        #paste(c(AwayCoveredLowerBound,AwayCoveredUpperBound), collapse = " - "))
                        AwayCoveredp)
  )
# Create a table plot
names(SummaryTable) <- c(season, 
                         "Closing'\nSpread",
                         "Spread'\nError"
                         )
# Set theme to allow for plotmath expressions
tt <- ttheme_default(base_size = 8, colhead=list(fg_params = list(parse=TRUE)))
tbl <- tableGrob(SummaryTable, rows=NULL, theme=tt)


#Create scatter plot
#plot data directly on scatter plot - not used anymore 
#txt <-data.frame(label = c("Skew",round(skew(dbRows$RoadClose),2), 
#                           "Skew", round(skew(SpreadError),2),
#                           "Mean", round(RoadCloseMean,2),
#                           "Conf Int", round(SpreadErrorMean-error,2),round(SpreadErrorMean+error,2)))
scatter <- ggplot()+geom_point(aes(dbRows$RoadClose, SpreadError))+ 
  #geom_text(data = txt, aes(x =c(rep(0,2),rep(maxx-3,2),maxx/3, maxx/3+5, maxx/3, maxx/3+5, maxx/3+10), 
  #                          y= c(maxy, maxy-5, 10,5,rep(4,2),rep(-3,3)), label=label)) +
  geom_vline(xintercept = RoadCloseMean) #+                 #plot road close mean on plot
  #geom_hline(yintercept = SpreadErrorMean)                 #plot spread error mean on plot

#Arrange four visuals in a grid
grid.arrange(hist_top, tbl, scatter, hist_right, ncol=2, nrow=2, 
             widths=c(4, 2), heights=c(2, 4))


error <- sd(SpreadError)*qnorm(0.825)/sqrt(length(SpreadError))
#t.test(x=SpreadError, y=NULL, alternative=c("two.sided", "less", "greater"), mu=0, paired=FALSE, var.equal=FALSE, conf.level=0.65)
print (AwayCoveredProp)

#dbDisconnect(devenvironment)
