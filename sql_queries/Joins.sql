USE devenvironment;

/*------------------------------------------------
----Add lookups to spreads table*/

DROP TABLE spreads_plus;
create table spreads_plus(
SELECT sp.Season, sp.Week, sp.AWAY as spAway, sp.HOME as spHome, sp.RoadOpen, sp.RoadClose, sp.TotalOpen, sp.TotalClose, l.Team as Away FROM spreads as sp 
left JOIN lookup AS l 
ON sp.AWAY= l.Abbreviation
)
;
SELECT * FROM spreads_plus WHERE abs(RoadClose) > 100;

DROP TABLE spreads_plus_2;
create table spreads_plus_2(
SELECT Season, Week, RoadOpen, RoadClose, TotalOpen, TotalClose, Away, l.Team as Home, if(RoadClose < 0, Away, l.team) as Favorite FROM spreads_plus as sp 
left JOIN lookup AS l 
ON sp.spHome = l.Abbreviation
)
;
SELECT * FROM spreads_plus_2 WHERE abs(RoadClose) > 100;

/*-----------------------------------------
---------Merge Spread Data with Season Results*/
DROP TABLE seasons_spreads_prelim;
create table seasons_spreads_prelim(
SELECT se.gamedatetext, sp.Season, sp.Week, se.GameTime, sp.Away as Away, sp.Home as Home, sp.Favorite, se.Winner, 
sp.RoadOpen, sp.RoadClose, sp.TotalOpen, sp.TotalClose, se.PtsWin, se.PtsLoss, 
se.Ptswin-se.PtsLoss as Margin_of_V
FROM season_added as se
JOIN spreads_plus_2 AS sp
ON (sp.Season = se.Season AND sp.Week = se.Week AND sp.Away = se.Away)
)
;
SELECT * FROM seasons_spreads_prelim;

/*finalize seasons spreads table by calculation the spread error - 
where a value <0 indicates away team beat spread by X pts, value >0 means away team needed X more pts to push*/
DROP TABLE seasons_spreads;
CREATE TABLE seasons_spreads (
SELECT gamedatetext, season, Week, Away, Home, Winner, RoadOpen, RoadClose, PtsWin, PtsLoss, Margin_of_V,   
if((RoadClose >0 AND Home=Winner), -(abs(RoadClose)-Margin_of_V),
   if( Away=Winner, -(RoadClose + Margin_of_V), -(RoadClose - Margin_of_V))) as Spread_Error
FROM seasons_spreads_prelim
)
;

SELECT * FROM seasons_spreads;
SELECT count(RoadClose) FROM seasons_spreads WHERE abs (Spread_Error) > 9 AND RoadClose > 0;
SELECT count(if  (Spread_Error < 0, TRUE, FALSE)) as Away_Covered from seasons_spreads WHERE abs(Spread_Error) > 9 AND RoadClose > 0 AND Spread_Error <0;
SELECT Home, Away, RoadClose, Margin_of_V, Spread_Error as Away_Covered from seasons_spreads WHERE abs(Spread_Error) > 8 AND RoadClose > 0 AND Season = 2013 AND Away ="Buffalo Bills";

/*-----------------------------------------
---------Merge O/U Data with Season Results*/
DROP TABLE seasons_OUs_prelim;
create table seasons_OUs_prelim(
SELECT sp.Season, sp.Week, se.GameTime, sp.Away as Away, sp.Home as Home, sp.Favorite, se.Winner, 
sp.RoadOpen, sp.RoadClose, sp.TotalOpen, sp.TotalClose, se.PtsWin, se.PtsLoss, 
se.Ptswin+se.PtsLoss as Total
FROM season_added as se
JOIN spreads_plus_2 AS sp
ON (sp.Season = se.Season AND sp.Week = se.Week AND sp.Away = se.Away)
)
;
SELECT * FROM seasons_OUs_prelim;

/*finalize seasons spreads table by calculation the O/U error - 
where a value <0 indicates under covered, value >0 means over covered*/
DROP TABLE seasons_OUs;
CREATE TABLE seasons_OUs (
SELECT season, Week, Away, Home, Winner, TotalClose, PtsWin, PtsLoss, Total,   
Total - TotalClose as OU_Error
FROM seasons_OUs_prelim
)
;
SELECT * FROM seasons_OUs;
