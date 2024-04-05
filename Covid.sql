Select *
from CovidDeaths
order by 3,4


-- Shows likelihood of dying while contracting covid

Select Location, date, total_cases, total_deaths, ((total_deaths/total_cases)*100) AS DeathPercentage
From CovidDeaths
order by 1,2


-- total cases vs population

Select Location, date, total_cases, population, ((total_cases/population)*100) AS CasePercentage
From CovidDeaths
order by 1,2


-- highest infection rate countries compared to total population using a CTE


WITH CasePercent AS (
Select location, ((total_cases/population)*100) AS CasePercentage
From CovidDeaths
) 

Select Location , MAX(CasePercentage) AS MaxCase
From CasePercent
Group by Location
Order by MaxCase DESC


-- Highest death rate countries compared to total population

Select Location, Max(Cast(total_deaths as int)/population)*100 As DeathPercent
From CovidDeaths
Group by Location
Order by DeathPercent DESC


-- Noticed that some continents are in the location field

Select *
from CovidDeaths
WHERE continent is null
order by 3,4

-- noticed that the numbers within the continent in locations are more accurate than 
-- the sum of all the data we have of the locations with a continent tag

--more accurate

Select location, Max(Cast(total_Deaths as Int))
From CovidDeaths
Where Continent is null
group by location
order by 2 DESC

-- less accurate

Select continent, Max(Cast(total_Deaths as Int))
From CovidDeaths
Where Continent is not null
group by continent
order by 2 DESC


-- Showing continents with the highest death count per population

Select location, Max(Cast(total_Deaths as Int)/population)*100 as DeathPopRate
From CovidDeaths
Where Continent is null
group by location
order by 2 DESC


-- Global numbers 

---Accumulated Deaths, Cases and Death Percentage by day

WITH d AS ( 
SELECT date,SUM(Cast(total_deaths as float)) as World_Deaths, SUM(Cast(total_cases as float)) as World_Cases
From CovidDeaths
Where continent is null
group by date
)

Select date,MAX(World_Deaths) as World_Deaths, MAX(World_Cases) as World_Cases, 

CASE
        WHEN MAX(World_Cases) > 0 THEN (MAX(World_Deaths) / MAX(World_Cases))* 100
        ELSE NULL  -- Handle division by zero
    END AS DeathPercentage

From d
group by date
order by date asc



--- Deaths, Cases and Death Percentage day by day

Select date, sum(new_cases) as World_cases, sum(cast(new_deaths as int)) as World_deaths, 

CASE
		WHEN SUM(new_cases) > 0 THEN SUM(cast(new_deaths as float))/SUM(new_cases)*100.0
		ELSE NULL -- Handle division by zero
	END AS Deathpercentage
From CovidDeaths
Where continent is null
Group by date
order by date asc



-- Looking at total population vs Vaccinations

--- joining tables

select * 
from CovidDeaths dea
JOIN CovidVaccinations vac
	on dea.location = vac.location AND
	dea.date = vac.date

---

select dea.location, dea.continent, dea.date, vac.new_vaccinations, dea.population
from CovidDeaths dea
JOIN CovidVaccinations vac
	on dea.location = vac.location AND
	dea.date = vac.date
Where vac.new_vaccinations IS NOT NULL AND dea.continent IS NOT NULL 


--- accumulated vacinations by days by country and vaccination percentage against population


Select dea.date, dea.continent, dea.location, 
	SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.continent, dea.location ORDER BY dea.date) AS rolling_vaccinations, 
	vac.new_vaccinations, 
	(SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.continent, dea.location ORDER BY dea.date)/dea.population)*100 as VaccinationPercentage,
	dea.population
from CovidDeaths dea
JOIN CovidVaccinations vac
	on dea.location = vac.location AND
	dea.date = vac.date
Where dea.continent is not null
group by dea.date, dea.continent,dea.location, dea.population,vac.new_vaccinations


--- Same but with CTE 



WITH f as(
Select dea.date, dea.continent, dea.location, 
	SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.continent, dea.location ORDER BY dea.date) AS rolling_vaccinations, 
	vac.new_vaccinations, dea.population
from CovidDeaths dea
JOIN CovidVaccinations vac
	on dea.location = vac.location AND
	dea.date = vac.date
Where dea.continent is not null
group by dea.date, dea.continent,dea.location, dea.population,vac.new_vaccinations
)

SELECT date, continent, location, rolling_vaccinations, new_vaccinations, (rolling_vaccinations/population)*100 as Vac_Percentage, population
FROM f





---FOR TABLEAU VISUALIZATIONS---


--1

Select SUM(new_cases) as Total_cases, SUM(cast(new_deaths as int)) as Total_deaths, (SUM(cast(new_deaths as float)) / SUM(new_cases)) * 100 as DeathPercentage
from CovidDeaths
where continent is not null


--2

Select location, sum(cast(new_deaths as int)) as TotalDeathCount
from CovidDeaths
where continent is null 
and location not in ('European Union','International','World')
group by location
order by TotalDeathCount desc


--3

Select location, Population, MAX(total_cases) as HighestInfectionCount, Max(total_cases/population)*100 as PercentPopulationInfected
From CovidDeaths
group by location, population
order by PercentPopulationInfected desc


--4

Select Location, population, date, MAX(total_cases) as HighestInfectionCount, Max(total_cases/population)*100 as PercentPopulationInfected
From CovidDeaths
group by Location, population, Date
order by PercentPopulationInfected desc





select MIN(date)
from CovidDeaths




select SUM(Cast(new_vaccinations as float))
from CovidVaccinations
Where continent is null 
order by SUM(Cast(new_vaccinations as float)) DESC



select AVG(Cast(new_cases_per_million as float)), continent, location
from CovidDeaths
Group by Continent, location
order by AVG(Cast(new_cases_per_million as float)) DESC

 



























































































































































































