USE spreadtesting;
DROP TABLE season_added;

CREATE TABLE season_added (
	Season INT,
    Week INT,
    DayofWeek VARCHAR(3),
    GameDateText VARCHAR(10),
    GameTime TIME,
    Winner VARCHAR (30),
    Away VARCHAR(30),
    VsAt VARCHAR(2),
    Loser VARCHAR(30),
    Boxscore VARCHAR(8),
    PtsWin INT,
    PtsLoss INT,
    YdsWin INT,
    TOWin INT,
    YdsLoss INT,
    TOLoss INT,
    GameDate date
    )
;

LOAD DATA LOCAL INFILE "C:/Users/Ian/Desktop/Python/season_added.csv" INTO TABLE season_added
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 LINES
;

UPDATE season SET GameDate = STR_TO_DATE(GameDateText, '%Y-%m-%d');

/*Vet number of games per team per year*/
SELECT Season, Away, COUNT(Away) FROM spreadtest WHERE Week>0  GROUP BY Season, Away ORDER BY Season, COUNT(Away) ASC;
SELECT Season, Home, COUNT(Home) FROM spreadtest WHERE Week>0  GROUP BY Season, Home ORDER BY Season, COUNT(Home) ASC;

/*spreadtesting.cvd7x6e7znft.us-east-1.rds.amazonaws.com*/