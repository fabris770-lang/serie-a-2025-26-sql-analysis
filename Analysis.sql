/* 
Q1 — Offensive efficiency by team based on possession. Which teams have a very quick and effective attack?
*/

SELECT Squad, Poss, Gls, round(Gls/Poss,2) as Efficiency from Teams 
order by 4 desc;


/* 
Q2 — The most productive midfielder 
Among midfielders with at least 10 appearances, who has the best goal+assist ratio per 90 minutes?
*/

SELECT Player, CAST(Replace("Min",',','') as INT)/"MP" as Min_per_game, Pos, MP, "G+A_90", "G+A", "G+A-PK_90", PK FROM Players
WHERE Pos like '%MF%' AND MP >= 10 and "G+A" >=5
order by "G+A_90" desc
limit 20;

/* 
Q3 — Under-23 talents underutilized 
Players born after 2002, more than 5 goals or assists, fewer than 20 matches played. 
Who is playing little despite the numbers?
*/

SELECT Player, Squad, CAST(Replace("Min",',','') as INT)/"MP" as Min_per_game, Pos, MP,Starts, "G+A_90", "G+A", CAST(substr(Age,1,2) as INT) as age FROM Players
WHERE 
CAST(substr(Age,1,2) as INT)<=23 and
MP<20 and "G+A">5 
order by "G+A_90" desc;

/* 
Q4 — Penalty weight on Forwards' efficiency 
Which forwards depend most on penalties?
Rank by the difference between Gls and G-PK — who disappears if you remove penalties?
*/

SELECT Player, Squad, Gls as Goals, PK as Penalties, "G-PK", round((CAST(PK as REAL)/CAST(Gls as REAL)), 2) as "Penalties_%" FROM Players
WHERE Pos = 'FW' AND
Gls >=3 AND
PK > 0
order by 
"penalties_%" desc;

/* 
Q5 — Age in the league. How young is each team? Not only in terms of general age but also in terms of contribution by age.
*/

-- PART 1 - Rank the 20 teams by average roster age. Do younger teams perform worse?
SELECT 
t.Squad, round(avg(CAST(substr(p.Age,1,2) as REAL)),2) as avg_age, t."G+A" 
from Players as p
LEFT JOIN  Teams as t on p.Squad = t.Squad
Group by t.Squad
order by avg_age;

-- PART 2 - Which age category of players contributes the most to their team?

-- to understand cut-off ages for later categorizing players by age
SELECT ntile (4) over (order by cast(substr(age,1,2) as real)) as quartile, cast(substr(age,1,2) as real)
from Players;

-- Cut-off ages are 23 - 26 - 29



SELECT p.Squad, 
CASE WHEN CAST(SUBSTR(p.Age,1,2) AS REAL) < 24 then 'Young'
WHEN CAST(SUBSTR(p.Age,1,2) AS REAL) >= 24 and CAST(SUBSTR(p.Age,1,2) as REAL) <= 26 then 'Prime'
WHEN CAST(SUBSTR(p.Age,1,2) AS REAL) > 26 and CAST(SUBSTR(p.Age,1,2) AS REAL)<= 29 then 'Top'
ELSE 'Old' END as player_category,
count(p.Player) as n_players, sum(p."G+A"), t."G+A", 
round(sum(CAST(p."G+A" as real))/CAST(t."G+A"as REAL),2) as "categoryG%"


from Players as p


LEFT JOIN Teams as t on p.Squad = t.Squad
group by player_category, p.Squad
order by t."G+A" DESC, t.Squad DESC;

/* 
Q6 — The most important offensive player for their team 
For each team, who contributed the highest percentage of the team's total goals? 
*/

SELECT * FROM (
SELECT p.Player, t.Squad, 
CAST(t.Gls as REAL) as Team_Gls, 
CAST(p.Gls as REAL) as Player_Gls, 
round(CAST(p.Gls as REAL)/CAST(t.Gls as REAL), 2) as "gls%", 
row_number () over(PARTITION by t.Squad order by	CAST(p.Gls as REAL)/CAST(t.Gls as REAL) DESC) as internal_rank 
from Teams as t

LEFT JOIN Players as p on t.Squad = p.Squad)

where internal_rank <= 3
order by Squad;


/* 
Q7 — Discipline by role 
What is the average yellow cards per role? And which players are significantly above their role average?
*/

with by_role as (
SELECT p.Pos, round(avg(CAST(p.CrdY as real)),2) as Y_by_Role from Players as p
group by p.Pos)


SELECT * FROM (
SELECT p.Pos, p.Y_by_Role, pl.Player, pl.CrdY, 
CAST (pl.CrdY as REAL)-p.Y_by_Role as PLAYER_vs_AVG, 
round(CAST (pl.CrdY as REAL)/p.Y_by_Role,2) as ratio 
FROM by_role as p
LEFT JOIN Players as pl on p.Pos = pl.Pos)


where ratio >3
order by PLAYER_vs_AVG DESC;

/* 
Q8 — Dominant nations 
Which nationalities contribute the most goals+assists in total in Serie A? Top 10
*/

SELECT substr (Nation, instr(Nation, ' ')+1, 3) as NAT, sum("G+A") as contribution from Players
GROUP by NAT
HAVING sum("G+A") > 0
ORDER by contribution DESC
limit 10;

/* 
Q9 — Starters vs substitutes performance
Who has more goals+assists per 90 minutes between those who almost always start (Starts/MP > 0.8)
and those who almost always come off the bench (Starts/MP < 0.3)?
*/

SELECT 
CASE 
WHEN (CAST (Starts as REAL)/CAST (MP as REAL)) > 0.8 THEN 'Starter'
WHEN CAST (Starts as REAL)/CAST (MP as REAL) < 0.3 THEN 'Substitute'
ELSE 'Regular'
END as Category,
Pos, 
count(Player) as N_players,
round(avg("G+A-PK_90"),2) as Efficiency
from Players
WHERE Pos <> 'GK' AND Pos <> 'DF' and Pos <> 'DF,MF'
GROUP by	Pos, Category
ORDER by	Pos, Category;

/* 
Q10 — Offensive index based on role efficiency and total offensive contribution.
Which players overperform compared to their role average, and do so with consistency?
*/

WITH averages as (SELECT round(avg("G+A-PK_90"),2) as role_efficiency, 
Pos, 
round(avg(Age),2) as age,
round(avg(CAST(Replace("Min",',','') as real))) as Minutes from Players
GROUP by Pos)


SELECT * FROM (SELECT p.Player, 
p."G+A-PK_90" as efficiency, 
CAST(Replace(p."Min",',','') as real) as minutes, 
p.Pos, 
round(p."G+A-PK_90"*(CAST(Replace(p."Min",',','') as real)/a.minutes),2) as dependability,
round((round(p."G+A-PK_90"*(CAST(Replace(p."Min",',','') as real)/a.minutes),2)-a.role_efficiency)/a.role_efficiency,2) as score from Players as p


LEFT JOIN averages as a on a.Pos = p.Pos)


WHERE score is NOT NULL
ORDER by pos, score DESC
limit 20;
