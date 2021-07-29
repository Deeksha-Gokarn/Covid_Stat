-- COVID CASES TABLE
Select * from Covid_Stat..Covid_DeathRate

-- Data to be used
Select Location, date, total_cases, new_cases, total_deaths, population
From Covid_Stat..Covid_DeathRate
Order by 1,2

--Calculate percentage of total cases and total deaths based on specific country
Select Location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
From Covid_Stat..Covid_DeathRate
Order by 1,2

--Death percentage of Germany due to covid from the year 2020(likely)
Select Location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
From Covid_Stat..Covid_DeathRate
Where Location = 'Germany'
Order by 1,2

--Percenatge of people affected by covid in Germany
Select Location, date, total_cases, new_cases, population, (total_cases/population)*100 as Affected_Percentage
From Covid_Stat..Covid_DeathRate
Where Location = 'Germany'
Order by 1,2

--Percenatge of people affected by covid in all the countries
Select Location, date, total_cases, new_cases, population, (total_cases/population)*100 as Affected_Percentage
From Covid_Stat..Covid_DeathRate
Order by 1,2

--Countries with high infection rate
Select Location, population, MAX(total_cases) as Infection_count, MAX((total_cases/population))*100 as Infected_Population_Percentage
From Covid_Stat..Covid_DeathRate
Group by location, population
Order by Infected_Population_Percentage desc

--Countries with high death count
Select Location, MAX(cast(total_deaths as INT)) as TotalDeathCount
From Covid_Stat..Covid_DeathRate
Where continent is not null
Group by location
Order by TotalDeathCount desc

--Continents with high death count
Select continent, MAX(cast(total_deaths as INT)) as TotalDeathCount
From Covid_Stat..Covid_DeathRate
Where continent is not null
Group by continent
Order by TotalDeathCount desc

-- Global rate
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100
as DeathPrcentage
From Covid_Stat..Covid_DeathRate
Where continent is not null
-- Group by continent
Order by 1,2

-- VACCINATION TABLE

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From Covid_Stat..Covid_DeathRate dea
Join Covid_Stat..Covid_Vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 1,2,3

-- Rolling count of the vaccinated people 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as Vaccinated_rollcount
From Covid_Stat..Covid_DeathRate dea
Join Covid_Stat..Covid_Vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- CTE
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, Vaccinated_rollcount)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as Vaccinated_rollcount
From Covid_Stat..Covid_DeathRate dea
Join Covid_Stat..Covid_Vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
Select *,(Vaccinated_rollcount/Population)*100
From PopvsVac

--Data Visualization
Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as Vaccinated_rollcount
From Covid_Stat..Covid_DeathRate dea
Join Covid_Stat..Covid_Vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

Select *
From PercentPopulationVaccinated