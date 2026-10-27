-- Table Keys

ALTER TABLE countries 
MODIFY CountryCode VARCHAR(50) NOT NULL;
ALTER TABLE countries
ADD CONSTRAINT PK_countries PRIMARY KEY (CountryCode);

ALTER TABLE organizations
ADD CONSTRAINT PK_organizations PRIMARY KEY (OrgID);

ALTER TABLE launch_sites
ADD CONSTRAINT PK_launch_sites PRIMARY KEY (SiteID);
ALTER TABLE launch_sites
MODIFY CountryCode VARCHAR(50) NOT NULL;
ALTER TABLE launch_sites
ADD CONSTRAINT FK_launch_sites FOREIGN KEY (CountryCode) REFERENCES countries(CountryCode);

ALTER TABLE rockets
ADD CONSTRAINT PK_rockets PRIMARY KEY (RocketID);
ALTER TABLE rockets
ADD CONSTRAINT FK_rockets FOREIGN KEY (OrgID) REFERENCES organizations(OrgID);

ALTER TABLE missions
ADD CONSTRAINT PK_missions PRIMARY KEY (MissionID);
ALTER TABLE missions
ADD CONSTRAINT FK_missions1 FOREIGN KEY (RocketID) REFERENCES rockets(RocketID);
ALTER TABLE missions
ADD CONSTRAINT FK_missions2 FOREIGN KEY (SiteID) REFERENCES launch_sites(SiteID);

ALTER TABLE payloads
ADD CONSTRAINT PK_payloads PRIMARY KEY (PayloadID);
ALTER TABLE payloads
ADD CONSTRAINT FK_payloads FOREIGN KEY (MissionID) REFERENCES missions(MissionID);

-- 1.
select missions.MissionName, rockets.RocketName, organizations.OrgName, launch_sites.SiteName, missions.Destination, missions.LaunchYear, missions.Outcome
from missions
join rockets on missions.RocketID = rockets.RocketID
join organizations on rockets.OrgID = organizations.OrgID
join launch_sites on missions.SiteID = launch_sites.SiteID
order by missions.LaunchYear desc, missions.MissionName asc;

-- 2.
select missions.MissionName, rockets.RocketName, payloads.PayloadName, payloads.PayloadType, payloads.MassKg
from payloads
right join missions on payloads.MissionID = missions.MissionID
left join rockets on missions.RocketID = rockets.RocketID
where missions.LaunchYear = 2024
order by payloads.MassKg desc;

-- 3. 
select launch_sites.SiteName, missions.MissionName, rockets.RocketName, missions.LaunchYear
from launch_sites
left join missions on launch_sites.SiteID = missions.SiteID
left join rockets on missions.RocketID = rockets.RocketID
group by launch_sites.SiteName,  missions.MissionName, rockets.RocketName, missions.LaunchYear;

-- 4.
with total_payload_mass as (
select organizations.OrgID as OrgID, sum(payloads.MassKg) as TotalMass
from organizations
join rockets on organizations.OrgID = rockets.OrgID
join missions on rockets.RocketID = missions.RocketID
join payloads on missions.MissionID = payloads.MissionID
group by organizations.OrgID
)
select organizations.OrgName, organizations.HeadquartersCountry, organizations.OrgType, total_payload_mass.TotalMass
from organizations
join total_payload_mass on organizations.OrgID = total_payload_mass.OrgID
order by total_payload_mass.TotalMass desc;

-- 5.
with total_country_missions as (
select countries.CountryCode as CountryCode, count(missions.MissionID) as CountryMissions
from countries
left join launch_sites on countries.CountryCode = launch_sites.CountryCode
left join missions on launch_sites.SiteID = missions.SiteID
group by CountryCode
),
total_country_mass as (
select countries.CountryCode as CountryCode, sum(payloads.MassKg) as TotalMass
from countries
left join launch_sites on countries.CountryCode = launch_sites.CountryCode
left join missions on launch_sites.SiteID = missions.SiteID
left join payloads on missions.MissionID = payloads.MissionID
group by CountryCode
)
select countries.CountryName, total_country_missions.CountryMissions, ifnull(total_country_mass.TotalMass, 0) as TotalMass
from countries
join total_country_missions on countries.CountryCode = total_country_missions.CountryCode
join total_country_mass on countries.CountryCode = total_country_mass.CountryCode
order by total_country_mass.TotalMass desc;
