USE spreadtesting;
DROP TABLE spreads;

CREATE TABLE spreads (
	Season INT,
    Week INT,
    AWAY VARCHAR (3),
    HOME VARCHAR(3),
    GameDateText VARCHAR(10),
	RoadOpen INT,
    RoadClose INT,
    TotalOpen INT,
    HomeOpen INT,
    HomeClose INT,
    TotalClose INT,
    GameDate DATE
    )
;

LOAD DATA LOCAL INFILE "C:/Users/Ian/Desktop/Python/spreads.csv" INTO TABLE spreads
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 LINES
;

UPDATE spreads SET GameDate = STR_TO_DATE(GameDateText, '%Y-%m-%d');



/*Vet number of games per team per year*/
SELECT Season, Away, COUNT(Away) FROM spreadtest WHERE Week>0  GROUP BY Season, Away ORDER BY Season, COUNT(Away) ASC;
SELECT Season, Home, COUNT(Home) FROM spreadtest WHERE Week>0  GROUP BY Season, Home ORDER BY Season, COUNT(Home) ASC;

/*spreadtesting.cvd7x6e7znft.us-east-1.rds.amazonaws.com*/