---SELECT DATA TO USE 

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM Portfolio.covid.covid_data
WHERE continent is not null
ORDER BY 1, 2

---LOOKING AT TOTAL CASES VS TOTAL CASES 

SELECT location, date, total_cases, total_deaths, (total_deaths * 100 / total_cases) AS DeathPercentage
FROM Portfolio.covid.covid_data
WHERE location LIKE '%thailand%'
ORDER BY location, date;

---LOOKING AT COUNTRIES WITH HIGHEST INFECTION RATE COMPARED TO POPULATION 

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_deaths * 100 / population)) AS PercentPopulationInfected 
FROM Portfolio.covid.covid_data
--WHERE location LIKE '%thailand%'
WHERE continent is not null
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

--- SHOWING COUNTRIES WITH HIGHEST DEATH COUNT PER POPULATION

SELECT continent, MAX(CAST(total_deaths AS int)) AS TotalDeathCounts
FROM Portfolio.covid.covid_data
WHERE continent is not null
---WHERE location LIKE '%thailand%'
GROUP BY continent
ORDER BY TotalDeathCounts DESC

---lETS BREAK THINGS DOWN BY CONTINENT

SELECT continent, MAX(CAST(total_deaths AS int)) AS TotalDeathCounts
FROM Portfolio.covid.covid_data
---WHERE location LIKE '%thailand%'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCounts DESC

---SHOWING CONTINENTS WITH THE HIGHEST DEATH COUNT PER POPULATION

SELECT continent, MAX(CAST(total_deaths AS int)) AS TotalDeathCounts
FROM Portfolio.covid.covid_data
---WHERE location LIKE '%thailand%'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCounts DESC

---GLOBAL NUMBERS
SELECT SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int))as total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
FROM Portfolio.covid.covid_data
--WHERE location LIKE '%thailand%'
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2;

---LOOKING AT TOTAL POPULATION VS VACCINATIONS 

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as int)) OVER (partition by dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated
FROM Portfolio.covid.covid_data dea
JOIN Portfolio.covid.covid_data2 vac
     ON dea.location = vac.location
	 AND dea.date = vac.date
WHERE dea.continent is not null
ORDER by 2,3

--USE CTE

WITH popvsvac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.location ORDER BY dea.date) AS RollingPeopleVaccinated
FROM Portfolio.covid.covid_data dea
JOIN Portfolio.covid.covid_data2 vac
     ON dea.location = vac.location
	 AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER by 2,3
)


SELECT*,(RollingPeopleVaccinated/population)*100
FROM popvsvac

---	TEMP TABLE

CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

DROP TABLE IF EXIST 
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.location ORDER BY dea.date) AS RollingPeopleVaccinated
FROM Portfolio.covid.covid_data dea
JOIN Portfolio.covid.covid_data2 vac
     ON dea.location = vac.location
	 AND dea.date = vac.date
--WHERE dea.continent is not null
--ORDER by 2,3
)
SELECT * , (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated

---CREATING VIEW FOR VISUALIZATION






