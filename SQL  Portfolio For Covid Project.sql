select * 
from PortfolioProject.dbo.CovidDeaths
where continent is not null
order by 1,2


--Select Data that we are going to be using

SELECT Location, date, total_cases,new_cases,total_deaths,population
FROM PortfolioProject.dbo.CovidDeaths
ORDER BY 1,2

--Looking at Total Cases vs Total Deaths 

SELECT  Location,date,total_cases,total_deaths ,(total_cases/total_deaths )*100 as DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
--where location like  '%State%'
ORDER BY 1,2 

--Looking for Total Cases vs Population

--Shows Percentage of Population got covid-19 in Qatar

SELECT  Location,Date,total_cases,population ,(total_cases/population )*100 as CovidPercentageInQatar
FROM PortfolioProject.dbo.CovidDeaths
where Location like  'Qatar' 

ORDER BY Date asc

--Shows Percentage of Population got covid-19 in Qatar in 2023

SELECT  Location,Date,total_cases,population ,(total_cases/population )*100 as PercentPopulationAffectedInQatar23
FROM PortfolioProject.dbo.CovidDeaths
where Location like  'Qatar' and Date like '%2023%'
ORDER BY Date DESC

--looking at Countries with Highest Infection Rate compared to Population

SELECT  Location,population ,Max(total_cases) as HighestInfectionsCount,Max((total_cases/population ))*100 as PercentPopulationAffected
FROM PortfolioProject.dbo.CovidDeaths
Group by Location,population 
Order by PercentPopulationAffected desc

--Showing countries with Highest Death Count per Population

SELECT  continent ,Max(cast (total_deaths as int)) as TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
where (continent is not null )
Group by continent 
Order by TotalDeathCount desc


--Global Number

SELECT  date,SUM(cast(new_cases as int)) as TotalNewCases,SUM(cast(new_deaths as int)) as TotalNewDeaths
,(SUM(cast(new_deaths as int))/SUM(new_cases))*100 as DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
--where location like  '%State%'
where continent is not null --((new_deaths != 0 )and  (new_cases != 0  ))
ORDER BY 1,2 

--******************************************************************************************************************
--Looking at Total  Population Vs Vaccination

select C_Dea.continent ,C_Dea.location,C_Dea.date, C_Dea.population , C_Vacc.new_vaccinations 
,SUM(CAST(C_vacc.new_vaccinations AS bigint)) 
over (PARTITION by C_Dea.location  order by C_Dea.location , C_Dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/C_Dea.population)*100
from PortfolioProject..CovidDeaths C_Dea 
join PortfolioProject..CovidVaccinations C_Vacc
	on C_Dea.location = C_Vacc.location 
	and C_Dea.date = C_Vacc.date  
where C_Dea.continent is not null
order by 2,3

-- Use CTE

with PopVsVacc (continent ,location,date,population , new_vaccinations ,RollingPeopleVaccinated )

as 
(
select C_Dea.continent ,C_Dea.location,C_Dea.date, C_Dea.population , C_Vacc.new_vaccinations 
,SUM(CAST(C_vacc.new_vaccinations AS bigint)) 
over (PARTITION by C_Dea.location  order by C_Dea.location , C_Dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/C_Dea.population)*100
from PortfolioProject..CovidDeaths C_Dea 
join PortfolioProject..CovidVaccinations C_Vacc
	on C_Dea.location = C_Vacc.location 
	and C_Dea.date = C_Vacc.date  
where C_Dea.continent is not null
--order by 2,3
)

select *,(RollingPeopleVaccinated/population)*100 as PercentPopulationVaccinated
from PopVsVacc


--TEMP TABLE 
Drop table if exists #PercentPopulationVaccinated 

Create table #PercentPopulationVaccinated 
(
continent varchar(255),
Locationn varchar(255),
Datee datetime ,
Populations numeric ,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated  
select C_Dea.continent ,C_Dea.location,C_Dea.date, C_Dea.population , C_Vacc.new_vaccinations 
,SUM(CAST(C_vacc.new_vaccinations AS bigint)) 
over (PARTITION by C_Dea.location  order by C_Dea.location , C_Dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/C_Dea.population)*100
from PortfolioProject..CovidDeaths C_Dea 
join PortfolioProject..CovidVaccinations C_Vacc
	on C_Dea.location = C_Vacc.location 
	and C_Dea.date = C_Vacc.date  
where C_Dea.continent is not null
--order by 2,3


select *,(RollingPeopleVaccinated/populations)*100 as PercentPopulationVaccinated
from #PercentPopulationVaccinated 


--Creating view to store data for later use (Visualisation ... )

DROP VIEW PercentPopulationVaccinated

CREATE VIEW PercentPopulationVaccinated  as
select C_Dea.continent ,C_Dea.location,C_Dea.date, C_Dea.population , C_Vacc.new_vaccinations 
,SUM(CAST(C_vacc.new_vaccinations AS bigint)) 
over (PARTITION by C_Dea.location  order by C_Dea.location , C_Dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/C_Dea.population)*100
from PortfolioProject..CovidDeaths C_Dea 
join PortfolioProject..CovidVaccinations C_Vacc
	on C_Dea.location = C_Vacc.location 
	and C_Dea.date = C_Vacc.date  
where C_Dea.continent is not null

select * from PercentPopulationVaccinated