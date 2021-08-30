Select *
From CovidProject..covid_death
order by 3,4

--Select *
--From CovidProject..covid_vaccination
--order by 3,4

-- Select data we are going to be using 
Select location, date, total_cases, new_cases, total_deaths, population
From CovidProject..covid_death
order by 1,2

-- Looking at Total Cases vs Total Deaths in the United Kingdom
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
From CovidProject..covid_death
Where location like '%kingdom%'
order by 1,2

-- Looking at Total Cases vs Population
Select location, date, total_cases, population, (total_cases/population)*100 as cases_percentage
From CovidProject..covid_death
--Where location like '%kingdom%'
order by 1,2

-- Looking at countries with highest infection rate per population
Select location, population, MAX(total_cases) as highest_infection_count, Max((total_cases/population))*100 as cases_percentage
From CovidProject..covid_death
--Where location like '%kingdom%'
Group by location, population
order by cases_percentage desc

-- Looking at countries with highest death count per population
Select location,  MAX(cast(total_deaths as int)) as total_death_count
From CovidProject..covid_death
where continent is not null
Group by location
order by total_death_count desc

-- Looking at countries with highest death count per continent
Select location,  MAX(cast(total_deaths as int)) as total_death_count
From CovidProject..covid_death
where continent is null
Group by location
order by total_death_count desc

-- Showing continents with highest death count per population
Select continent,  MAX(cast(total_deaths as int)) as total_death_count
From CovidProject..covid_death
where continent is not null
Group by continent
order by total_death_count desc

-- Global numbers per day
Select date, SUM(new_cases) as total_new_cases, SUM(cast(new_deaths as int)) as total_new_deaths, sum(cast(new_deaths as int))/ sum(new_cases) * 100 as death_percentage
From CovidProject..covid_death
Where continent is not null
Group by date
order by 1,2


-- Global numbers
Select SUM(new_cases) as total_new_cases, SUM(cast(new_deaths as int)) as total_new_deaths, sum(cast(new_deaths as int))/ sum(new_cases) * 100 as death_percentage
From CovidProject..covid_death
Where continent is not null
order by 1,2

-- vaccinations per day in total population
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as rolling_vaccination_count

From CovidProject..covid_death dea
Join CovidProject..covid_vaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 1,2,3

-- Use CTE
with pop_vs_vac (Continent, Location, Date, Population, newVaccinations, rollingVaccinationCount)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as rolling_vaccination_count

From CovidProject..covid_death dea
Join CovidProject..covid_vaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
Select *, (rollingVaccinationCount/Population)*100 as rollingVaccinationPercentage
From pop_vs_vac

-- temp table
DROP Table if Exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
rolling_vaccination_count numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as rolling_vaccination_count

From CovidProject..covid_death dea
Join CovidProject..covid_vaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

Select *, (rolling_vaccination_count/Population)*100 
From  #PercentPopulationVaccinated

-- Create view to store data for later visualization

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as rolling_vaccination_count

From CovidProject..covid_death dea
Join CovidProject..covid_vaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

--Select *
--From PercentPopulationVaccinated
