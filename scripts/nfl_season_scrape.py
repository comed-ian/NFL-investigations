import nfl_season_scrape_fxs
from nfl_season_scrape_fxs import PFFscrape

year = []
index = 1

for i in range(2002,2019) :
    year.append(str(i))

for y in year:
    PFFscrape(index, y)
    index += 1
