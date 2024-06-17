SELECT * FROM PortfolioProject.CovidDeaths
ORDER BY 3,4

-- SELECT * FROM PortfolioProject.CovidVaccinations
-- ORDER BY 3,4
-- Select Data that we are going to be using 

-- show likelihood of dying of one certain country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
From PortfolioProject.CovidDeaths
WHERE location like '%china%'
ORDER BY 1,2

SELECT *
FROM PortfolioProject.CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

SELECT location, date, population, total_cases, (total_cases/population) * 100 as InfectionPercentage
From PortfolioProject.CovidDeaths
WHERE location like '%state%'
ORDER BY 1,2

-- looking highest infection rate compared by country/population

SELECT location, population, MAX(total_cases), MAX((total_cases/population)) * 100 as Highest_Infection_Rate
From PortfolioProject.CovidDeaths
GROUP BY location, population
ORDER BY Highest_Infection_Rate DESC

-- highest death count per population
SELECT location, MAX(total_deaths) AS Max_deaths
From PortfolioProject.CovidDeaths
GROUP BY location
ORDER BY Max_deaths DESC

SELECT location, MAX(CAST((total_deaths) AS UNSIGNED)) AS max_deaths
FROM PortfolioProject.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY max_deaths DESC

SELECT location, MAX(CAST((total_deaths) AS UNSIGNED)) AS max_deaths
FROM PortfolioProject.CovidDeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY max_deaths DESC

SELECT date, SUM(new_cases)
FROM PortfolioProject.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
Order by 1,2

SELECT date, SUM(new_cases), SUM(new_deaths), SUM(new_deaths)/ SUM(new_cases) * 100 as DeathPertage
FROM PortfolioProject.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

SELECT *
FROM PortfolioProject.CovidVaccinations

SELECT continent, location, date, total_vaccinations, new_vaccinations
FROM PortfolioProject.CovidVaccinations
WHERE continent IS NOT NULL
ORDER BY 1,2,3

SELECT *
FROM PortfolioProject.CovidDeaths dea
JOIN PortfolioProject.CovidVaccinations vac
	ON dea.location = vac.location and dea.date = vac.date
	
-- Looking at total population vs vaccations
Select dea.continent, dea.location, dea.date, dea.population, vac.total_vaccinations, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS UNSIGNED)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject.CovidDeaths dea
JOIN PortfolioProject.CovidVaccinations vac
	ON dea.location = vac.location and dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3
	
-- USE CTE
WITH PopvsVac (continent, location, date, population, total_vaccinations, new_vaccinations, RollingPeopleVaccinated)
AS 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.total_vaccinations, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS UNSIGNED)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject.CovidDeaths dea
JOIN PortfolioProject.CovidVaccinations vac
	ON dea.location = vac.location and dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac

-- TEMP TABLE
DROP TABLE IF EXISTS PercentPopulationVaccinated
CREATE TEMPORARY TABLE PercentPopulationVaccinated
(
continent VARCHAR(255),
location VARCHAR(255),
date DATETIME,
population NUMERIC,
total_vaccinations NUMERIC,
new_vaccinations NUMERIC,
RollingPeopleVaccinated NUMERIC
)

INSERT INTO PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.total_vaccinations, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS UNSIGNED)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject.CovidDeaths dea
JOIN PortfolioProject.CovidVaccinations vac
	ON dea.location = vac.location and dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/population)*100
FROM PercentPopulationVaccinated

-- Creating view to store date for later visualizations
Create view PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.total_vaccinations, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS UNSIGNED)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject.CovidDeaths dea
JOIN PortfolioProject.CovidVaccinations vac
	ON dea.location = vac.location and dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3



