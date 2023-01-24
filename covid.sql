CREATE TABLE covid_death(
	continent VARCHAR(255),
	location VARCHAR(255),
	date DATE,
	population NUMERIC,
	total_cases NUMERIC,
	new_cases NUMERIC,
	total_deaths NUMERIC,
	new_deaths NUMERIC
);

CREATE TABLE covid_vac(
	continent VARCHAR(255),
	location VARCHAR(255),
	date DATE,
	new_vaccinations NUMERIC
);



--Total Cases vs Total Deaths
--Likelihood of death if Covid is contracted in United States

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathpercentage
FROM covid_death
WHERE location = 'United States'
ORDER BY 1,2


--Total Cases vs Population
--Shows percentage of population that contracted Covid

SELECT location, date, population, total_cases, (total_cases/population)*100 as covidinfectionpercentage
FROM covid_death
WHERE location = 'United States'
ORDER BY 1,2


--Countries with highest infection count compared to population

SELECT location, population, MAX(total_cases) as highestinfectioncount, (MAX(total_cases)/population)*100 as covidinfectionpercentage
FROM covid_death
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY covidinfectionpercentage DESC;


--Countries with highest death count compared to population

SELECT location, MAX(total_deaths) as deathcount
FROM covid_death
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY deathcount DESC;


--Continent with highest death count compared to population

SELECT location, MAX(total_deaths) as deathcount
FROM covid_death
WHERE continent IS NULL
GROUP BY location
ORDER BY deathcount DESC;


--Continent with highest death count compared to population

SELECT continent, MAX(total_deaths) as deathcount
FROM covid_death
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY deathcount DESC;


--Global death count compared to population 

SELECT date, SUM(new_cases) as totalcases, SUM(new_deaths) as totaldeaths, SUM(new_deaths)/SUM(new_cases)*100 as deathpercentage
FROM covid_death
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2;

SELECT SUM(new_cases) as totalcases, SUM(new_deaths) as totaldeaths, SUM(new_deaths)/SUM(new_cases)*100 as deathpercentage
FROM covid_death
WHERE continent IS NOT NULL
ORDER BY 1,2;


--Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as rollingpopvac
FROM covid_death dea
JOIN covid_vac vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3;


--CTE for Total Population vs Vaccinations

WITH popvsvac (continent, location, date, population, new_vacinations, rollingpopvac)
AS(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as rollingpopvac
FROM covid_death dea
JOIN covid_vac vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3
)
SELECT *, (rollingpopvac/population)*100 
FROM popvsvac;


--Create View: Total Population vs Vaccinations

CREATE VIEW percentpopvaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as rollingpopvac
FROM covid_death dea
JOIN covid_vac vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;


--Create View: Highest infection count compared to population

CREATE VIEW invectionvspop as
SELECT location, population, MAX(total_cases) as highestinfectioncount, (MAX(total_cases)/population)*100 as covidinfectionpercentage
FROM covid_death
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY covidinfectionpercentage DESC;


--Create View: Highest death count compared to population

CREATE VIEW deathvspop as
SELECT location, MAX(total_deaths) as deathcount
FROM covid_death
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY deathcount DESC;


