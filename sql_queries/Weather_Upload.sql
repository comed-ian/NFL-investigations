USE devenvironment;

DROP TABLE weather;

CREATE TABLE weather (
	Season INT,
    Week INT,
    Away VARCHAR (20),
    At VARCHAR (1),
    Home VARCHAR(20),
    Result VARCHAR(10),
	TV_station VARCHAR(10),
    Forecast VARCHAR(100),
    Extended_Forecast VARCHAR(400),
    WIND VARCHAR(10),
    Details VARCHAR(10)
    )
;

LOAD DATA LOCAL INFILE "C:/Users/Ian/Desktop/Python/weather.csv" INTO TABLE weather
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 LINES
;

