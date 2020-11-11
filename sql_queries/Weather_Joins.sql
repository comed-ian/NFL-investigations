USE devenvironment;


/*Add team names and abbreviations to weather table*/
DROP TABLE weather_plus;
create table weather_plus(
SELECT w.Season, w.Week, w.Away, w.Home, w.Forecast, w.Extended_Forecast, w.Wind, l.Team,
SUBSTR(Forecast, 1, INSTR(w.Forecast, 'f')-1) as Temp, SUBSTR(w.Wind, 1, INSTR(w.Wind, 'm')-1) as WindMPH FROM weather as w 
left JOIN lookup AS l 
ON w.Away= l.TeamName
)
;
SELECT * from weather_plus;
SELECT *, INSTR(Forecast, 'f ') from weather_plus;
SELECT *, SUBSTR(Forecast, 1, INSTR(Forecast, 'f')-1) as Temp, SUBSTR(Wind, 1, INSTR(Wind, 'm')-1) as WindMPH from weather_plus WHERE Forecast <> 'Dome';
SELECT * from weather_plus WHERE Forecast LIKE ("%rain%");

DROP TABLE weather_OUs;
CREATE table weather_OUs(
SELECT s.season, s.Week, s.Away, s.Winner, s.TotalClose, s.PtsWin, s.PtsLoss, s.Total, s.OU_Error,
w.Forecast, w.Extended_Forecast, w.Temp, w.WindMPH FROM seasons_OUs as s
LEFT JOIN weather_plus as w
ON (s.Season = w.Season and s.Week = w.Week and s.Away = w.Team)
);

SELECT Week, Count(Week), if (INSTR(Forecast, "rain")> 0,1,0) as DiditRain, if (INSTR(Forecast, "snow")> 0,1,0) as DiditSnow FROM weather_OUs WHERE OU_Error < -9 AND Forecast LIKE("%rain%") GROUP BY Week;