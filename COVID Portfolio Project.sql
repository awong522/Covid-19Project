
select *
From PortfolioProject..CovidDeaths$
where continent is not Null
order by 3,4

--select *	
--From PortfolioProject..CovidVaccinations$
--order by 3,4

-- select data that we are going to be using 
--1.
Select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as Int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths$
where continent is not null 
order by 1,2

--Looking at total deaths
--2.
Select Location, SUM(cast(new_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths$
--where location like '%states%'
where continent is null
and location not in ('World','European Union','International')
group by location
order by TotalDeathCount desc

--Looking at the total cases vs population
--Shows that percentage of population got Covid
--3.
Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentagePopulationInfected
from PortfolioProject..CovidDeaths$
--where location like '%states%'
group by location, population
order by PercentagePopulationInfected desc


--Looking at countries with highest infection rate compared to population
--4.
Select Location, Population,date, Max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentagePopulationInfected
from PortfolioProject..CovidDeaths$
--where location like '%states%'
Group by Location, population, date
order by PercentagePopulationInfected desc

--Showing Countries with highest death count per population

Select Location, Max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths$
--where location like '%states%'
where continent is not Null
Group by Location
order by TotalDeathCount desc


--Break things down by continent 

Select continent, Max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths$
--where location like '%states%'
where continent is not Null
Group by continent
order by TotalDeathCount desc


--Showing continents with the highest death count per population 

Select continent, Max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths$
--where location like '%states%'
where continent is not Null
Group by continent
order by TotalDeathCount desc
 

--Global Numbers

Select Sum(new_cases) as total_cases, Sum(cast(new_deaths as int)) as total_deaths, Sum(cast
	(new_deaths as int))/sum (new_cases) *100 as DeathPercentage
from PortfolioProject..CovidDeaths$
--where location like '%states%'
where continent is not Null
--Group by date 
order by 1,2


--Looking at total population vs vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--Use CTE

With PopvsVac (continent, location, date, population, New_Vaccinations, RollingPeopleVaccinated)
as 
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac

--Temp Table

Drop table if exists #PercentPopulationvaccinated
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
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated


--Creating view to store later visualizations

Create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select * 
from PercentPopulationVaccinated
