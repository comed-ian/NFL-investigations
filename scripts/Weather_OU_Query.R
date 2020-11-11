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

#query SQL Table - pull all records with Spread_Error > 9 (blowouts)
query <- paste("SELECT *, if (INSTR(Forecast, 'rain')> 0,1,0) as DiditRain, if (INSTR(Forecast, 'snow')> 0,1,0) as DiditSnow from weather_ous WHERE abs(OU_error) > 9 AND TotalClose>10 ",sql_insert,";")
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

#count key metrics
xrainblowout <- sum(dbRows$DiditRain > 0)  #get number of times it rained during an O/U blowout
xsnowblowout <- sum(dbRows$DiditSnow > 0)  #get number of times it snowed during an O/U blowout
xrainblowoutover <- sum(dbRows$DiditRain > 0  & dbRows$OU_Error > 9)
xrainblowoutunder <- sum(dbRows$DiditRain > 0  & dbRows$OU_Error < 9)
xsnowblowoutover <- sum(dbRows$DiditSnow > 0  & dbRows$OU_Error > 9)
xsnowblowoutunder <- sum(dbRows$DiditSnow > 0  & dbRows$OU_Error < 9)
nblowout <- sum(dbRows$TotalClose > 0)     #get number of O/U blowouts
nblowoutover <- sum(dbRows$TotalClose > 0 & dbRows$OU_Error > 9)
nblowoutunder <- sum(dbRows$TotalClose > 0 & dbRows$OU_Error < 9)

#query entire table to find ratio of rainy and snowy games in non-blowouts
#query SQL Table - pull all records with Spread_Error > 9 (blowouts)
query <- paste("SELECT *, if (INSTR(Forecast, 'rain')> 0,1,0) as DiditRain, if (INSTR(Forecast, 'snow')> 0,1,0) as DiditSnow from weather_ous WHERE TotalClose>10 ",sql_insert,";")
#print(query)    #print query to confirm syntax

rsInsert <- dbSendQuery(devenvironment, query)       #insert query into database 
dbRows <- dbFetch(rsInsert, n=-1)                    #fetch result, store in var dbRows

#count key metrics
xraintotal <- sum(dbRows$DiditRain > 0)  #get number of times it rained in all games
xrainover <- sum(dbRows$DiditRain > 0  & dbRows$OU_Error > 0)
xrainunder <- sum(dbRows$DiditRain > 0  & dbRows$OU_Error < 0)
xsnowtotal <- sum(dbRows$DiditSnow > 0)  #get number of times it snowed in all games
xsnowover <- sum(dbRows$DiditSnow > 0  & dbRows$OU_Error > 0)
xsnowunder <- sum(dbRows$DiditSnow > 0  & dbRows$OU_Error < 0)
n <- sum(dbRows$TotalClose > 0)     #get number of O/U blowouts
nover <- sum(dbRows$TotalClose > 0 & dbRows$OU_Error > 0)
nunder <- sum(dbRows$TotalClose > 0 & dbRows$OU_Error < 0)

xrainblowout / nblowout
xraintotal/n
xsnowblowout / nblowout
xsnowtotal / n

nblowout
n


xrainblowoutover
xrainblowoutunder
xrainblowout
xsnowblowoutover
xsnowblowoutunder
xsnowblowout

xrainover
xrainunder
xraintotal
xsnowover
xsnowunder
xsnowtotal
ggplot(dbRows, aes(OU_Error))+geom_histogram(binwidth=1)
describe(dbRows$OU_Error)
