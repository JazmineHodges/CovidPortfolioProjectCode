/*
	Queries used for Tableau Project
*/

--Query 1
SELECT SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage
FROM CovidProjectPortfolio..CovidDeaths
WHERE continent!=''
ORDER BY 1,2

--Query 2 
SELECT Location, SUM(new_deaths) as TotalDeathCount
FROM CovidProjectPortfolio..CovidDeaths
WHERE continent is not null
AND Location IN ('Europe','North America','South America','Asia','Africa','Oceania')
GROUP BY Location
ORDER BY TotalDeathCount DESC

--Query 3
SELECT Location, Population, MAX(total_cases) as HighInfectionCount, MAX((CONVERT(float, total_cases)/NULLIF(CONVERT(float,population),0)))*100 AS
	PercentPopulationInfected
FROM CovidProjectPortfolio..CovidDeaths
GROUP BY Location, Population
ORDER BY PercentPopulationInfected DESC

--Query 4
SELECT Location, Population, Date, MAX(total_cases) as HighInfectionCount, MAX((CONVERT(float, total_cases)/NULLIF(CONVERT(float,population),0)))*100 AS
	PercentPopulationInfected
FROM CovidProjectPortfolio..CovidDeaths
GROUP BY Location, Population, Date
ORDER BY PercentPopulationInfected DESC

