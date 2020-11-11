from bs4 import BeautifulSoup
from urllib.request import urlopen
import re
import csv

def RowScrape (row, s, w):
    with open('spreads.csv', 'a') as file:
        writer = csv.writer(file, delimiter =';', lineterminator='\n', quoting=csv.QUOTE_NONE)

        output_row = s + "," + w + ","        #reset output_row for new row

        if row != '\n':
            #find away and home team from first cell in row (format is AWY ## @ HME ##)
            away_index = row.td.string.strip().find(' ')
            home_index = row.td.string.strip().rfind(' ')
            away = row.td.string.strip()[0:away_index]
            home = row.td.string.strip()[home_index-3: home_index].strip()
            output_row += away +"," + home + ","

            for cell in row.td.next_siblings :
                if cell != '\n':
                    if cell.span != None : output_row += str(cell.span.contents[0])+ ","
                    else:
                        output_row += cell.string.strip() + ","
        #print (output_row)
        if output_row != s + "," + w + "," :
            writer.writerow([output_row])
        #    print ("Written")

############################################################################################

def SeasonScrape(table):
    if table.name != None:

        #find season and week from caption, format 'NFL Week # Point Spreads #### Opening and Closing NFL Point Spreads' where #### is the season
        season_index = table.caption.string.find('20')
        season = table.caption.string[season_index:season_index+4]
        week_index = table.caption.string.find('Week')
        week = table.caption.string[week_index+5:week_index+7].strip()
        print("Season " + season + " done")

        #loop through rows.  Start with first then cycle through next_siblings
        RowScrape(table.tbody.tr, season, week)
        for r in table.tbody.tr.next_siblings:
            RowScrape(r, season, week)

#########################################################################################

def HeaderWriter (soup):
    output_row = "Season,Week,"

    with open('spreads.csv', 'w') as file:
        writer = csv.writer(file, delimiter =';', lineterminator='\n', quoting=csv.QUOTE_NONE)

        #write header
        header_row = soup.table.thead.tr
        for header_cell in header_row.children:
            if header_cell.name != None:
                if header_cell.string.strip() == "Road v Home": output_row += "Away,Home,"
                else : output_row += header_cell.string.strip() +","
        if output_row != "" : writer.writerow([output_row])
        print ("header done")
