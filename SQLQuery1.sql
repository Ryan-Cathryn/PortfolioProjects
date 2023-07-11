select *
from PortfolioProject..Covid_Deaths$
where continent is not null
order by 3,4


select location, population, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
from PortfolioProject..Covid_Deaths$
where continent is not null
order by 1,2

--Diagnosing problem I was facing
--Modified data within columns to float from nvarchar
EXEC sp_help 'dbo.Covid_Deaths$'

ALTER TABLE dbo.Covid_Deaths$
ALTER COLUMN total_cases float

ALTER TABLE dbo.Covid_Deaths$
ALTER COLUMN total_deaths float 

ALTER TABLE dbo.Covid_Vaccinations$
ALTER COLUMN new_vaccinations float

--Looking at Total Cases vs Population
--Showing what percentage of population has gotten Covid

select location, date, population, total_cases, (total_cases/population)*100 as Percent_Population_Infected
from PortfolioProject..Covid_Deaths$
where location='United States'
and continent is not null
order by 1,2

--Looking at Countries with Highest Infection Rate compared to Population

select location, population, MAX(total_cases) as Highest_Infection_Count, MAX((total_cases/population))*100 as Percent_Population_Infected
from PortfolioProject..Covid_Deaths$
--where location='United States'
--and continent is not null
Group by location, population
order by Percent_Population_Infected desc


--Showing Countries with Highest Death Count per Population

select location, MAX(total_deaths) as Total_Death_Count 
from PortfolioProject..Covid_Deaths$
--where location='United States'
WHERE continent is not null
Group by location
order by Total_Death_Count desc

--Let's break things down by Continent 
--This is the most accurate Query
select location, MAX(total_deaths) as Total_Death_Count 
from PortfolioProject..Covid_Deaths$
--where location='United States'
WHERE continent is null
Group by location
order by Total_Death_Count desc


--Showing Continents with the highest death count per population

select continent, MAX(total_deaths) as Total_Death_Count 
from PortfolioProject..Covid_Deaths$
--where location='United States'
WHERE continent is not null
Group by continent
order by Total_Death_Count desc



--GLOBAL NUMBERS

select date, SUM(new_cases) as Total_Cases, SUM(new_deaths) as Total_Deaths, SUM(new_deaths)/SUM(new_cases)*100 as Global_Death_Percentage
from PortfolioProject..Covid_Deaths$
where continent is not null
and new_cases > 0
Group By date
order by 1,2

--GLOBAL DEATH PERCENTAGE

select SUM(new_cases) as Total_Cases, SUM(new_deaths) as Total_Deaths, SUM(new_deaths)/SUM(new_cases)*100 as Global_Death_Percentage
from PortfolioProject..Covid_Deaths$
where continent is not null
and new_cases > 0
--Group by date
order by 1,2


--Joining tables together

select *
From PortfolioProject..Covid_Deaths$ dea
Join PortfolioProject..Covid_Vaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date


--Looking at total population vs. vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,
	dea.date) as RollingPeopleVaccinated
From PortfolioProject..Covid_Deaths$ dea
Join PortfolioProject..Covid_Vaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


--USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,
	dea.date) as RollingPeopleVaccinated
From PortfolioProject..Covid_Deaths$ dea
Join PortfolioProject..Covid_Vaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



--TEMP TABLE

DROP table if exists #Percent_Population_Vaccinated
Create Table #Percent_Population_Vaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #Percent_Population_Vaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,
	dea.date) as RollingPeopleVaccinated
From PortfolioProject..Covid_Deaths$ dea
Join PortfolioProject..Covid_Vaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #Percent_Population_Vaccinated



--Creating view to store data for later visualization

Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,
	dea.date) as RollingPeopleVaccinated
From PortfolioProject..Covid_Deaths$ dea
Join PortfolioProject..Covid_Vaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3 

Select *
From PercentPopulationvaccinated