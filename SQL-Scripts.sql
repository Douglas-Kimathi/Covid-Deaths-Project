
select * 
from Project5..CovidDeaths$
where continent is not null
order by 3,4

--SELECT THE DATA THAT WE WILL BE USING
Select location, date,total_cases, new_cases, total_deaths, population
from Project5..CovidDeaths$ 
where continent is not null
order by 1,2


--LOOKING AT TOTAL CASES VS TOTAL DEATHS
 --shows likelihood of dying if you contract covid in your country
Select location, date,total_cases, total_deaths,(total_deaths/total_cases)*100 as Death_Percentage
from Project5..CovidDeaths$ 
where continent is not null and
location like '%kenya%'
order by 1,2

--LOOKING AT THE TOTAL CASES VS THE POPULATION
Select location, date, population,total_cases,(total_cases/population)*100 as Percentage_Infected
from Project5..CovidDeaths$ 
where continent is not null
--where location like '%kenya%'
order by 1,2

--LOOKING AT COUNTRIES WITH THE HIGHEST INFECTION RATE COMPARED TO POPULATION
Select location,population,MAX(total_cases) AS Highest_Infection_Count,MAX((total_cases/population))*100 as Percentage_Infected
from Project5..CovidDeaths$ 
where continent is not null
--where location like '%kenya%'
group by location, population
order by Percentage_Infected desc


--SHOWING COUNTRIES WITH THE HIGHEST DEATH COUNT PER POPULATION
Select location,MAX(cast(total_deaths as int)) AS Total_Death_Count
from Project5..CovidDeaths$ 
where continent is not null
--where location like '%kenya%'
group by location
order by Total_Death_Count desc 


--LETS BREAK THINGS DOWN BY CONTINENT
--showing the continent with the highest death count
Select continent,MAX(cast(total_deaths as int)) AS Total_Death_Count
from Project5..CovidDeaths$ 
where continent is not null
--where location like '%kenya%'
group by continent
order by Total_Death_Count desc 

 

 --GLOBAL NUMBERS 
 --by each day
Select date,SUM(new_cases)as Total_Cases,SUM(CAST(new_deaths as int))AS Total_Deaths,SUM(CAST(new_deaths as int))/SUM(new_cases)*100  as Death_Percentage
from Project5..CovidDeaths$ 
where continent is not null
group by date
order by 1,2

--total
Select SUM(new_cases)as Total_Cases,SUM(CAST(new_deaths as int))AS Total_Deaths,SUM(CAST(new_deaths as int))/SUM(new_cases)*100  as Death_Percentage
from Project5..CovidDeaths$ 
where continent is not null
--group by date
order by 1,2


--COVID VACCINATIONS TABLE
--LOOKING AT TOTAL POPULATION VS VACCINATION
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) over(partition by dea.location order by dea.location,dea.date) as Rolling_People_Vaccinated
from Project5..CovidDeaths$ dea
join Project5..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 1,2

--Using CTE
With PopvsVac(Continent, Location, Date, Population, New_Vaccinations, Rolling_People_Vaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) over(partition by dea.location order by dea.location,dea.date) as Rolling_People_Vaccinated
from Project5..CovidDeaths$ dea
join Project5..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 1,2
)
Select *,(Rolling_People_Vaccinated/Population)*100 AS Vaccinated_Percentage
from PopvsVac

 

--Using Temp Table
Drop Table if exists #Vaccinated_Percentage
Create Table #Vaccinated_Percentage(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
Rolling_People_Vaccinated numeric
)

Insert into #Vaccinated_Percentage
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) over(partition by dea.location order by dea.location,dea.date) as Rolling_People_Vaccinated
from Project5..CovidDeaths$ dea
join Project5..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 1,2

Select *,(Rolling_People_Vaccinated/Population)*100 AS Vaccinated_Percentage
from #Vaccinated_Percentage


--Creating view to store data for later visualizations
--Vaccinated Percentage view
Create view Vaccinated_Percentage_View as
 select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) over(partition by dea.location order by dea.location,dea.date) as Rolling_People_Vaccinated
from Project5..CovidDeaths$ dea
join Project5..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

--TOTAL POPULATION VS VACCINATION View
Create view popvsvac_view as
	select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as int)) over(partition by dea.location order by dea.location,dea.date) as Rolling_People_Vaccinated
	from Project5..CovidDeaths$ dea
	join Project5..CovidVaccinations$ vac
		on dea.location = vac.location
		and dea.date = vac.date
	where dea.continent is not null


	--Global numbers by day view
Create view global_umbers_by_day as
	Select date,SUM(new_cases)as Total_Cases,SUM(CAST(new_deaths as int))AS Total_Deaths,SUM(CAST(new_deaths as int))/SUM(new_cases)*100  as Death_Percentage
	from Project5..CovidDeaths$ 
	where continent is not null
	group by date
	--order by 1,2

	--Global numbers -total
Create view global_numbers_total as
	Select SUM(new_cases)as Total_Cases,SUM(CAST(new_deaths as int))AS Total_Deaths,SUM(CAST(new_deaths as int))/SUM(new_cases)*100  as Death_Percentage
	from Project5..CovidDeaths$ 
	where continent is not null
	--group by date
	--order by 1,2


--Death count by continent view
Create view death_count_by_continent as
	Select continent,MAX(cast(total_deaths as int)) AS Total_Death_Count
	from Project5..CovidDeaths$ 
	where continent is not null
	--where location like '%kenya%'
	group by continent
	--order by Total_Death_Count desc 


--death count by population view
Create view death_count_by_population as
	Select location,MAX(cast(total_deaths as int)) AS Total_Death_Count
	from Project5..CovidDeaths$ 
	where continent is not null
	--where location like '%kenya%'
	group by location
	--order by Total_Death_Count desc 