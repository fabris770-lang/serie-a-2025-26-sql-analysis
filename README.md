Serie A 2025-2026 Season - Analysis for a sport director

The goal of the analysis is to tell the Serie A 2025-2026 season through a different perspective. I investigated the data through 10 questions I wrote, quantifying the impacts of common stats (goals and assists) through relative metrics in order to read them in a new way.

In order to do this, I have downloaded two tables of the 2024-2025 Serie A season from FBref: one contains stats regarding team performances and one individual players performances. The two tables are then joined based on team name.

These two tables had some columns that needed cleaning:
- the field "Nation" required me to remove a variable length prefix       --> "substr (Nation, instr(Nation, ' ')+1,3)"
- the value for "minutes played" was stored as text with comma separators --> "CAST(replace("Min",',','') as INT)"
- "Age" was formatted as years-days                                       --> "CAST(SUBSTR(Age,1,2) AS REAL"


Here below the 10 questions:

Q1 — Offensive efficiency by team based on possession. Which teams have a very quick and effective attack?

Q2 — The most productive midfielder 
Among midfielders with at least 10 appearances, who has the best goal+assist ratio per 90 minutes?

Q3 — Under-23 talents underutilized 
Players born after 2002, more than 5 goals or assists, fewer than 20 starts. 
Who is playing little despite the numbers?

Q4 — Penalty weight on Forwards' efficiency 
Which forwards depend most on penalties?
Rank by the difference between Gls and G-PK — who disappears if you remove penalties?

Q5 — Age in the league. How young is each team? Not only in terms of general age but also in terms of contribution by age.
   PART 1 - Rank the 20 teams by average roster age. Do younger teams perform worse?
   PART 2 - Which age category of players contributes the most to their team?

Q6 — The most important offensive player for their team 
For each team, who contributed the highest percentage of the team's total goals? 

Q7 — Discipline by role 
What is the average yellow cards per role? And which players are significantly above their role average?

Q8 — Dominant nations 
Which nationalities contribute the most goals+assists in total in Serie A? Top 10

Q9 — Starters vs substitutes performance
Who has more goals+assists per 90 minutes between those who almost always start (Starts/MP > 0.8)
and those who almost always come off the bench (Starts/MP < 0.3)?

Q10 — Offensive index based on role efficiency and total offensive contribution.
Which players overperform compared to their role average, and do so with consistency?


KEY FINDINGS

From Q5 we see how differently Inter and Como's squads were built: 50% of goals and assists scored by Como came from players younger than 23 while Inter scored 80% of its goals and assists with players older than 27.

Q10 gives an interesting perspective on players offensive output relative to their role. In this particular ranking we find Bremer at number 1, with his average of 0.29 goals+assists every 90 minutes he's by far the most efficient defender, 4x his role average. Moreover he plays above average minutes per game, which further increases his offensive effectiveness throughout a season.
This metric is heavily influenced by role, further investigation can be done to improve its output's quality.

In Q8 we can see the impact of foreign players, in particular French (132 G+A) and Argentinian (110 G+A): both nationalities have scored more than 1/4 of the goals and assists scored by Italian players (414 G+A). Moreover Italy's share only accounts for 42% of the offensive output from the top 10. 

