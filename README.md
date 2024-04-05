# Covid Data Analysis and Dashboard Creation Project (SQL, PowerBI, Tableau)



## Introduction:

The Covid-19 pandemic, which gripped the world for several years, brought about unprecedented challenges and disruptions to societies, economies, and healthcare systems worldwide. While the acute phase of the pandemic may have ended, its impact continues to reverberate across the globe. This project seeks to examine the multifaceted aspects of the Covid-19 pandemic through a data-driven lens. By analyzing and visualizing Covid-19 data, this project aims to understand the spread, severity, and mitigation efforts related to the virus across the continents.

In this project I have created dashboards in both PowerBI and Tableau.

<br/><br/>

## Project Overview

### Data Source

The data set includes all the data relevant to the COVID virus and vaccines from 2020-01-01 to 2021-04-30. The files will be added as "CovidDeaths.xlsx" and "CovidVaccinations.xlsx". 

### Objectives

The objectives of the Covid Data Analysis project are as follows:

1. Understand the Impact: Analyze Covid-19 data to identify the most affected countries and continents, considering metrics such as total cases, deaths, and prevalence rates.

2. Correlate with Socioeconomic Factors: Explore correlations between Covid-19 outcomes and socioeconomic factors such as average GDP per capita, population density, and average age of populations.

3. Examine Temporal Trends: Investigate the evolution of Covid-19 cases over time by analyzing trends by date, assessing changes in infection rates, and understanding the progression of the pandemic.

4. Evaluate Vaccination Efforts: Analyze vaccination data by continent and date to assess the progress and effectiveness of vaccination campaigns in different regions.

5. Assess Positive Rate and Testing: Examine the positive rate of Covid-19 tests in different continents and countries, alongside the number of tests conducted, to evaluate testing strategies and healthcare capacity.

<br/><br/>

<br/><br/>

## Tools and Technologies:

 - Microsoft SQL Server Management Studio for data manipulation and analysis.
 - PowerBI for Data visualization, Statistical analysis and Dashboard creation.
 - Tableau for Dashboard creation
 - Obsidian for documentation purposes.

<br/><br/>

## Microsoft SQL Server Management Studio:
<br/><br/>



### Overview of CovidDeaths Table:

```sql
Select *
from CovidDeaths
order by Location, date
```

<br/><br/>



### Likelihood of Dying from Covid-19:


```sql
Select Location, date, total_cases, total_deaths, ((total_deaths/total_cases)*100) AS DeathPercentage
From CovidDeaths
order by Location, date
```

<br/><br/>

### Total Cases vs Population:


```sql
Select Location, date, total_cases, population, ((total_cases/population)*100) AS CasePercentage
From CovidDeaths
order by Location, date
```

<br/><br/>

### Countries with Highest Infection Rates (CTE):


```sql
WITH CasePercent AS (
    Select location, ((total_cases/population)*100) AS CasePercentage
    From CovidDeaths
) 
Select Location , MAX(CasePercentage) AS MaxCase
From CasePercent
Group by Location
Order by MaxCase DESC
```

<br/><br/>


### Countries with Highest Death Rates:


```sql
Select Location, Max(Cast(total_deaths as int)/population)*100 As DeathPercent
From CovidDeaths
Group by Location
Order by DeathPercent DESC
```

<br/><br/>



### Analysis of Locations with and without Continent Information:


```sql
-- Comparing the accuracy of data between locations with and without continent information
Select *
from CovidDeaths
WHERE continent is null
order by Location, date
```

<br/><br/>



### Accurate vs Less Accurate Data Comparison:

In this step, we observe that certain entries in the "Location" column contain aggregated data for each continent, with corresponding totals for deaths, cases, and other metrics. Remarkably, these entries include the respective continent label within the "Location" column. This presentation appears to offer a more precise representation compared to instances where the continent is not explicitly listed in the "Location" column. 


```sql
-- Compares the accuracy of total death counts between locations with and without continent information
-- More accurate
Select location, Max(Cast(total_Deaths as Int))
From CovidDeaths
Where Continent is null
group by location
order by 2 DESC

-- Less accurate
Select continent, Max(Cast(total_Deaths as Int))
From CovidDeaths
Where Continent is not null
group by continent
order by 2 DESC
```

<br/><br/>



### Highest Death Rate per Population by Location:


```sql
Select location, Max(Cast(total_Deaths as Int)/population)*100 as DeathPopRate
From CovidDeaths
Where Continent is null
group by location
order by 2 DESC
```

<br/><br/>

### Global Covid-19 Analysis:


```sql
-- Accumulated Deaths, Cases, and Death Percentage by Day
WITH d AS ( 
    SELECT date, SUM(Cast(total_deaths as float)) as World_Deaths, SUM(Cast(total_cases as float)) as World_Cases
    From CovidDeaths
    Where continent is null
    group by date
)
Select date, MAX(World_Deaths) as World_Deaths, MAX(World_Cases) as World_Cases, 
    CASE
        WHEN MAX(World_Cases) > 0 THEN (MAX(World_Deaths) / MAX(World_Cases))* 100
        ELSE NULL  -- Handle division by zero
    END AS DeathPercentage
From d
group by date
order by date asc
```

<br/><br/>


### Daily Deaths, Cases, and Death Percentage:


```sql
-- Deaths, Cases, and Death Percentage day by day
Select date, sum(new_cases) as World_cases, sum(cast(new_deaths as int)) as World_deaths, 
    CASE
        WHEN SUM(new_cases) > 0 THEN SUM(cast(new_deaths as float))/SUM(new_cases)*100.0
        ELSE NULL -- Handle division by zero
    END AS Deathpercentage
From CovidDeaths
Where continent is null
Group by date
order by date asc
```

<br/><br/>




### Total population vs Vaccinations:


```sql
--- joining tables

select * 
from CovidDeaths dea
JOIN CovidVaccinations vac
	on dea.location = vac.location AND
	dea.date = vac.date
```



```sql
select dea.location, dea.continent, dea.date, vac.new_vaccinations, dea.population
from CovidDeaths dea
JOIN CovidVaccinations vac
	on dea.location = vac.location AND
	dea.date = vac.date
Where vac.new_vaccinations IS NOT NULL AND dea.continent IS NOT NULL 
```





<br/><br/>


### Accumulated vacinations by days by country and vaccination percentage against population:


```sql
Select dea.date, dea.continent, dea.location, 
	SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.continent, dea.location ORDER BY dea.date) AS rolling_vaccinations, 
	vac.new_vaccinations, 
	(SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.continent, dea.location ORDER BY dea.date)/dea.population)*100 as VaccinationPercentage,
	dea.population
from CovidDeaths dea
JOIN CovidVaccinations vac
	on dea.location = vac.location AND
	dea.date = vac.date
Where dea.continent is not null
group by dea.date, dea.continent,dea.location, dea.population,vac.new_vaccinations
```

Same but with a CTE:

```sql
WITH f as(
Select dea.date, dea.continent, dea.location, 
	SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.continent, dea.location ORDER BY dea.date) AS rolling_vaccinations, 
	vac.new_vaccinations, dea.population
from CovidDeaths dea
JOIN CovidVaccinations vac
	on dea.location = vac.location AND
	dea.date = vac.date
Where dea.continent is not null
group by dea.date, dea.continent,dea.location, dea.population,vac.new_vaccinations
)

SELECT date, continent, location, rolling_vaccinations, new_vaccinations, (rolling_vaccinations/population)*100 as Vac_Percentage, population
FROM f
```


<br/><br/>

### SQL Entries for Tableau Visualizations:


```sql

--1

Select SUM(new_cases) as Total_cases, SUM(cast(new_deaths as int)) as Total_deaths, (SUM(cast(new_deaths as float)) / SUM(new_cases)) * 100 as DeathPercentage
from CovidDeaths
where continent is not null


--2

Select location, sum(cast(new_deaths as int)) as TotalDeathCount
from CovidDeaths
where continent is null 
and location not in ('European Union','International','World')
group by location
order by TotalDeathCount desc


--3

Select location, Population, MAX(total_cases) as HighestInfectionCount, Max(total_cases/population)*100 as PercentPopulationInfected
From CovidDeaths
group by location, population
order by PercentPopulationInfected desc


--4

Select Location, population, date, MAX(total_cases) as HighestInfectionCount, Max(total_cases/population)*100 as PercentPopulationInfected
From CovidDeaths
group by Location, population, Date
order by PercentPopulationInfected desc
```

<br/><br/>

## Summary of Dashboards Insights:

### General Page:

 - Population Density Analysis: The stacked bar chart provides insights into population density across different continents, highlighting variations in population distribution.
 - Cases Per Million Examination: This visualization offers a comparative view of Covid-19 cases per million people across continents, indicating the relative severity of outbreaks.
 - Healthcare Infrastructure Assessment: Utilizing the hospital beds per thousand stacked bar chart, we can gauge the availability of healthcare resources in different continents, crucial for managing Covid-19 cases effectively.
 - Temporal Trends Analysis: The clustered column chart depicting cases by date helps track the progression of Covid-19 over time, identifying peaks and trends.
 - Economic Impact Consideration: The pie chart illustrating average GDP per capita by continent provides insights into the economic landscape amid the pandemic.
 - Overall Pandemic Status: The total cases card presents a snapshot of the cumulative Covid-19 cases, serving as a key indicator of the pandemic's scale.


<br/><br/>

### Cases and Deaths Page:

 - Regional Covid-19 Distribution: Stacked bar charts for cases and deaths by continent offer insights into the geographical spread of Covid-19 and associated fatalities.
 - Population Dynamics Overview: The stacked bar chart depicting population by continent highlights demographic variations, influencing the pandemic's impact.
 - Vulnerable Population Analysis: The clustered column chart focusing on the population aged 70 or older by continent sheds light on the vulnerability of certain age groups to severe outcomes.
 - Country-Level Analysis: The pie chart showcasing cases by country provides a breakdown of Covid-19 cases, aiding in identifying hotspots and patterns.
 - Fatality Status: The total deaths card presents a summary of the cumulative Covid-19 fatalities, offering perspective on the human toll of the pandemic.


<br/><br/>

### Vaccinations and Tests Page:

 - Vaccination Progress Assessment: The stacked bar chart visualizes vaccinations by continent, facilitating the evaluation of vaccination campaigns' effectiveness across regions.
 - Testing Strategy Evaluation: The stacked bar chart for tests by country offers insights into testing efforts, essential for monitoring and controlling the spread of Covid-19.
 - Infection Rate Analysis: The positive rate by continent stacked bar chart provides an overview of Covid-19 infection rates across different regions.
 - Vaccine Coverage Overview: The pie chart depicting fully vaccinated people by continent highlights progress towards achieving herd immunity.
 - Temporal Vaccination Trends: The clustered column chart showcasing vaccinations by date helps track the pace and distribution of vaccination efforts over time.
 - Current Vaccination Status: The total vaccinations card summarizes the total number of Covid-19 vaccine doses administered, indicating progress towards immunization goals.

<br/><br/>

### Tableau Dashboard:

 - Continental Covid-19 Impact: Analysis of total deaths and cases per continent provides a comprehensive understanding of the pandemic's toll on different regions.
 - Country-Level Infection Rates: The map illustrating percent population infected per country offers a visual representation of Covid-19 prevalence globally.
 - Population Infected Trends: Graphs depicting percent population infected for select countries and predictions aid in forecasting and decision-making.

<br/><br/>


## Dashboard images:

### Power BI:
<br/><br/>
![image](https://github.com/DiogoGravanita/Covid-SQL-PowerBI-Tableau-DataAnalysisProject/assets/163042130/84bc8a23-6748-4749-a40c-60a23c72c6d2)

<br/><br/>
![image](https://github.com/DiogoGravanita/Covid-SQL-PowerBI-Tableau-DataAnalysisProject/assets/163042130/1aacdd36-5ac3-4b5a-b518-b4f4726965d3)

<br/><br/>
![image](https://github.com/DiogoGravanita/Covid-SQL-PowerBI-Tableau-DataAnalysisProject/assets/163042130/7958f409-1071-4b7f-ac45-35cfb76e44e7)

<br/><br/>

### Tableau:

![image](https://github.com/DiogoGravanita/Covid-SQL-PowerBI-Tableau-DataAnalysisProject/assets/163042130/0b40c643-a5a4-4f14-aeab-25b2ab25b6cd)





<br/><br/>
<br/><br/>
# Results/findings
<br/><br/>


## Understanding the Impact

 - Analyzing COVID-19 data reveals the severity of the pandemic across continents. Europe stands out with the highest average GDP per capita at $33k, followed by Asia ($23k), North America ($18k), Oceania ($17k), South America ($13k), and Africa ($5k). This economic disparity impacts healthcare infrastructure and the ability to mitigate the spread.
 - A correlational analysis between average GDP per capita and healthcare infrastructure reveals a significant relationship. Europe leads with five hospital beds per thousand, indicating robust healthcare systems. Asia follows with three beds per thousand, while North America and Oceania trail behind. This suggests that regions with higher GDP per capita tend to invest more in healthcare, potentially contributing to lower mortality rates.
 - Europe also reports the highest cases per million average, exceeding 20,000, followed by South America (13,500), Asia and North America (8,000), Africa (2,000), and Oceania (200). Despite Europe's robust healthcare infrastructure, its high population density challenges containment efforts.
 - Population density further elucidates the impact of the pandemic. Europe and Asia lead with an average population density of 600 people per square mile, while North America (194), Africa (100), Oceania (52), and South America (24) trail behind. Notably, South America's relatively low population density contrasts with its high incidence of cases, suggesting systemic challenges in disease management.

<br/><br/>


##  Correlation with Socioeconomic Factors:


 - Examining the population demographics reveals Europe's significant elderly population, with over 200 million individuals aged 70 or older. Asia follows with 81 million, North America with 50 million, Africa with 48 million, and South America with 26 million. This demographic composition significantly impacts mortality rates, as older individuals are more vulnerable to severe outcomes.
 - South America's unique demographic profile raises questions about its vulnerability to the pandemic. Despite its lower elderly population compared to Europe and North America, South America reports a high death toll of 670k. This disparity underscores the need for nuanced analyses considering socioeconomic and demographic factors.
 - Comparing total populations across continents further elucidates disparities. While South America comprises more than half the population of Europe, its elderly population amounts to only 10% of it. This discrepancy highlights the complex interplay between demographics and pandemic outcomes.

<br/><br/>

## Temporal Trends and Evolution:

- Temporal analysis reveals the dynamic nature of the pandemic. The virus's spread accelerated from March 2020, peaking between November 2020 and February 2021. Despite temporary declines, subsequent surges underscore the challenges of sustained containment efforts.
- Understanding temporal trends is crucial for anticipating future outbreaks and guiding public health interventions. Continuous monitoring and analysis of infection rates are essential for effective pandemic management.

<br/><br/>

## Evaluation of Vaccination Efforts:

 - Vaccination campaigns play a pivotal role in controlling the pandemic. Asia leads in total vaccinations administered, with 535 million doses, followed by North America (280 million), Europe (220 million), South America (75 million), Africa (17.5 million), and Oceania (2.5 million). Notably, North America's robust vaccination efforts are commendable given its population size.
 - Analysis of fully vaccinated populations across continents underscores regional disparities. North America reports 37 million fully vaccinated individuals, followed by Europe (19 million), Asia (17 million), South America (6.5 million), and Africa (2 million). These figures reflect varying degrees of success in vaccination campaigns and highlight areas requiring further attention.

Noteworthy:
 - North America and Europe demonstrated remarkable vaccination efforts relative to their population sizes.
 - Despite its large population, North America's administration of 280 million doses showcases effective distribution strategies.
 - Europe's distribution of 220 million doses also reflects a proactive approach to vaccination campaigns.
 - Asia's administration of 535 million doses, while substantial, may not be as impressive given its sizable population of nearly 5 billion.
 - The disparity in fully vaccinated populations reflects the effectiveness of vaccination campaigns in North America and Europe, despite their lower total vaccination numbers compared to Asia.
 - North America's success in achieving a high number of fully vaccinated individuals stands out, considering its population size relative to other continents.

<br/><br/>

## Assessment of Positive Rate and Testing:
 - Robust testing strategies are essential for early detection and containment of the virus. The United States leads in the number of tests conducted, with 400 million, followed by India (281 million), the UK (150 million), Russia (110 million), France (75 million), and Italy (50 million).
 - Positive rates of COVID-19 tests provide insights into the effectiveness of testing strategies. South America reports the highest average positive rate at 0.2, followed by North America (0.14), Africa (0.09), Europe, and Asia (0.08). These disparities underscore the need for targeted testing and containment measures in high-risk regions.


<br/><br/>

## Summary of Key Figures:
 - Total vaccinations administered: 1.1 billion
 - Total deaths: 3.1 million
 - Total cases: 150 million (as of the data date)


<br/><br/>

# Conclusion

The comprehensive analysis of Covid-19 data presented in this study unveils a multifaceted understanding of the pandemic's impact across continents, highlighting various socio-economic and demographic factors that influenced its trajectory.

Firstly, the distribution of cases and deaths revealed stark regional disparities, with Europe emerging as the most heavily affected continent in terms of both total cases and deaths. Despite boasting better healthcare infrastructure and resources, its aging population played a significant role in amplifying the severity of the outbreak. This underscores the critical influence of demographic factors, particularly age, in shaping the pandemic's toll on different regions.

Furthermore, correlations between key socio-economic indicators such as GDP per capita, hospital bed availability, and population density shed light on the intricate interplay between economic resilience and healthcare capacity in mitigating the spread of the virus. Europe's robust healthcare system, characterized by a higher density of hospital beds per capita, contributed to its ability to manage the pandemic more effectively compared to other regions. Conversely, regions with lower GDP per capita and healthcare resources, such as South America, faced greater challenges in containing the virus and reducing the deaths despite relatively lower population, population density, and having a younger average age.

Moreover, the analysis of vaccination efforts revealed notable discrepancies in distribution and coverage across continents. While North America and Europe demonstrated commendable progress in vaccine rollout, disparities in fully vaccinated populations underscored the need for equitable access to vaccines worldwide. Additionally, the impact of age demographics on vaccination outcomes became evident, with regions like Europe experiencing higher mortality rates due to their larger elderly populations.

In conclusion, this study underscores the importance of considering a comprehensive range of factors, including socio-economic indicators, demographic profiles, and healthcare infrastructure, in understanding the complex dynamics of the Covid-19 pandemic. By elucidating the interplay between these factors, policymakers and healthcare authorities can better tailor interventions and strategies to address the evolving challenges posed by the pandemic and safeguard public health on a global scale.

