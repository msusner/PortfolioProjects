--select * from dbo.covids_death
--select * from dbo.covids_vaccinations


-- Select Data that we are going to be using

select location, date, total_cases, new_cases, total_deaths, population
from covids_death
order by 1,2

--- Looking at Total Cases vs Total Deaths
--- Shows likelihood of dying if you contract COVID in your country
select location, date, total_cases, total_deaths, ROUND((total_deaths/total_cases)*100,3) AS death_percentage
from covids_death
where location like '%states%' and continent is not null

order by 1,2


--- Looking at Total Cases vs Population
--- Shows what percentage of population got COVID
select location, date, population, total_cases, total_deaths, ROUND((total_cases/Population)*100,3) AS death_percentage
from covids_death
where location like '%states%' and continent is not null
order by 1,2



--- Country with highest infection rate
select location, Population, max(total_cases) as highest_infection_count, max((total_cases/population))*100 as percentinfected
from covids_death
WHERE continent is not null
group by location, population
order by percentinfected desc


--- Showing countries with the highest Deaths count per population by COVID
select location, MAX(CAST(total_deaths as int)) as highest_death_count
from covids_death
WHERE continent is not null
group by location
order by highest_death_count desc



--- LET'S BREAK THINGS DOWN BY CONTINENT
select location, MAX(CAST(total_deaths as int)) as highest_death_count
from covids_death
WHERE continent is not null
group by location
order by highest_death_count desc


--- LET'S BREAK THINGS DOWN BY CONTINENT



--- Showing the continents the highest death count
select continent, MAX(CAST(total_deaths as int)) as highest_death_count
from covids_death
WHERE continent is not null
group by continent
order by highest_death_count desc



--- Global numbers
Select date, sum(new_cases) as total_Cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 AS death_percentage
from covids_death
where continent is not null
group by date
order by 1,2


--- Global numbers
Select sum(new_cases) as total_Cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 AS death_percentage
from covids_death
where continent is not null
---group by date
order by 1,2



-- Looking at Total Population vs Vaccincations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as int)) OVER(Partition by dea.location ORDER by dea.location, dea.date) AS rolling_sum_peoplevaccinated
-- SUM(CONVERT(int, vac.new_vaccinations)) OVER(Partiton by dea.location)
from covids_death as dea
JOIN 
covids_vaccinations as vac
	ON dea.location = vac.location 
	and dea.date = vac.date
WHERE dea.continent is not null
order by 2,3


--- USE CTE 
WITH PopvsVac (Continent, location, date, population, new_vaccinations, rolling_sum_peoplevaccinated)
AS 
(select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as int)) OVER(Partition by dea.location ORDER by dea.location, dea.date) AS rolling_sum_peoplevaccinated
-- SUM(CONVERT(int, vac.new_vaccinations)) OVER(Partiton by dea.location)

from covids_death as dea
JOIN 
covids_vaccinations as vac
	ON dea.location = vac.location 
	and dea.date = vac.date
WHERE dea.continent is not null
---order by 2,3
)

select *, (rolling_sum_peoplevaccinated/Population)*100
from PopvsVac


--- temp table
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
rolling_sum_peoplevaccinated numeric
)

INSERT into #PercentPopulationVaccinated 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as int)) OVER(Partition by dea.location ORDER by dea.location, dea.date) AS rolling_sum_peoplevaccinated
-- SUM(CONVERT(int, vac.new_vaccinations)) OVER(Partiton by dea.location)
from covids_death as dea
JOIN 
covids_vaccinations as vac
	ON dea.location = vac.location 
	and dea.date = vac.date
WHERE dea.continent is not null


select *, (rolling_sum_peoplevaccinated/Population)*100
from #PercentPopulationVaccinated


--Creating View for storing data for later visualizations
CREATE view PercentPopulation AS
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as int)) OVER(Partition by dea.location ORDER by dea.location, dea.date) AS rolling_sum_peoplevaccinated
-- SUM(CONVERT(int, vac.new_vaccinations)) OVER(Partiton by dea.location)
from covids_death as dea
JOIN 
covids_vaccinations as vac
	ON dea.location = vac.location 
	and dea.date = vac.date
WHERE dea.continent is not null

-- Querying the above view
select * from PercentPopulation
