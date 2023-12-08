use PortfolioProject


SELECT SUM(CONVERT(float,new_cases)) as total_cases, SUM(CONVERT(float, new_deaths )) as total_deaths, ( NULLIF(SUM(CONVERT(float,new_deaths)),0) / NULLIF(SUM(CONVERT(float,new_cases)),0) *100 ) as DeathPercentage
FROM [dbo].[CovidDeaths]
WHERE continent is not null
ORDER BY 1,2;


SELECT location, SUM(CONVERT(float, new_deaths)) as TotalDeathCount
FROM [dbo].[CovidDeaths]
WHERE continent IS NULL
AND location Not in ('World', 'European Union', 'International')
GROUP BY  location
ORDER BY TotalDeathCount desc;



--Looking at Countries with Highest Infection Rate compared to Populaction

SELECT Location, population,MAX(total_cases ) as HighestInfectionCount, MAX((convert(float,total_cases)/convert(float,population))*100 )as PercentPopulationInfected
FROM [dbo].[CovidDeaths]
--WHERE location like '%states%'
GROUP BY location, population
ORDER BY PercentPopulationInfected desc;



--Looking at Countries with Highest Infection Rate compared to Populaction

SELECT Location, population,date, MAX(total_cases ) as HighestInfectionCount, MAX((convert(float,total_cases)/convert(float,population))*100 )as PercentPopulationInfected
FROM [dbo].[CovidDeaths]
--WHERE location like '%states%'
GROUP BY location, population, date
ORDER BY PercentPopulationInfected desc;
