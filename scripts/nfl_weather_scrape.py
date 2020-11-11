import nfl_weather_scrape_fxs
from nfl_weather_scrape_fxs import WeatherScrape

year = []
week = []
index = 1

for i in range(2009,2018) :
    year.append(str(i))

for i in range(1,18) :
    week.append(str(i))

for y in year:
    for w in week:
        WeatherScrape(index, y, w)
        index += 1
