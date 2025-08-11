/*
Covid 19 Data Exploration

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/
-- Converting blanks to NULL and TEXT data type to correct type when needed 
UPDATE coviddeaths SET continent = NULL WHERE continent = '';
UPDATE coviddeaths SET date = STR_TO_DATE(date, '%m/%d/%Y');
UPDATE covidvaccinations SET date = STR_TO_DATE(date, '%m/%d/%Y');
UPDATE covidvaccinations SET new_vaccinations = CAST(new_vaccinations AS float);

SELECT * FROM portfolioproject.coviddeaths
WHERE continent IS NOT NULL;

Select location, date, total_cases, new_cases, total_deaths, population
FROM coviddeaths
ORDER BY location;

-- Total Cases vs Total Deaths

Select location, date, total_cases,  total_deaths,(total_deaths/total_cases)*100 AS death_percentage
FROM coviddeaths
WHERE location LIKE '%states%' 
AND continent IS NOT NULL
ORDER BY location;

-- Total Cases vs Population
-- Shows what percentage of population got covid
Select location, date, total_cases,  population, (total_cases/population)*100 AS PercentagePopulationInfected
FROM coviddeaths
WHERE location LIKE '%states%'
AND continent IS NOT NULL
ORDER BY location;

-- Countries with Highest Infection Rate compared to Population

Select location,  MAX(total_cases) AS HighestInfectionCount,  population, MAX((total_cases/population))*100 AS PercentagePopulationInfected
FROM coviddeaths
-- WHERE location LIKE '%states%'
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY PercentagePopulationInfected DESC;

-- Countries with Highest Death Count 

Select location, MAX(CAST(total_deaths AS float)) AS TotalDeathCount
FROM coviddeaths
-- WHERE location LIKE '%states%'
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC;

-- Breaking down by continent

Select continent, MAX(CAST(total_deaths AS float)) AS TotalDeathCount
FROM coviddeaths
-- WHERE location LIKE '%states%'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;

-- Global Numbers

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as float)) as total_deaths, SUM(cast(new_deaths as float))/SUM(New_Cases)*100 as DeathPercentage
From CovidDeaths
-- Where location like '%states%'
where continent is not null 
-- Group By date
order by 1,2;

-- Total Population VS Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

SELECT dea.continent, dea.location, dea.date, dea.population, CAST(vac.new_vaccinations AS float) AS new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS float)) OVER (partition by location ORDER BY dea.location, dea.date) AS RollingPopulationVaccinated
FROM coviddeaths dea
JOIN covidvaccinations vac
	ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL 
ORDER BY dea.location, dea.date;

-- Using CTE to perform Calculation on Partition By in previous query
WITH PopvsVac (continent, location, date, population,new_vaccinations, RollingPopulationVaccinated)
AS 
(
SELECT dea.continent, dea.location, dea.date, dea.population, CAST(vac.new_vaccinations AS float) AS new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS float)) OVER (partition by location ORDER BY dea.location, dea.date) AS RollingPopulationVaccinated
FROM coviddeaths dea
JOIN covidvaccinations vac
	ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL 
-- ORDER BY dea.location, dea.date
)
SELECT *, (RollingPopulationVaccinated/Population)*100 AS PercentPopVaccinated
FROM PopvsVac;

-- Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS 
SELECT dea.continent, dea.location, dea.date, dea.population, CAST(vac.new_vaccinations AS float) AS new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS float)) OVER (partition by location ORDER BY dea.location, dea.date) AS RollingPopulationVaccinated
FROM coviddeaths dea
JOIN covidvaccinations vac
	ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL 
-- ORDER BY dea.location, dea.date
;






