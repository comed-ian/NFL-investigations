import nfl_spread_scrape_fxs
from nfl_spread_scrape_fxs import RowScrape
from nfl_spread_scrape_fxs import HeaderWriter
from nfl_spread_scrape_fxs import SeasonScrape
from bs4 import BeautifulSoup
from urllib.request import urlopen
import re
import csv
import time


def SpreadScraper(index, week):

    w = week
    url = 'https://thefootballlines.com/nfl-lines/week-' + w

    site = urlopen(url).read()
    soup = BeautifulSoup(site, 'html.parser')

    #write header only for first iteration
    if index ==1 : HeaderWriter(soup)

    #loop through tables to find all season data.  Need to start with first season, then loop through sibling tables
    SeasonScrape(soup.table)
    for table in soup.table.next_siblings:
        SeasonScrape (table)


################# RUN CODE BELOW ################################################

week = []
index = 1

for i in range(1,18) :
    week.append(str(i))

for w in week:
    SpreadScraper(index, w)
    index += 1
