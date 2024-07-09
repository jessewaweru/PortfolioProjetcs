SELECT
	*
FROM
	Portfolio_Projects..CovidDeaths
WHERE
	continent IS NOT NULL
	--NOTE: I USED CONTINENT IS NOT NULL BECAUSE IN SOME ROWS, ASIA IS FOUND IN LOCATION INSTEAD OF THE CONTINENT COLUMN 
	--...AND LEAVES THE CONTINENT COLUMN NULL(IT HELPS US HAVE A MORE ACCURATE CONTINENT QUERY)
ORDER BY
	3,
	4


-- Establish percentage of deaths against reported cases
SELECT
	Location,
	date,
	total_cases,
	total_deaths,
	(CAST(total_deaths AS FLOAT) / CAST(total_cases AS FLOAT)) * 100 AS DeathPercentage
FROM
	Portfolio_Projects..CovidDeaths
WHERE
	location like '%states%'
ORDER BY
	Location,
	date

--Total cases vs Population
SELECT
	Location,
	date,
	total_cases,
	total_deaths,
	population,
	(CAST(total_cases AS FLOAT) / population) * 100 AS Perc_PopulationInfected
FROM
	Portfolio_Projects..CovidDeaths
WHERE
	location like '%states%'
ORDER BY
	Location,
	date

--Countries with the Highest Infection rate compared to Population
SELECT
	Location,
	population,
	MAX(total_cases) AS HighestInfectionCount,
	MAX((CAST(total_cases AS FLOAT) / population)) * 100 AS Perc_PopulationInfected
FROM
	Portfolio_Projects..CovidDeaths
GROUP BY
	Location,
	population
ORDER BY
	Perc_PopulationInfected DESC

--Countries with the Highest Death Count per population
SELECT
	Location,
	population,
	MAX(CAST(total_deaths AS float)) AS TotalDeathCount
FROM
	Portfolio_Projects..CovidDeaths
WHERE
	continent IS NOT NULL
GROUP BY
	Location,
	population
ORDER BY
	TotalDeathCount DESC

--Continents with the Highest Death Count 
SELECT
	location,
	MAX(CAST(total_deaths AS float)) AS TotalDeathCount
FROM
	Portfolio_Projects..CovidDeaths
WHERE
	continent IS NULL
GROUP BY
	location
ORDER BY
	TotalDeathCount DESC

--USE THE CODE BELOW LATER FOR VISUALIZATION PURPOSES
--SELECT
--	continent,
--	MAX(CAST(total_deaths AS float)) AS TotalDeathCount
--FROM
--	Portfolio_Projects..CovidDeaths
--WHERE
--	continent IS NOT NULL
--GROUP BY
--	continent
--ORDER BY
--	TotalDeathCount DESC

--GLOBAL VIEW
SELECT
	SUM(CAST(new_cases AS float)) AS total_cases,
	SUM(CAST(new_deaths as float)) AS total_deaths,
	SUM(CAST(new_deaths as float))/ SUM(CAST(new_cases AS float))*100 AS DeathPercentage
FROM
	Portfolio_Projects..CovidDeaths
WHERE
	continent IS NOT NULL
ORDER BY
	1,
	2


--Total Population of people Vaccinated
SELECT
	Dea.continent,
	Dea.location,
	Dea.date,
	Dea.population,
	Vac.new_vaccinations,
	SUM(CAST(Vac.new_vaccinations AS float)) OVER(PARTITION BY Dea.location ORDER BY Dea.date) AS RollingPeopleVaccinated_per_country
FROM
	Portfolio_Projects..CovidDeaths AS Dea
JOIN
	Portfolio_Projects..[CovidVaccinations - CovidVaccinations] AS Vac
	ON Dea.location = Vac.location
	AND Dea.date = Vac.date
WHERE
	Dea.continent IS NOT NULL
ORDER BY
	location,
	date

-- Temporary Table for RollingPeopleVaccinated_per_country as a % of the population
DROP TABLE IF EXISTS #PercentPeopleVaccinated
CREATE TABLE #PercentPeopleVaccinated(
Continent varchar(300),
Location varchar(300),
Date date,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPeopleVaccinated
SELECT
	Dea.continent,
	Dea.location,
	Dea.date,
	Dea.population,
	Vac.new_vaccinations,
	SUM(CAST(Vac.new_vaccinations AS float)) OVER(PARTITION BY Dea.location ORDER BY Dea.date) AS RollingPeopleVaccinated_per_country
FROM
	Portfolio_Projects..CovidDeaths AS Dea
JOIN
	Portfolio_Projects..[CovidVaccinations - CovidVaccinations] AS Vac
	ON Dea.location = Vac.location
	AND Dea.date = Vac.date
WHERE
	Dea.continent IS NOT NULL
ORDER BY
	location,
	date

SELECT
	*,
	(RollingPeopleVaccinated/Population) *100 AS PercentRollingPeopleVaccinated
FROM
	#PercentPeopleVaccinated

-- CREATE VIEW FOR FUTURE DATA VISUALIZATION
-- CONTINENTS WITH HIGHEST DEATH COUNT
CREATE VIEW ContinentsWithHighestDeathCount AS
SELECT
	location,
	MAX(CAST(total_deaths AS float)) AS TotalDeathCount
FROM
	Portfolio_Projects..CovidDeaths
WHERE
	continent IS NULL
GROUP BY
	location
