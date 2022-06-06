Select *
From PortfolioProject..CovidDeaths
Order by 3,4

----Select *
----From PortfolioProject..CovidVaccinations
----Order by 3,4

----Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Order by 1,2


---- Looking at Total Cases vs Total Deaths
---- Shows likelihood of dying if you contract covid in your country

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
From PortfolioProject..CovidDeaths
WHERE location like '%states%'
Order by 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got COVID

Select Location, date, total_cases, population, (total_cases/population)*100 as Percent_of_Population_Infected
From PortfolioProject..CovidDeaths
WHERE location like '%states%'
Order by 1,2

-- Looking at Countries with Hightest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as Highest_Infection_Count, MAX((total_cases/population))*100 as Percent_of_Population_Infected
From PortfolioProject..CovidDeaths
--WHERE location like '%states%'
Group by location, population
Order by Percent_of_Population_Infected desc

-- Showing Countries with Highest Death Count per Population

Select Location, MAX(cast(total_deaths as int)) as Total_Death_Count
From PortfolioProject..CovidDeaths
--WHERE location like '%states%'
Where continent is not null
Group by location
Order by Total_Death_Count desc

-- Showing Continents by Highest Death Count per Population

Select continent, MAX(cast(total_deaths as bigint)) as Total_Death_Count
From PortfolioProject..CovidDeaths
--WHERE location like '%states%'
Where continent is not null
Group by continent
Order by Total_Death_Count desc

-- Global Numbers

Select date, SUM(new_cases) as Total_Cases, SUM(CAST(new_deaths as int)) as Total_Deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as Death_Percentage
From PortfolioProject..CovidDeaths
Where continent is not null
Group by date
Order by 1,2


--Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From PortfolioProject..CovidDeaths as dea
Join PortfolioProject..CovidVaccinations as vac
	On  dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2,3  



Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as Rolling_People_Vaccinated
From PortfolioProject..CovidDeaths as dea
Join PortfolioProject..CovidVaccinations as vac
	On  dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2,3

-- Use CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, Rolling_People_Vaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as Rolling_People_Vaccinated
From PortfolioProject..CovidDeaths as dea
Join PortfolioProject..CovidVaccinations as vac
	On  dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3
)
Select *, (Rolling_People_Vaccinated/Population)*100
From PopvsVac

-- Temp Table

DROP TABLE if exists #Percent_Population_Vaccinated
Create Table #Percent_Population_Vaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
Rolling_People_Vaccinated numeric
)
Insert into #Percent_Population_Vaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as Rolling_People_Vaccinated
From PortfolioProject..CovidDeaths as dea
Join PortfolioProject..CovidVaccinations as vac
	On  dea.location = vac.location
	and dea.date = vac.date
--Where dea.continent is not null
--Order by 2,3

Select *, (Rolling_People_Vaccinated/Population)*100
From #Percent_Population_Vaccinated


-- Creating View to Store Data for Later Visulaizations

Create View Percent_Population_Vaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as Rolling_People_Vaccinated
From PortfolioProject..CovidDeaths as dea
Join PortfolioProject..CovidVaccinations as vac
	On  dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3

Select *
From  Percent_Population_Vaccinated