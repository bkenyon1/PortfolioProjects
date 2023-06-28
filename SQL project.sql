SELECT *
From PortfolioProject..CovidDeaths
where continent is not null
order by 3,4


--SELECT *
--From PortfolioProject..CovidVaccinations
--order by 3,4

SELECT Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2


-- Looking at TotalCases vs Total
-- Shows liklihood of dying if you contract covid in your country

ALTER TABLE CovidDeaths
ALTER COLUMN total_deaths float

ALTER TABLE CovidDeaths
AlTER COLUMN total_cases float 

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%states'
order by 1,2


-- Looking at the total cases vs. population
-- Shows what percent of population got covid
SELECT Location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
----where location like '%states'
order by 1,2

-- Looking at countries with highest infection rate compared to population

SELECT Location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
----where location like '%states'
Group by location, population
order by PercentPopulationInfected desc


-- Countries with highest death count per population

SELECT location, MAX(cast(total_deaths as int)) AS TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by location 
order by TotalDeathCount desc

--Breaking things down by continent 
SELECT continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by continent 
order by TotalDeathCount desc


-- GLOBAL NUMBERS
SET ARITHABORT OFF
SET ANSI_WARNINGS OFF
GO
SELECT date, SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
----where location like '%states'
where continent is not null
group by date
order by 1,2

SELECT SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
----where location like '%states'
where continent is not null
--group by date
order by 1,2


-- Looking at Total Population vs Vaccinations
-- USE CTE

with PopvsVac (Continent, location, date, population, new_vaccionations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac



--TEMP TABLE

Drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric, 
RollingPeopleVaccinated numeric
)
insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated




-- Creating view to store data for later visualizations

Create view PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3











