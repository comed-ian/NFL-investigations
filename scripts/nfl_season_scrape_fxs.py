def PFFscrape(ind, year):

    from bs4 import BeautifulSoup
    from urllib.request import urlopen
    import re
    import csv

    y = year
    url = 'https://www.pro-football-reference.com/years/' + y + '/games.htm'

    site = urlopen(url).read()
    soup = BeautifulSoup(site, 'html.parser')

    #table = soup.find_all("table", attrs = {"class":re.compile("stats_table")})
    #not a tree object so using this instead:'
    header_row = soup.table.thead.tr
    table_body = soup.table.tbody
    table_row = table_body.tr

    #find column headers, class names and store in arrays
    headers_text = []
    headers_class = []
    headers_text_string = "Season,"
    for col in header_row.children:
        if col.name != None :
            headers_text.append(col.string)
            #one column header for boxscore link does not have a value, need to pass in "," for that column
            if col.string == None: headers_text_string += ','
            else: headers_text_string += col.string + ","

            headers_class.append(col['data-stat'])

    #find all values in table
    #Note that there are weekly header rows with a class of thead, the if statement removes those from the output
    #save output into csv file

    #if this is the first year being run, clear existing worksheet.  If not, append to exisiting data
    if ind == 1: w_a = 'w'
    else: w_a = 'a'

    with open('season.csv', w_a) as file:
        writer = csv.writer(file, delimiter =';', lineterminator='\n', quoting=csv.QUOTE_NONE)
        #write header row only if first iteration
        if ind == 1 : writer.writerow([headers_text_string])

        for index, child in enumerate(table_body.children):
            if child.name != None:
                output_row = year + ","
                if not (child.has_attr('class') and child['class'] == ["thead"]):
                    for cell in child.children:
                        #blank cells for home team winners (no @, just  blank)
                        if cell.string == None: output_row += ","
                        elif cell.has_attr('data-stat') and cell['data-stat'] == 'game_date' and cell.string != "Playoffs":

                            #for some reason playoff games have 'zz#' in their data_stat field. Adjust date accordingly
                            test = cell['csk']
                            if test.find('zz') == 0 :
                                day_index = cell.string.rfind(' ')
                                day = cell.string[day_index+1:day_index+3]
                                if cell.string.find('January') == 0 :
                                    day = str("1/" + day + "/" + str(int(year)+1))
                                elif cell.string.find('February') == 0 :
                                    day = str("2/" + day + "/" + str(int(year)+1))
                                output_row += day + ","
                            else : output_row += cell['csk'] + ","

                        #format times from ##:##PM or #:##PM or #:##AM to ##:##:00
                        elif cell.has_attr('data-stat') and cell['data-stat'] == 'gametime' and cell.string != "Playoffs":
                            if cell.string.rfind('PM') < 0 :
                                game_time = cell.string[0:cell.string.find('AM')] + ":00"
                            else :
                                hour = int(cell.string[0:cell.string.find(':')])
                                if hour !=12 : hour +=  12 #add 12 to get into military time so long as it wasn't a noon game EST (Thanksgiving)
                                game_time = str(hour) + ":"  + cell.string[cell.string.find("PM")-2:cell.string.find("PM")] + ":00"
                            output_row += game_time + ","

                        else: output_row += cell.string + ","

                #for some reason the .children process yields blank rows, filter out
                #along with single "playoff" header row that is not labeled with class "thead"
                if not output_row == (year + ",") and not output_row == (year + ",,,Playoffs,,,,,,,,,,,,") : writer.writerow([output_row])

    print ("Year " + year + " complete")

#OPTION FOR PRINTING OUT COLUMN NAMES WITH VALUES
#for index2, cell in enumerate(child.children):
#    print (index2, headers_class[index2], cell.string)
