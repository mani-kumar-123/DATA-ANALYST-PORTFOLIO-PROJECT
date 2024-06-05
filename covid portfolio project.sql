select * from PortfolioProject..coviddeaths order by 3,4


--select * from PortfolioProject..covidvactination order by 3,4

select location,date,total_cases,new_cases,total_deaths,population from PortfolioProject..coviddeaths

--looking at total cases vs total deaths

-- shows likelihood of dying by contacting coivid

select location,date,total_cases,total_deaths,(TRY_CAST(total_deaths AS NUMERIC(10, 2)) / NULLIF(TRY_CAST(total_cases AS NUMERIC(10, 2)), 0)) * 100.0 as deathpercentage
from PortfolioProject..coviddeaths 
where location like '%state%' order by 1,2


--looking total cases vs populations

select location,date,population,total_cases,(TRY_CAST(total_cases AS NUMERIC(10, 2)) / NULLIF(TRY_CAST(population AS NUMERIC(10, 2)), 0)) * 100.0 as deathpercentage
from PortfolioProject..coviddeaths 
where location like '%state%' order by 1,2



--LOOKING AT COUNTRIES WITH HIGHEST INFECTION RATE COMPARED TO POPULATIONS
select location,date,population,total_cases,(TRY_CAST(total_cases AS NUMERIC(10, 2)) / NULLIF(TRY_CAST(population AS NUMERIC(10, 2)), 0)) * 100.0 as deathpercentage
from PortfolioProject..coviddeaths 
where location like '%state%' order by 1,2


select location,max(total_cases) as highestinfrctioncount,MAX((TRY_CAST(total_cases AS NUMERIC(10, 2)) / NULLIF(TRY_CAST(population AS NUMERIC(10, 2)), 0)))* 100.0 as percentageofpopulationinfected
from PortfolioProject..coviddeaths 
Group by location,population
order by percentageofpopulationinfected desc


--showing deaths with highesst death count per population

select location,MAX(total_deaths) as totaldeathcount from portfolioproject..coviddeaths
where continent is not null
Group by location,population
order by totaldeathcount desc


--breaking the things down by continent

select continent,MAX(cast(total_deaths as int)) as totaldeathcount from portfolioproject..coviddeaths
where continent is not null
Group by continent
order by totaldeathcount desc

--glibal numbers

select sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_deaths,sum(new_deaths)/sum(cast(new_deaths as int))/sum(new_cases)*100 as deathpercentage from portfolioproject..coviddeaths
where continent is not null

order by 1,2


--loomking at total population vs vaccinations

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(TRY_CAST(vac.new_vaccinations AS NUMERIC(10, 2))) over (partition by  dea.location order by dea.location, dea.date) as rollingpeopeoplevacinated
--(rollingpeopeoplevacinated/population)*100
from PortfolioProject..coviddeaths dea
join portfolioproject..covidvactination vac
   on dea.location=vac.location
   and dea.date=vac.date
where dea.continent is not null
order by 2,3
 



 --use cte

 with popvsvac(continent,location,date,population,rollingpeopeoplevacinated,new_vaccinations)
 as
 (
 select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(TRY_CAST(vac.new_vaccinations AS NUMERIC(10, 2))) over (partition by  dea.location order by dea.location, dea.date) as rollingpeopeoplevacinated
--(rollingpeopeoplevacinated/population)*100
from PortfolioProject..coviddeaths dea
join portfolioproject..covidvactination vac
   on dea.location=vac.location
   and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)

select *, (rollingpeopeoplevacinated/population)*100 
from popvsvac


--create tem
drop table if exists #percentpopulationvaccinated
create table #percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeopeoplevacinated numeric
)

 insert into #percentpopulationvaccinated
 select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(TRY_CAST(vac.new_vaccinations AS NUMERIC(10, 2))) over (partition by  dea.location order by dea.location, dea.date) as rollingpeopeoplevacinated
--(rollingpeopeoplevacinated/population)*100
from PortfolioProject..coviddeaths dea
join PortfolioProject..covidvactination vac
   on dea.location=vac.location
   and dea.date=vac.date
where dea.continent is not null
order by 2,3
 select *,(rollingpeopeoplevacinated/population)*100
 from #percentpopulationvaccinated


--- create view to store data for later visualisation


USE PortfolioProject go
create view percentpopulationvaccinated
as
 select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(TRY_CAST(vac.new_vaccinations AS NUMERIC(10, 2))) over (partition by  dea.location order by dea.location, dea.date) as rollingpeopeoplevacinated
--(rollingpeopeoplevacinated/population)*100
from PortfolioProject..coviddeaths dea
join PortfolioProject..covidvactination vac
   on dea.location=vac.location
   and dea.date=vac.date
   where dea.continent is not null
group by 
   dea.continent,																														
   dea.location,dea.date,
  dea.population,
  vac.new_vaccinations

--order by 2,

select * from percentpopulationvaccinated

select *
 from #percentpopulationvaccinated