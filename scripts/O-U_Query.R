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
season <- "All"
sql_insert <- if (season != "All"){ paste("AND Season =",season)} else {}

#--------------------------------->
#connect to database--------------
devenvironment <- dbConnect(RMariaDB::MariaDB(), user='root', password='', 
                            dbname='devenvironment', host='localhost', port=3308)

#list tables to confirm database connection
dbListTables(devenvironment)

#query SQL Table - pull all records with OU_Error> 9 (blowouts)
query <- paste("SELECT * from seasons_ous WHERE TotalClose>10 AND abs(OU_Error) > 9",sql_insert,";")
#print(query)    #print query to confirm syntax

rsInsert <- dbSendQuery(devenvironment, query)       #insert query into database 
dbRows <- dbFetch(rsInsert, n=-1)                    #fetch result, store in var dbRows

#convert Spread_Error data from int64 to int, int64 cannot plot in histogram
#SpreadError <- as.integer(dbRows$Spread_Error)

#Get relevant statistics
#minxblowout <- round(min(dbRows$TotalClose),2)
#minyblowout <- round(min(dbRows$OU_Error),2)
#maxxblowout <- round(max(dbRows$TotalClose),2)
#maxyblowout <- round(max(dbRows$OU_Error),2)
#totalmeanblowout <- round(mean(dbRows$TotalClose),2)

#run proportion test on whether biased toward positive or negative spread
x <- sum(dbRows$RoadClose > 0)  #get number of times Away / Home Team Covered
n <- length(dbRows$RoadClose)   #get number of total occurrences

#Based on sample results, analyze if bias toward home or road covering
which_side <- if (x/n > 0.5) { 'greater'} else {'less'}
RoadCloseProp <- prop.test(x, n, p=0.5, alternative = "g" , conf.level=0.95, correct=FALSE) 
RoadCloseLowerBound <- round(RoadCloseProp$conf.int[1],2)
RoadCloseUpperBound <- round(RoadCloseProp$conf.int[2],2)
RoadCloseMean <- round(RoadCloseProp$estimate,2)
RoadClosep <- round(RoadCloseProp$p.value,2)

#check if over or under is covering in this biased situation
x <- sum(dbRows$RoadClose > 0 & dbRows$OU_Error>0)  #get number of times Away / Home Team Covered
n <- sum(dbRows$RoadClose > 0)                          #get number of total occurrences
#Based on sample results, analyze if bias toward home or road covering
which_side <- if (x/n > 0.5) { 'greater'} else {'less'}
AwayCoveredProp <- prop.test(x, n, p=0.5, alternative = "g" , conf.level=0.95, correct=FALSE) 
AwayCoveredLowerBound <- round(AwayCoveredProp$conf.int[1],2)
AwayCoveredUpperBound <- round(AwayCoveredProp$conf.int[2],2)
AwayCoveredMean <- round(AwayCoveredProp$estimate,2)
AwayCoveredp <- round(AwayCoveredProp$p.value,2)
x/n
AwayCoveredProp
scatter <- ggplot()+geom_point(aes(dbRows$RoadClose, dbRows$OU_Error))
scatter
