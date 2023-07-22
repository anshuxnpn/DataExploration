select location,date, total_cases,new_cases, total_deaths, population
from [PortfolioProject].[dbo].[covidDeath]
order by 1, 2

--looking at total cases vs total deaths
--shows likelihood of dying if you contract covid in India
select location,date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from [PortfolioProject].[dbo].[covidDeath] 
where location like 'India'
and continent is not null
order by 1, 2

--looking at total cases vs population
--shows what percentage of people got covid in India
select location,date, population, total_cases, (total_cases/population)*100 as InfectedPopulationPercentage
from [PortfolioProject].[dbo].[covidDeath] 
where location like 'India'
and continent is not null
order by 1, 2


--looking at countries with highest infection rate compared to population
select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as InfectedPopulationPercentage
from [PortfolioProject].[dbo].[covidDeath]
where continent is not null
group by location, population
order by InfectedPopulationPercentage desc


--countries with highest death count per population
select location, max(total_deaths)as TotalDeathCount
from [PortfolioProject].[dbo].[covidDeath] 
where continent is not null
group by location, population
order by TotalDeathCount desc


--let's break things down by continent
select continent, max(total_deaths)as TotalDeathCount
from [PortfolioProject].[dbo].[covidDeath] 
where continent is not null
group by continent
order by TotalDeathCount desc

--showing continents with highest death count per population
select continent, max(total_deaths)as TotalDeathCount
from [PortfolioProject].[dbo].[covidDeath] 
where continent is not null
group by continent
order by TotalDeathCount desc

--global numbers
select date, sum(new_cases) as totalCases, sum(new_deaths) as totalDeaths, sum(new_deaths)/sum(new_cases)*100 as deathPercentage
from [PortfolioProject].[dbo].[covidDeath] 
where continent is not null
group by date
having sum(new_cases) <> 0
and sum(new_deaths) <> 0
order by 1

--looking at total population vs vaccinations
select death.continent, death.location, death.date, death.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) over (partition by death.location order by death.location, death.date) as RollingPeopleVaccinated
from [PortfolioProject].[dbo].[covidDeath] death
join [PortfolioProject].[dbo].[covidVaccination] vac
on death.location = vac.location
and death.date = vac.date
where death.continent is not null
order by 2, 3

--create temp table
drop table if exists #VaccinatedPeoplePercentage
create table #VaccinatedPeoplePercentage
(
Continent nvarchar(250),
Location nvarchar(250),
Date datetime,
Population bigint,
New_Vaccinations bigint,
RollingPeopleVaccinated numeric
)

insert into #VaccinatedPeoplePercentage
select death.continent, death.location, death.date, death.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) over (partition by death.location order by death.location, death.date) as RollingPeopleVaccinated
from [PortfolioProject].[dbo].[covidDeath] death
join [PortfolioProject].[dbo].[covidVaccination] vac
on death.location = vac.location
and death.date = vac.date
--where death.continent is not null
--order by 2, 3

select *, (RollingPeopleVaccinated/ Population) * 100
from #VaccinatedPeoplePercentage

--creating view to store data for later visualization
create view VaccinatedPeoplePercentage as
select death.continent, death.location, death.date, death.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) over (partition by death.location order by death.location, death.date) as RollingPeopleVaccinated
from [PortfolioProject].[dbo].[covidDeath] death
join [PortfolioProject].[dbo].[covidVaccination] vac
on death.location = vac.location
and death.date = vac.date

create view DeathCountPerContinent as
select continent, max(total_deaths)as TotalDeathCount
from [PortfolioProject].[dbo].[covidDeath] 
where continent is not null
group by continent
--order by TotalDeathCount desc

