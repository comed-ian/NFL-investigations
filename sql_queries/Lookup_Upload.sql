USE devenvironment;

DROP TABLE lookup;

CREATE TABLE lookup (
	Abbreviation VARCHAR(3),
    AbbreviationAlt VARCHAR(3),
    Team VarChar(30),
    TeamName VARCHAR (20),
    Active VARCHAR(30)
    )
;

LOAD DATA LOCAL INFILE "C:/Users/Ian/Desktop/Python/lookup.csv" INTO TABLE lookup
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 LINES
;