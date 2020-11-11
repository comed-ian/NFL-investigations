def WeatherScrape(ind, year, week):

    from bs4 import BeautifulSoup
    from urllib.request import urlopen
    import re
    import csv

    y = year
    w = week
    #for some reason the 2010 season has a -2 at the end of each week
    if year == "2010" : url = 'http://www.nflweather.com/en/week/' + y + '/week-' + w + '-2/'
    else: url = 'http://www.nflweather.com/en/week/' + y + '/week-' + w + '/'

    site = urlopen(url).read()
    soup = BeautifulSoup(site, 'html.parser')

    #table = soup.find_all("table", attrs = {"class":re.compile("stats_table")})
    #not a tree object so using this instead:'
    header_row = soup.table.thead.tr
    table_body = soup.table.tbody
    table_row = table_body.tr

    # find column headers and store in array
    headers_text = []
    headers_text_string = "Year,Week,"
    for col in header_row.children:
        if col.name != None :
            headers_text.append(col.string)
            if col.string == None: headers_text_string += ','
            else: headers_text_string += col.string + ","



    #-------------------------->
    #find all values in table
    #save output into csv file

    #if this is the first year being run, clear existing worksheet.  If not, append to exisiting data
    if ind == 1: w_a = 'w'
    else: w_a = 'a'
    #
    #rint (table_body)

    with open('weather.csv', w_a) as file:
        writer = csv.writer(file, delimiter =';', lineterminator='\n', quoting=csv.QUOTE_NONE)
        #write header row only if first iteration
        if ind == 1 : writer.writerow([headers_text_string])

        for index, child in enumerate(table_body.children):
             if child.name != None
                #first two columns shold include year then week
                 output_row = y + ',' + w + ','
        #         if not (child.has_attr('class') and child['class'] == ["thead"]):
                 for cell in child.children:

        #                 #blank cells for home team winners (no @, just  blank)
                    if cell.name != None:
                        if cell.string == None:
#                           #some cells have children that contain the string, iterate down using cell.children on these items
                            #set a placeholder that appends all children and children of children --> text in links are embedded a layer down
                            placeholder = ""
                            for cell_child in cell.children :
                                if cell_child.string != None and cell_child.string.strip() != '':
                                    placeholder += cell_child.string.strip()
                            if placeholder != "": output_row += placeholder + ","
                        else:
                            text_input = cell.string.strip()
                            #some weather forecasts have commas that screw everything up, replace with random string
                            text_input = text_input.replace(",", "---")
                            output_row += text_input + ","

                 if not output_row == "" : writer.writerow([output_row])

    print ("Year " + y + " Week " + w + " complete")
