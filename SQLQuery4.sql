

SELECT location, [date], total_cases, new_cases, total_deaths, population
FROM dbo.CovidDeaths
order by 1,2;

-- looking at total_deaths vs total_cases

SELECT location, [date], total_cases, total_deaths,(total_deaths/total_cases)*100 as deaths_percentage
FROM dbo.CovidDeaths
where location = 'south africa'
order by 1,2;

-- looking at the toatal_cases vs population
SELECT location, [date], total_cases, population,(total_cases/population)*100 as cases_per_population
FROM dbo.CovidDeaths
where location = 'south africa'
order by 1,2;

-- countries with the highest infection rate compared to the population
SELECT location, population, max(total_cases) as highest_infection_rate,
max((total_cases/population))*100 as percentage_population_infected
FROM dbo.CovidDeaths
group by location, population
order by percentage_population_infected desc;

-- countries with the highest death count per population
SELECT location, max (cast(total_deaths as int)) as total_deaths
FROM dbo.CovidDeaths
group by location
order by  total_deaths desc;

-- lets break things down by continent

SELECT continent, max (cast(total_deaths as int)) as total_deaths
FROM dbo.CovidDeaths
where continent is not Null
group by continent
order by  total_deaths desc;

-- showing the continents with the highest death count 

SELECT continent, max (cast(total_deaths as int)) as total_deaths
FROM dbo.CovidDeaths
where continent is not Null
group by continent
order by  total_deaths desc;

-- GLOBAL NUMBERS 

SELECT  SUM(cast(new_cases AS INT)) AS TOTAL_CASES, SUM(cast(new_deaths AS INT)) AS TOTAL_DEATHS,
				(SUM(cast(new_deaths AS INT))/SUM(new_cases))*100 as deathpercentage
FROM dbo.CovidDeaths
--where location = 'south africa'
where continent is not NUll
--group by date 
order by 1,2;

-- looking at total population vs vaccinations

SELECT dea.continent, dea.location, dea.date,dea.total_cases, vac.new_vaccinations,
sum (cast(vac.new_vaccinations as int) ) 
	over (partition by dea.location order by dea.location , dea.date) as total_vaccinations
FROM dbo.CovidDeaths dea
Join dbo.CovidVaccinations vac
	on dea.location = vac.location and dea.date= vac.date
where dea.continent is not Null
order by 2,3;

-- use CTE to compare recently created table

WITH populationvsvaccinations(continent, location, date,population, total_cases, new_vaccinations, total_vaccinations)
as 
(
SELECT dea.continent, dea.location, dea.date,dea.population, dea.total_cases, vac.new_vaccinations,
sum (cast(vac.new_vaccinations as int) ) 
	over (partition by dea.location order by dea.location , dea.date) as total_vaccinations
FROM dbo.CovidDeaths dea
Join dbo.CovidVaccinations vac
	on dea.location = vac.location and dea.date= vac.date
where dea.continent is not Null
--order by 2,3;
)
select *, (total_vaccinations/population)*100 as vaccination_percentage
from populationvsvaccinations;

-- creating a view to store data for later visualization

create view percentpopulationvaccinated as

SELECT dea.continent, dea.location, dea.date,dea.total_cases, vac.new_vaccinations,
sum (cast(vac.new_vaccinations as int) ) 
	over (partition by dea.location order by dea.location , dea.date) as total_vaccinations
FROM dbo.CovidDeaths dea
Join dbo.CovidVaccinations vac
	on dea.location = vac.location and dea.date= vac.date
where dea.continent is not Null
--order by 2,3;


SELECT *
FROM percentpopulationvaccinated;