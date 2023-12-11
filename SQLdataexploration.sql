/* select *
from CovidDeath
order by 3,4 */

/* select *
from CovidVaccinations
order by 3,4 */

/* select data need to be used */
select location, date, total_cases, new_cases, total_deaths, population
from CovidDeath
order by 1,2

/* total cases vs total death */
/*the probabiliy of dying if infected covid in your country  */
Select location, date, total_cases,total_deaths, 
(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS Deathpercentage
/* from CovidDeath
 */
 where continent is not null
 order by 1,2

/* total cases vs population */
/* percentage of population got covid */
Select location, date, total_cases, population, 
(CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0)) * 100 AS InfectedPercentage
from CovidDeath
/* where location like 'Be%m'
 */
 where continent is not null
 order by 1,2


 /* countries with the hightest infectin rate  */
Select location, MAX(total_cases) as HighestInfectionCount, population, 
MAX((CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0))) * 100 AS InfectedPercentage
from CovidDeath
where continent is not null
group by location, population
order by 4 DESC

/* countries with the highest death rate */
/* change data type, cast(total_deaths as int) */
Select location, MAX(total_deaths) as HighestDeathCount/* , 
MAX((CONVERT(float, total_deaths) / NULLIF(CONVERT(float, population), 0))) * 100 AS TotalDeathRate */
from CovidDeath
where continent is not null
group by location
order by 2 DESC

/* Continent highest death count */
Select continent, MAX(total_deaths) as HighestDeathCount/* , 
MAX((CONVERT(float, total_deaths) / NULLIF(CONVERT(float, population), 0))) * 100 AS TotalDeathRate */
from CovidDeath
where continent is NOT null
group by continent
order by 2 DESC

/* show the continent with the highest death counnt */
Select continent, MAX(total_deaths) as TotalDeathCount/* , 
MAX((CONVERT(float, total_deaths) / NULLIF(CONVERT(float, population), 0))) * 100 AS TotalDeathRate */
from CovidDeath
where continent is NOT null
group by continent
order by 2 DESC


/* Global numbers */
Select date, SUM(new_cases) as GlobalInfectionCount, sum(new_deaths) as GloableDeathCount, (sum(cast(new_deaths as float))/ SUM(cast(new_cases as float)))*100 as DeathPercentage
--,total_deaths, (CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS Deathpercentage
from CovidDeath
where continent is not null
GROUP By date
order by 1, 2, 3

/* Total Death rate across wolrd and whole time frame */
Select SUM(new_cases) as GlobalInfectionCount, sum(new_deaths) as GloableDeathCount, (sum(cast(new_deaths as float))/ SUM(cast(new_cases as float)))*100 as DeathPercentage
--,total_deaths, (CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS Deathpercentage
from CovidDeath
where continent is not null
--GROUP By date
order by 1, 2, 3



/* Compared with group by, over (partition by) do not reduce the number of rows in the result set, instead it shows results of aggregate function (SUM, MAX, AVG)
for each partition.

In this case, it is partitioned by location, and new columns shows the cumulated count for the location by date and location  */
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 sum(new_vaccinations) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVacinated
-- ,(RollingPeopleVacinated/population)*100
from CovidDeath dea
join CovidVaccinations vac
on dea.location = vac.location
 and dea.date =vac.date
 where dea.continent is not null
 order by 1,2,3


/* Use cte */
/* Common table expression: a temporary table used to reference orginal table. 
If the original table contains too many columns, and we only need few, can make cte containing the required column only */
/* If the number of column in cte is different from number of column in the code, it will give error */
With PopvsVac (Continent, location, date, population, new_vaccinations, RollingPeopleVacinated)
as
( select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 sum(new_vaccinations) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVacinated
-- ,(RollingPeopleVacinated/population)*100
from CovidDeath dea
join CovidVaccinations vac
on dea.location = vac.location
 and dea.date =vac.date
 where dea.continent is not null
 --order by 1,2,3
 )
 select *, (RollingPeopleVacinated/population)*100
 from PopvsVac
 /* cumulated percent of population who got vaccinated in the specified location and data */


 /* Temp Table */
Drop table if EXISTS
Create table #PercentPopulationVaccinated
(
    continent nvarchar(50),
    location nvarchar(50),
    date datetime,
    population  float,
    new_vaccinations float,
    RollingPeopleVacinated float

)
Insert into  #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 sum(new_vaccinations) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVacinated
-- ,(RollingPeopleVacinated/population)*100
from CovidDeath dea
join CovidVaccinations vac
on dea.location = vac.location
 and dea.date =vac.date
 where dea.continent is not null
 --order by 1,2,3

  select *, (RollingPeopleVacinated/population)*100
 from #PercentPopulationVaccinated


/* Create view to store data for later visualizations */
/* View is a virtual table based on the result-set of sql statement */
create view PercentPopulationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 sum(new_vaccinations) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVacinated
-- ,(RollingPeopleVacinated/population)*100
from CovidDeath dea
join CovidVaccinations vac
on dea.location = vac.location
 and dea.date =vac.date
 where dea.continent is not null
 --order by 2,3

/* Use for the visualization later */
 select *
 from PercentPopulationVaccinated