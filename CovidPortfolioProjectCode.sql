/*
	Covid 19 Data Exploration

	Skills Used: Joins, CTE, Temp Table, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

SELECT *
FROM CovidProjectPortfolio..CovidDeaths
--WHERE continent is not null
ORDER BY 3,4

--SELECT *
--FROM CovidProjectPortfolio..CovidVaccinations
--ORDER BY 3,4

--Select the data that I am going to be using
SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM CovidProjectPortfolio..CovidDeaths
ORDER BY 1,2

--Looking at total cases vs total deaths
--Shows how likely you are to die from covid in your country
SELECT Location, date, total_cases, total_deaths, (CONVERT(float, total_deaths)/NULLIF(CONVERT(float,total_cases),0))*100 AS Death_Percentage
FROM CovidProjectPortfolio..CovidDeaths
WHERE Location like '%states%'
ORDER BY 1,2

--Looking at the total cases vs population
--Shows the percentage of the population that caught Covid in the United States
SELECT Location, date, population,total_cases, (total_cases/population)*100 AS DeathPercentage
FROM CovidProjectPortfolio..CovidDeaths
WHERE Location like '%states%'
ORDER BY 1,2

--Looking at countries with the highest infection rate compared to population
SELECT Location, Population, MAX(total_cases) as HighInfectionCount, MAX((CONVERT(float, total_cases)/NULLIF(CONVERT(float,population),0)))*100 AS
	PercentPopulationInfected
FROM CovidProjectPortfolio..CovidDeaths
--WHERE location like '%state%'
GROUP BY Location, Population
ORDER BY PercentPopulationInfected DESC

--Showing countries with highest death count per population
SELECT Location, MAX(total_deaths) AS TotalDeathCount
FROM CovidProjectPortfolio..CovidDeaths
WHERE continent != ''
GROUP BY Location
ORDER BY TotalDeathCount DESC

--Showing continents with highest death count per population
SELECT continent, SUM(new_deaths) AS TotalDeathCount
FROM CovidProjectPortfolio..CovidDeaths
WHERE continent !=''
GROUP BY continent
ORDER BY TotalDeathCount DESC

--Global Numbers
SELECT SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage
FROM CovidProjectPortfolio..CovidDeaths
WHERE continent!=''
ORDER BY 1,2

--Total Population vs Vaccinations
SELECT *
FROM CovidProjectPortfolio..CovidDeaths dea
JOIN CovidProjectPortfolio..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date

--Shows Percentage of Population that has recieved at least one Covid Vaccine
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM CovidProjectPortfolio..CovidDeaths dea
JOIN CovidProjectPortfolio..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent!=''
ORDER BY 2,3

--Using CTE to perform Calculation on Partition By in previous Query
With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM CovidProjectPortfolio..CovidDeaths dea
JOIN CovidProjectPortfolio..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent!= ''
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100 AS RPVPercentage
FROM PopvsVac

--Using Temp Table to perform Calculation on Partition By in previous query
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(225),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM CovidProjectPortfolio..CovidDeaths dea
JOIN CovidProjectPortfolio..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
--WHERE dea.continent!=''
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/population)*100 AS RPVPercentage
FROM #PercentPopulationVaccinated

--Creating View to store data for later visualizations
Create View PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM CovidProjectPortfolio..CovidDeaths dea
JOIN CovidProjectPortfolio..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent!=''