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
source("MySQL/DVOA_DAVE_fxs.R") #import functions 


#select season, if running aggregate data, set to "All".  Otherwise, enter season as int
#season <- "All"
#sql_insert <- if (season != "All"){ paste("AND Season =",season)} else {}

#--------------------------------->
#connect to database--------------
devenvironment <- dbConnect(RMariaDB::MariaDB(), user='root', password='', 
                            dbname='devenvironment', host='localhost', port=3308)

#list tables to confirm database connection
dbListTables(devenvironment)

#query SQL Tabl2
query <- paste("SELECT *, AwayRank-HomeRank as RankDiff, AwayDave-HomeDave as DAVEDiff from DVOA_seasons_spreads where abs(spread_error) >2")


rsInsert <- dbSendQuery(devenvironment, query)       #insert query into database 
dbRows <- dbFetch(rsInsert, n=-1)                    #fetch result, store in var dbRows

#convert RankDiff, DAVEDiff into integer
temp <- as.integer(dbRows$RankDiff)
dbRows$RankDiff <- temp
temp <- as.integer(dbRows$DAVEDiff)
dbRows$DAVEDiff <- temp

#set x equal to the dataframe column to analyze via histogram.  Ex: RankDiff for DVOA, DAVEDiff for DAVE, spread for roadclose
x <- "RankDiff"

histdata <- histogramComp(dbRows, x)  #call function to analyze variable by histogram, pass in data frame and column to be analyzed
histdata
#disconnect from database
dbDisconnect(devenvironment)

