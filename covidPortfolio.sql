/*

SELECT * FROM [dbo].[CovidDeaths]
ORDER BY 3,4

SELECT * FROM [dbo].[CovidVaccinations]
ORDER BY 3,4

*/


-- Select the data we are going to be using

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM [dbo].[CovidDeaths]
ORDER BY 1,2;



-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of daying if you contract covid in your country
SELECT Location, date, total_cases, total_deaths,(convert(float,total_deaths)/convert(float,total_cases))*100 as DeathPercentage
FROM [dbo].[CovidDeaths]
WHERE location like '%states%'
ORDER BY 1,2;


--Looking at total Cases vs Population
-- Shows what percentage of population got Covid

SELECT Location, date, population,total_cases ,(convert(float,total_cases)/convert(float,population))*100 as PercentPopulationInfected
FROM [dbo].[CovidDeaths]
--WHERE location like '%states%'
ORDER BY 1,2;


--Looking at Countries with Highest Infection Rate compared to Populaction

SELECT Location, population,MAX(total_cases ) as HighestInfectionCount, MAX((convert(float,total_cases)/convert(float,population))*100 )as PercentPopulationInfected
FROM [dbo].[CovidDeaths]
--WHERE location like '%states%'
GROUP BY location, population
ORDER BY PercentPopulationInfected desc;



-- Showing Countries with Highest Death Count  per Population

SELECT Location,MAX(convert(float, total_deaths)) as TotalDeathCount
FROM [dbo].[CovidDeaths]
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY location, population
ORDER BY TotalDeathCount desc;


-- Break Thing by Continent
-- Showing continents with the highest deadth count 

SELECT location, MAX(convert(float, total_deaths)) as TotalDeathCount
FROM [dbo].[CovidDeaths]
--WHERE location like '%states%'
WHERE continent is null
GROUP BY location
ORDER BY TotalDeathCount desc;

--OR 
SELECT continent, MAX(convert(float, total_deaths)) as TotalDeathCount
FROM [dbo].[CovidDeaths]
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc;


-- Global Numbers

SELECT date, SUM(CONVERT(float,new_cases)), SUM(CONVERT(float, new_deaths )), ( NULLIF(SUM(CONVERT(float,new_deaths)),0) / NULLIF(SUM(CONVERT(float,new_cases)),0) *100 ) as DeathPercentage
FROM [dbo].[CovidDeaths]
WHERE continent is not null
GROUP BY date
ORDER BY 1,2;


--

SELECT SUM(CONVERT(float,new_cases)), SUM(CONVERT(float, new_deaths )), ( NULLIF(SUM(CONVERT(float,new_deaths)),0) / NULLIF(SUM(CONVERT(float,new_cases)),0) *100 ) as DeathPercentage
FROM [dbo].[CovidDeaths]
WHERE continent is not null
ORDER BY 1,2;




/*

COVID VACCINATIONS

*/

--Looking at total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float,  vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated / population) * 100
FROM [dbo].[CovidDeaths] dea
INNER JOIN [dbo].[CovidVaccinations] vac
ON dea.location = vac.location and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3


--USE CTE

With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float,  vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated / population) * 100
FROM [dbo].[CovidDeaths] dea
INNER JOIN [dbo].[CovidVaccinations] vac
ON dea.location = vac.location and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

)

Select *, (RollingPeopleVaccinated/ population) * 100
FROM PopvsVac




-- TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinated numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float,  vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated / population) * 100
FROM [dbo].[CovidDeaths] dea
INNER JOIN [dbo].[CovidVaccinations] vac
ON dea.location = vac.location and dea.date = vac.date
--WHERE dea.continent is not null
--ORDER BY 2,3


Select *, (RollingPeopleVaccinated/ population) * 100
FROM #PercentPopulationVaccinated






-- Create view to store data for visualizations
--
CREATE VIEW PercentPopulationVaccinated as 

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float,  vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated / population) * 100
FROM [dbo].[CovidDeaths] dea
INNER JOIN [dbo].[CovidVaccinations] vac
ON dea.location = vac.location and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3


Select* FROM PercentPopulationVaccinated


