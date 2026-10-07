-- Table Keys

ALTER TABLE countries 
MODIFY CountryCode VARCHAR(50) NOT NULL;
ALTER TABLE countries
ADD CONSTRAINT PK_countries PRIMARY KEY (CountryCode);

ALTER TABLE operators
ADD CONSTRAINT PK_operators PRIMARY KEY (OperatorID);
ALTER TABLE operators 
MODIFY HeadquartersCountry VARCHAR(50) NOT NULL;
ALTER TABLE operators
ADD CONSTRAINT FK_operators FOREIGN KEY (HeadquartersCountry) REFERENCES countries(CountryCode);

ALTER TABLE fuel_types
ADD CONSTRAINT PK_fuel PRIMARY KEY (FuelID);

ALTER TABLE power_plants
ADD CONSTRAINT PK_power PRIMARY KEY (PlantID);
ALTER TABLE power_plants 
MODIFY CountryCode VARCHAR(50) NOT NULL;
ALTER TABLE power_plants
ADD CONSTRAINT FK_power1 FOREIGN KEY (CountryCode) REFERENCES countries(CountryCode);
ALTER TABLE power_plants
ADD CONSTRAINT FK_power2 FOREIGN KEY (OperatorID) REFERENCES operators(OperatorID);
ALTER TABLE power_plants
ADD CONSTRAINT FK_power3 FOREIGN KEY (FuelID) REFERENCES fuel_types(FuelID);

ALTER TABLE  generation_records
ADD CONSTRAINT PK_generation PRIMARY KEY (plantid, year);
ALTER TABLE generation_records
ADD CONSTRAINT FK_generation FOREIGN KEY (plantid) REFERENCES power_plants(PlantID);

ALTER TABLE  emission_metrics
ADD CONSTRAINT PK_emission PRIMARY KEY (plantid, year);
ALTER TABLE emission_metrics
ADD CONSTRAINT FK_emission FOREIGN KEY (plantid) REFERENCES power_plants(PlantID);

-- 1.
select power_plants.PlantName, countries.CountryName, operators.OperatorName, fuel_types.FuelCategory, fuel_types.FuelName, power_plants.CapacityMW, power_plants.CommissionYear
from power_plants
join countries on power_plants.CountryCode = countries.CountryCode
join operators on power_plants.OperatorID = operators.OperatorID
join fuel_types on power_plants.FuelID = fuel_types.FuelID
order by power_plants.CapacityMW desc;

-- 2.
select  power_plants.PlantName, power_plants.CountryCode, generation_records.year, generation_records.generationgwh
from power_plants  
join generation_records on power_plants.PlantID = generation_records.plantid
where generation_records.year = 2024
order by generation_records.generationgwh desc;

-- 3.
select power_plants.PlantName, power_plants.CountryCode, generation_records.year, generation_records.generationgwh, emission_metrics.co2emissionstonnes
from power_plants
join generation_records on power_plants.PlantID = generation_records.plantid
join emission_metrics on power_plants.PlantID = emission_metrics.plantid
where generation_records.year = 2024
order by emission_metrics.co2emissionstonnes asc;

-- 4. 
with total_generationgwh as (
select operators.OperatorID as oID, SUM(generation_records.generationgwh) as totalG
from generation_records
right join power_plants on generation_records.plantID = power_plants.PlantID
right join operators on power_plants.OperatorID = operators.OperatorID
where generation_records.generationgwh IS NOT NULL
group by operators.OperatorID
)
select distinct operators.OperatorName, operators.HeadquartersCountry, total_generationgwh.totalG
from total_generationgwh
join operators on total_generationgwh.oID = operators.OperatorID
join power_plants on operators.OperatorID = power_plants.OperatorID
join generation_records on power_plants.PlantID = generation_records.plantid
order by total_generationgwh.totalG desc;

-- 5. 
with total_country_power as (
select countries.CountryCode as country, SUM(generation_records.generationgwh) as country_total
from generation_records
right join power_plants on generation_records.plantID = power_plants.PlantID
right join countries on power_plants.CountryCode = countries.CountryCode
where generation_records.generationgwh IS NOT NULL
group by countries.CountryCode
),
total_country_emissions as (
select countries.CountryCode as country, SUM(emission_metrics.co2emissionstonnes) as country_total
from emission_metrics
right join power_plants on emission_metrics.plantID = power_plants.PlantID
right join countries on power_plants.CountryCode = countries.CountryCode
where emission_metrics.co2emissionstonnes IS NOT NULL
group by countries.CountryCode
)
select countries.CountryName, total_country_power.country_total, total_country_emissions.country_total
from countries
join total_country_power on countries.CountryCode = total_country_power.country
join total_country_emissions on countries.CountryCode = total_country_emissions.country
order by total_country_power.country_total desc;



