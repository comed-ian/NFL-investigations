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

histogramComp <- function(df,columnName) {
  if (columnName == "RankDiff") {
    histdata <- DVOAhist(df)
  } else if (columnName == "DAVEDiff") {
    histdata <- DAVEhist(df)
  } else {
    histdata <- spreadHist(df)
  }
  
# set up proportion test assuming null hypothesis that % of occurrences should be 50 A cover, 50% H cover
propTest <- data.frame(pval <- 1:length(histdata$x), x <- 1:length(histdata$x))
for (i in seq_along(histdata$x)) {  #loop through all histogram counts
  if (histdata$fullhistcounts[i]>0) {  #run only if n!=0
    results <- prop.test(max(histdata$gthistcounts[i],histdata$lthistcounts[i]),
                         histdata$fullhistcounts[i],
                         alternative = "two.sided",
                         conf.level = 0.55,
                         correct = FALSE)

    propTest$pval [i] <- results$p.value        #extract p-val for future comparison
    propTest$x[i] <- histdata$x[i]  #match with RankDiff, in case is necessary
  } else { #if n==0, don't run and set default 0 val
    propTest$pval[i] <- 0
    propTest$x[i] <- histdata$x[i]
  }
}


# #old plot here -- plot(combohist, xlab = "<<  Away Fav / Home Fav >>", ylab = "<< Count Away Cov / Count Home Cov >>")
deltaData<-data.frame(counts <- histdata$combohistcounts,
                      x <- histdata$x)
gtandltData <-data.frame(ltcounts <- histdata$lthistcounts,
                         gtcounts <- histdata$gthistcounts,
                         x <- histdata$x)
colorScheme = rep(0,length(propTest$x))  #set up colorScheme variable to length of RankDiff variables (note indexing propTest$RankDiff vs totalhist$RankDiff b/c diff)
for (i in seq_along(propTest$x)) {
  colorScheme[i] <- if(propTest$pval[i]< 0.3) {   #if meets 75% prop test, set to green
    "green"
  }else if (propTest$pval[i]< 0.45){                 #if meets 60% prop test, set to yellow
    "yellow"
  }else {
    "gray"
  }
}

# plot bar chart with color scheme indicating confidence Away or Home Team will cover
gtandlt <- ggplot(gtandltData, aes(x, counts, ratio))+
  geom_col(aes(x=x, y = -ltcounts), fill = "palevioletred")+
  geom_col(aes(x=x, y = gtcounts), fill = "pink")+
  geom_hline(yintercept=0)

delta <- ggplot(deltaData, aes(x, counts, ratio))+
  geom_col(aes(x=x, y = counts), fill = colorScheme)

# with(deltaData, RankDiff[abs(counts)>15])

grid.arrange(gtandlt, delta, ncol=2, nrow=1,
             widths=c(1,1), heights=c(2))

propTest

}

DVOAhist <- function(DVOAdf) {
  #create histogram of count of spreaderror >0 - spreaderror < 0 for every RankDiff
  fullhist = hist(DVOAdf$RankDiff, seq(-32,32,by=1))  #create full histogram of all data
  # sum(fullhist$counts) #check total number of values (excludes nulls)
  gthist = with(subset(DVOAdf, spread_error>0), hist(RankDiff, breaks = fullhist$breaks))  #separate histogram when home team covers
  lthist = with(subset(DVOAdf, spread_error<0), hist(RankDiff, breaks = fullhist$breaks))  #separate histogram when away team covers
  combohist <- fullhist  #create combination hist first using full hist data (gets breaks, density, etc)
  combohist$counts = gthist$counts - lthist$counts  #override counts to get difference between home and away team frequency of covering
  histdata <- data.frame(x <- fullhist$breaks[2:length(fullhist$breaks)],
                         fullhistcounts <- fullhist$counts,
                         gthistcounts <-gthist$counts,
                         lthistcounts <-lthist$counts,
                         combohistcounts <- combohist$counts)
  histdata
}

DAVEhist <- function(DAVEdf) {
  #create histogram of count of spreaderror >0 - spreaderror < 0 for every RankDiff
  fullhist = hist(DAVEdf$DAVEDiff, seq(-32,32,by=1))  #create full histogram of all data
  # sum(fullhist$counts) #check total number of values (excludes nulls)
  gthist = with(subset(DAVEdf, spread_error>0), hist(DAVEDiff, breaks = fullhist$breaks))  #separate histogram when home team covers
  lthist = with(subset(DAVEdf, spread_error<0), hist(DAVEDiff, breaks = fullhist$breaks))  #separate histogram when away team covers
  combohist <- fullhist  #create combination hist first using full hist data (gets breaks, density, etc)
  combohist$counts = gthist$counts - lthist$counts  #override counts to get difference between home and away team frequency of covering
  combohist
  histdata <- data.frame(x <- fullhist$breaks[2:length(fullhist$breaks)],
                         fullhistcounts <- fullhist$counts,
                         gthistcounts <-gthist$counts,
                         lthistcounts <-lthist$counts,
                         combohistcounts <- combohist$counts)
  histdata
}

spreadHist <- function(spreaddf) {
  #create histogram of count of spreaderror >0 - spreaderror < 0 for every RankDiff
  fullhist = hist(spreaddf$roadclose, seq(-32,32,by=1))  #create full histogram of all data
  # sum(fullhist$counts) #check total number of values (excludes nulls)
  gthist = with(subset(spreaddf, spread_error>0), hist(roadclose, breaks = fullhist$breaks))  #separate histogram when home team covers
  lthist = with(subset(spreaddf, spread_error<0), hist(roadclose, breaks = fullhist$breaks))  #separate histogram when away team covers
  combohist <- fullhist  #create combination hist first using full hist data (gets breaks, density, etc)
  combohist$counts = gthist$counts - lthist$counts  #override counts to get difference between home and away team frequency of covering
  combohist
  histdata <- data.frame(x <- fullhist$breaks[2:length(fullhist$breaks)],
                         fullhistcounts <- fullhist$counts,
                         gthistcounts <-gthist$counts,
                         lthistcounts <-lthist$counts,
                         combohistcounts <- combohist$counts)
  histdata
  
}