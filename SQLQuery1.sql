select *
from [PROTFOLIO PROJECT]..CovidDeaths
order by 3,4


--select *
--from [PROTFOLIO PROJECT]..CovidVaccination
--order by 3,4

--select Data that we going to be using

select location, date, total_cases, new_cases, total_deaths, population
from [PROTFOLIO PROJECT]..CovidDeaths
order by 1,2

--looking at Total cases vs total death

select location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from [PROTFOLIO PROJECT]..CovidDeaths
where location like '%states%'
order by 1,2


--Looking at total cases vs Population. What percentage population got covid in US.

select location, date, total_cases,  (total_cases/population)*100 as PopulationPercentage
from [PROTFOLIO PROJECT]..CovidDeaths
where location like '%states%'


---all Countries

select location, date, total_cases,  (total_cases/population)*100 as PopulationPercentageInfected
from [PROTFOLIO PROJECT]..CovidDeaths
--where location like '%states%'
order by 1,2



--Looking at countries with highest infection rate with population

select location, max(total_cases) as HighestInfectionCount, max(total_cases/population)*100 as PopulationPercentageInfected
from [PROTFOLIO PROJECT]..CovidDeaths
Group by location, population
order by PopulationPercentageInfected desc

--Showing countries with highest Death Count per population

select location, max(total_deaths) as HighestDeathCount, max(total_deaths/population)*100 as TotalDeathCount
from [PROTFOLIO PROJECT]..CovidDeaths
where continent is not null
Group by location

order by TotalDeathCount desc

--BY CONTINENT
select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from [PROTFOLIO PROJECT]..CovidDeaths
where continent is not null
Group by location
order by TotalDeathCount desc

--Showing continents with highest death count
select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from [PROTFOLIO PROJECT]..CovidDeaths
where continent is not null
Group by continent
order by TotalDeathCount desc

--Breaking Global numbers by date

Select date, SUM(new_cases)as TotalNewCases, sum(cast(new_deaths as int)) as TotalNewDeaths , sum(cast(new_deaths as int))/sum(new_cases)* 100 as DeathPercentage 
from [PROTFOLIO PROJECT]..CovidDeaths
where continent is not null
Group By date
Order By 1,2

---Global total deaths 
Select SUM(new_cases)as TotalNewCases, sum(cast(new_deaths as int)) as TotalNewDeaths , sum(cast(new_deaths as int))/sum(new_cases)* 100 as DeathPercentage 
from [PROTFOLIO PROJECT]..CovidDeaths
where continent is not null
--Group By date
Order By 1,2

--JOINING 2 TABLES 
--looking at Total population vs vaccination

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 , SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location,dea.date) as RollingVaccination
 , RollingVaccination/population *100

 
from [PROTFOLIO PROJECT]..CovidDeaths dea
join [PROTFOLIO PROJECT]..CovidVaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
order by 2,3


--use CTE-- common table expression - temporary table
with PopvsVac(Continent, location, date, population, New_Vaccination, RollingVaccination)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 , SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location,dea.date) as RollingVaccination
 
from [PROTFOLIO PROJECT]..CovidDeaths dea
join [PROTFOLIO PROJECT]..CovidVaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
--order by 2,3
)
select *, (RollingVaccination/population)*100 as PercentageRollingVac
from PopvsVac


--TEMP TABLE
DROP TABLE if exists #PercentagePopulationVaccinated
Create Table #PercentagePopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingVaccination numeric
)

Insert into #PercentagePopulationVaccinated

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 , SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location,dea.date) as RollingVaccination
 
from [PROTFOLIO PROJECT]..CovidDeaths dea
join [PROTFOLIO PROJECT]..CovidVaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
--order by 2,3

select *, (RollingVaccination/population)*100 as PercentageRollingVac
from #PercentagePopulationVaccinated


--Creating View to store data for Visualization

Create View PercentagePopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 , SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location,dea.date) as RollingVaccination
 
from [PROTFOLIO PROJECT]..CovidDeaths dea
join [PROTFOLIO PROJECT]..CovidVaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null

	select *
	From PercentagePopulationVaccinated