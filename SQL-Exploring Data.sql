-- Exploring some covid data using SQL
-- Skills used: Aggregate Functions, Windows Functions,Converting Data Types, Join, CTE, Temp Tables, Creating Views.

-- Percent of death vs total infected
SELECT Date, location, total_cases,total_deaths, (total_deaths/total_cases)*100 AS DeathPercent
FROM CovidDeaths
ORDER BY 2, 1

-- Percent of population infected with covid
SELECT Date, location, total_cases,population, (total_cases/population)*100 AS PercentInfectedofPopulation
FROM CovidDeaths
ORDER BY 2, 1

-- Percent of highest infection rate
SELECT location, MAX(total_cases) AS HighestInfectionCount, population, MAX((total_cases/population))*100 AS PercentInfectedofPopulation
FROM CovidDeaths
GROUP BY location, population
ORDER BY PercentInfectedofPopulation DESC


-- Locations with highest death
SELECT location, MAX(CAST(total_deaths AS INT)) AS HighestDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY HighestDeathCount DESC

-- Total world numbers
SELECT SUM(new_cases) AS TotalCases, SUM(CONVERT(INT, new_deaths)) AS TotalDeaths, SUM(CONVERT(INT, new_deaths))/SUM(new_cases)*100 AS DeathPercent
FROM CovidDeaths
WHERE continent IS NOT NULL

-- Total population vs Vaccinations
-- Percent of Population with at least 1 dose of vaccine
SELECT D.continent, D.location, D.date, D.population, V.new_vaccinations AS VaccinationPerDay, 
SUM(CAST(V.new_vaccinations AS BIGINT)) OVER (PARTITION BY D.location ORDER BY D.location, D.date) AS RunningTotalVac
-- used BIGINT due to Arithmetic overflow error converting expression to data type int error

FROM covid..CovidDeaths D
JOIN covid..CovidVaccinations V
	ON D.location = V.location
	AND D.date = V.date
WHERE D.continent IS NOT NULL
ORDER BY 2, 3


-- Using CTE to perform calculation on partition by in previous query

WITH PopvsVac (continent,location,date, population, new_vaccintions, runningtotalvac)
AS
(
SELECT D.continent, D.location, D.date, D.population, V.new_vaccinations AS VaccinationPerDay, 
SUM(CAST(V.new_vaccinations AS BIGINT)) OVER (PARTITION BY D.location ORDER BY D.location, D.date) AS RunningTotalVac
-- used BIGINT due to Arithmetic overflow error converting expression to data type int error

FROM covid..CovidDeaths D
JOIN covid..CovidVaccinations V
	ON D.location = V.location
	AND D.date = V.date
WHERE D.continent IS NOT NULL
)
SELECT *, (runningtotalvac/population)*100 AS PercentVac 
FROM PopvsVac


-- Using temp table to perform calculation on partition by in previous query

DROP TABLE IF EXISTS #PopulationVacPercent
CREATE TABLE #PopulationVacPercent
(
continent VARCHAR(50),
location VARCHAR(50),
date DATETIME,
population INT,
VaccinationPerDay INT,
RunningTotalVac BIGINT
)

INSERT INTO #PopulationVacPercent

SELECT D.continent, D.location, D.date, D.population, V.new_vaccinations AS VaccinationPerDay, 
SUM(CAST(V.new_vaccinations AS BIGINT)) OVER (PARTITION BY D.location ORDER BY D.location, D.date) AS RunningTotalVac
-- used BIGINT due to Arithmetic overflow error converting expression to data type int error

FROM covid..CovidDeaths D
JOIN covid..CovidVaccinations V
	ON D.location = V.location
	AND D.date = V.date
WHERE D.continent IS NOT NULL

SELECT *, (Runningtotalvac/population)*100 AS PercentVac 
FROM #PopulationVacPercent

-- Creating Views for visualization

CREATE VIEW HighestDeathabyCountries AS
SELECT location, MAX(CAST(total_deaths AS INT)) AS HighestDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location

