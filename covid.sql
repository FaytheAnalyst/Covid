/* Covid 19 
Data Exploration: This is the first step in data analysis where we determine the trends and patterns in a data set

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/
SELECT *
FROM coviddeaths
ORDER BY 3,4;
-- Select Data that we are going to be starting with

SELECT location, date, total_cases, new_cases, total_deaths, population
from coviddeaths
order by 1,2;

-- Total Cases vs Total Deaths : Shows likelihood of dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths,(total_deaths/total_cases) *100 AS DeathPercentage
from coviddeaths
where location like 'africa'
order by 1,2;

-- Total Cases vs Population : Shows what percentage of population infected with Covid
SELECT location, date, population,total_cases,(total_cases/population)*100 AS PercentPopulationInfected
from coviddeaths
where location like 'africa';

-- Countries with Highest Infection Rate compared to Population
SELECT location, population,MAX(total_cases) AS highestInfectioncount, MAX((total_cases/population))*100 AS PercentPopulationInfected
from coviddeaths
GROUP BY location, population
ORDER BY Percentpopulationinfected DESC;

-- Countries with Highest Death Count per Population

SELECT location, population,MAX(total_deaths) AS highestdeathcount, MAX((total_deaths/population))*100 AS DeathRate
from coviddeaths
GROUP BY location, population
ORDER BY 1 ;

-- BREAKING THINGS DOWN BY CONTINENT: Showing contintents with the highest death count per population

Select continent, MAX(Total_deaths) as TotalDeathCount
From CovidDeaths
-- Where location like 'Africa%'
Where continent is not null 
Group by continent
order by TotalDeathCount desc;

-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(New_Cases)*100 as DeathPercentage
From CovidDeaths
-- Where location like 'Africa%'
where continent is not null 
-- Group By date
order by 1,2;

-- Total Population vs Vaccinations : Shows Percentage of Population that has recieved at least one Covid Vaccine

Select Cvd_dea.continent, Cvd_dea.location, Cvd_dea.date, Cvd_dea.population, Cvd_vac.new_vaccinations,
SUM(Cvd_vac.new_vaccinations) OVER (Partition by Cvd_dea.Location Order by Cvd_dea.location, Cvd_dea.Date) as RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population)*100
From CovidDeaths AS Cvd_dea
Join CovidVaccinations Cvd_vac
	On Cvd_dea.location = Cvd_vac.location
	and Cvd_dea.date = Cvd_vac.date
where Cvd_dea.continent is not null 
order by 2,3;

-- Using CTE to perform Calculation on Partition By in previous query
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population)*100
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
-- order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac;


-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
