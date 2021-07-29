-- 1) Looking at the whole data
SELECT *
FROM Covid_project..CovidDeaths
ORDER BY 3,4


-- 2) Looking as some of the important columns we will be using in further analysis
SELECT location, date, population, total_cases, total_deaths, new_cases, new_deaths, total_cases_per_million, total_deaths_per_million, icu_patients, hosp_patients
FROM Covid_project..CovidDeaths
ORDER BY 1,2


-- 3) total_cases vs population, total_deaths vs total_cases, total_deaths vs population
SELECT location, date, total_cases, (total_cases/population)*100 as PopulationInfectedRatio, total_deaths, (total_deaths/total_cases)*100 as MortalityRate, (total_deaths/population)*100 as PopulationDeathRatio
FROM Covid_project..CovidDeaths
ORDER BY 1,2


-- 4) Average, Maximum, Minimum mortality rate for each location
SELECT location, AVG(MortalityRate) as Avg_MortalityRate, MAX(MortalityRate) as Max_MortalityRate, MIN(MortalityRate) as Min_MortalityRate
FROM (
	SELECT location, (cast(total_deaths as int)/total_cases)*100 as MortalityRate
	FROM Covid_project..CovidDeaths
) as A
GROUP BY location
ORDER BY 2 DESC


-- Vanuata, Peru, Suden, Iran, Botswana 

-- 4a) Mortality rate of certains country whichg are looking suspicious
SELECT location, date, population, total_cases, total_deaths, new_cases, new_deaths, (cast(total_deaths as int)/total_cases)*100 as MortalityRate
FROM Covid_project..CovidDeaths
WHERE location in ('Botswana', 'Vanuatu', 'Peru', 'Sudan', 'Iran')
ORDER BY 1,2

SELECT location, date, population, total_cases, total_deaths, new_cases, new_deaths, (cast(total_deaths as int)/total_cases)*100 as MortalityRate
FROM Covid_project..CovidDeaths
WHERE location = 'Yemen'
ORDER BY 1,2


-- 5) maximum total_cases/population ratio by location
SELECT location, population, MAX(total_cases) as MaxTotalCases, (MAX(total_cases/population))*100 as MaxTotalCasesRatio
FROM Covid_project..CovidDeaths
GROUP BY location, population
ORDER BY 4 DESC


-- 6) maximum total_deaths/popultaion ration by location
SELECT location, population, MAX(cast(total_deaths as int)) as HighestTotalDeaths, (MAX(cast(total_deaths as int)/population))*100 as HighestTotalDeathRatio
FROM Covid_project..CovidDeaths
GROUP BY location, population
ORDER BY 4 DESC


-- 7) looking at total_cases_per_million
SELECT location, date, population, total_cases, total_cases_per_million
FROM Covid_project..CovidDeaths
ORDER BY 1,2


-- 8) maximum total_cases_per_million ny location 
SELECT location, population, MAX(cast(total_cases_per_million as float)) as MaxTotalCasesPerMillion
FROM Covid_project..CovidDeaths
GROUP BY location, population
ORDER BY 3 DESC


-- 9) maximum total_deaths_per_million ny location 
SELECT location, population, MAX(cast(total_deaths_per_million as float)) as MaxTotalDeathsPerMillion
FROM Covid_project..CovidDeaths
GROUP BY location, population
ORDER BY 3 DESC


-- 10) looking at icu_patients
SELECT location, date, total_cases, new_cases, cast(icu_patients as int) as IcuPatients
FROM Covid_project..CovidDeaths
ORDER BY 1,2


-- 11) icu_patients vs new_cases
SELECT location, date, new_cases, cast(icu_patients as int) as IcuPatients, (cast(icu_patients as int)/new_cases)*100 as IcuPercentage
FROM (
	SELECT location, date, new_cases, icu_patients
	FROM Covid_project..CovidDeaths
	WHERE new_cases is not NULL AND new_cases != 0
	) as A
ORDER BY 1,2


-- 12) hospitalised patients
SELECT location, date, total_cases, new_cases, cast(hosp_patients as int) as HospitalisedPatients
FROM Covid_project..CovidDeaths
ORDER BY 1,2


-- 13) hospitalised patients vs new cases
SELECT location, date, new_cases, cast(hosp_patients as int) as HospitalisedPatients, (cast(hosp_patients as int)/new_cases)*100 as HospitalisedPatientsPercentage
FROM (
	SELECT location, date, new_cases, hosp_patients
	FROM Covid_project..CovidDeaths
	WHERE new_cases is not NULL AND new_cases != 0
	) as A
ORDER BY 1,2



-- 2) Analysing Covid Vaccination Data

-- 2.1) looking at data
SELECT *
FROM Covid_project..CovidVaccinations
ORDER BY 3,4


-- 2.2) new_test
SELECT location, date, new_tests
FROM Covid_project..CovidVaccinations
ORDER BY 1,2


-- 2.2a) First date of test
SELECT location, MIN(date) as FirstDateOfTest
FROM Covid_project..CovidVaccinations
GROUP BY location
ORDER BY 2


-- 2.3) total_test
SELECT location, date, cast(total_tests as int)
FROM Covid_project..CovidVaccinations
ORDER BY 1,2


-- 2.3a) maximum total_test
SELECT location, MAX(cast(total_tests as int))
FROM Covid_project..CovidVaccinations
GROUP BY location
ORDER BY 2 DESC


-- 2.4) Positive rate
SELECT location, date, cast(new_tests as int) as NewTests, cast(positive_rate as float) as PositiveRate
FROM Covid_project..CovidVaccinations
ORDER BY 1,2


-- 2.4a) Maximum, Minimum and Average Positive rate over location
SELECT location, Max(cast(positive_rate as float)) as MaxPositiveRate, AVG(cast(positive_rate as float)) as AvgPositiveRate, MIN(cast(positive_rate as float)) as MinPositiveRate
FROM Covid_project..CovidVaccinations
GROUP BY location
ORDER BY 3 DESC


-- 2.5) test_per_case
SELECT location, date, CAST(tests_per_case as float) as TestPerCase
FROM Covid_project..CovidVaccinations
ORDER BY  1,2


-- 2.4a) Maximum, Minimum and Average Tests per case over location
SELECT location, Max(cast(tests_per_case as float)) as MaxTestPerCase, AVG(cast(tests_per_case as float)) as AvgTestPerCase, MIN(cast(tests_per_case as float)) as MinTestPerCase
FROM Covid_project..CovidVaccinations
GROUP BY location
ORDER BY 3 DESC


-- 2.5) total vaccination
SELECT location, date, total_vaccinations
FROM Covid_project..CovidVaccinations
ORDER BY 1,2


-- 2.5a) MAximum Total Vaccination
SELECT location, MAX(CAST(total_vaccinations as BIGINT)) as MaxTotalVaccinations
FROM Covid_project..CovidVaccinations
GROUP BY location
ORDER BY 2 DESC



-- 3) Analysing both tables togethere


-- 3.1) population vs vaccinations
SELECT D.location, D.date, D.population, V.new_vaccinations
FROM Covid_project..CovidDeaths D
JOIN Covid_project..CovidVaccinations V
ON D.location = V.location AND D.date = V.date
ORDER BY 1,2


-- 3.2) Rolling vaccination
SELECT D.location, D.date, D.population, V.new_vaccinations, SUM(CAST(V.new_vaccinations as bigint)) OVER (PARTITION BY D.location ORDER BY D.date) AS RollingVaccination
FROM Covid_project..CovidDeaths D
JOIN Covid_project..CovidVaccinations V
ON D.location = V.location AND D.date = V.date
ORDER BY 1,2


-- 3.3) Rolling Vaccinations vs population

-- Using CTE
with VACCvsPOP (location, date, population, new_vaccinations, RollingVaccination)
as
(
SELECT D.location, D.date, D.population, V.new_vaccinations, SUM(CAST(V.new_vaccinations as bigint)) OVER (PARTITION BY D.location ORDER BY D.date) AS RollingVaccination
FROM Covid_project..CovidDeaths D
JOIN Covid_project..CovidVaccinations V
ON D.location = V.location AND D.date = V.date
)
SELECT location, population, MAX(RollingVaccination), MAX((RollingVaccination/population)*100) as MaxRollingVaccination
FROM VACCvsPOP
GROUP BY location, population
ORDER BY 4 DESC