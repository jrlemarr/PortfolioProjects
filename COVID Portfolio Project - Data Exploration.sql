/*
Covid 19 Data Exploration
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

SELECT * FROM `ba775-jlp.DA_portfolio_project.CovidDeaths`
WHERE continent IS NOT NULL
ORDER BY 3,4;

SELECT * FROM `ba775-jlp.DA_portfolio_project.CovidVaccinations`
WHERE continent IS NOT NULL
ORDER BY 3,4;

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM `ba775-jlp.DA_portfolio_project.CovidDeaths`
WHERE continent IS NOT NULL
ORDER BY 1,2;

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract Covid in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM `ba775-jlp.DA_portfolio_project.CovidDeaths`
WHERE location LIKE '%States%'
AND continent IS NOT NULL
ORDER BY 1,2;

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid
-- Looking at Countries with Highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM `ba775-jlp.DA_portfolio_project.CovidDeaths`
--WHERE location LIKE '%States%'
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC;

-- Showing countries with highest death count per population

SELECT location, MAX(total_deaths) AS TotalDeathCount
FROM `ba775-jlp.DA_portfolio_project.CovidDeaths`
--WHERE location LIKE '%States%'
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC;

-- Breaking things down by continent
-- Showing continents with the highest death count per population

SELECT location, MAX(total_deaths) AS TotalDeathCount
FROM `ba775-jlp.DA_portfolio_project.CovidDeaths`
--WHERE location LIKE '%States%'
WHERE continent IS NULL
GROUP BY location
ORDER BY TotalDeathCount DESC;

-- Global numbers

-- New cases per day and new deaths per day from all over the world

SELECT date, SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, SUM(new_deaths)/SUM(new_cases)*100 AS DeathPercentage
FROM `ba775-jlp.DA_portfolio_project.CovidDeaths`
--WHERE location LIKE '%States%'
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2;

-- Total new cases and total deaths in the world; death percentage

SELECT SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, SUM(new_deaths)/SUM(new_cases)*100 AS DeathPercentage
FROM `ba775-jlp.DA_portfolio_project.CovidDeaths`
--WHERE location LIKE '%States%'
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2;

-- Looking at total population vs vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
-- ,(RollingPeopleVaccinated/population)*100
FROM `ba775-jlp.DA_portfolio_project.CovidDeaths` dea
JOIN `ba775-jlp.DA_portfolio_project.CovidVaccinations` vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3;

-- CTE

WITH PopvsVac --(Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM `ba775-jlp.DA_portfolio_project.CovidDeaths` dea
JOIN `ba775-jlp.DA_portfolio_project.CovidVaccinations` vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac;

-- TEMP TABLE

DROP TABLE if exists DA_portfolio_project.PercentPopulationVaccinated;
CREATE TABLE DA_portfolio_project.PercentPopulationVaccinated
(continent STRING,
location STRING,
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric);

INSERT INTO DA_portfolio_project.PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
-- ,(RollingPeopleVaccinated/population)*100
FROM `ba775-jlp.DA_portfolio_project.CovidDeaths` dea
JOIN `ba775-jlp.DA_portfolio_project.CovidVaccinations` vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;


SELECT *, (RollingPeopleVaccinated/population)*100
FROM DA_portfolio_project.PercentPopulationVaccinated;

-- Creating View to store data for later visualizations

CREATE VIEW DA_portfolio_project.PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
-- ,(RollingPeopleVaccinated/population)*100
FROM `ba775-jlp.DA_portfolio_project.CovidDeaths` dea
JOIN `ba775-jlp.DA_portfolio_project.CovidVaccinations` vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;
