
--inserting .csv dataframes I prepared in R into the table
BULK INSERT RANK_ALL
FROM 'C:\Users\gabri\Desktop\happy index\projekt_happy\RANK_ALL1.csv'
WITH ( FIELDTERMINATOR=',',
		ROWTERMINATOR = '\n'
		)

--checking that all columns have the correct data type 
SELECT *
FROM INFORMATION_SCHEMA.COLUMNS 

--changing data types 
ALTER TABLE RANK_ALL
ALTER COLUMN countryid_ph nvarchar(128)

ALTER TABLE RANK_ALL
ALTER COLUMN regionid_ph nvarchar(128)

ALTER TABLE countries_done
ALTER COLUMN countryid int

ALTER TABLE countries_done
ALTER COLUMN regionid int

UPDATE RANK_ALL
SET year_of_study = REPLACE(CAST(year_of_study AS varchar(max)), '"', '')

UPDATE RANK_ALL
SET countryid_ph = REPLACE(countryid_ph, '"', '')

UPDATE RANK_ALL
SET regionid_ph = REPLACE(regionid_ph, '"', '')

ALTER TABLE RANK_ALL
ADD year2 INT

UPDATE RANK_ALL
SET year2 = TRY_CAST(CAST(year_of_study AS varchar(max)) AS INT)

ALTER TABLE RANK_ALL
DROP COLUMN year_of_study

EXEC sp_rename 'RANK_ALL.year2', 'year_of_study', 'COLUMN'
EXEC sp_rename 'RANK_ALL.countryid_ph', 'countryid', 'COLUMN'

--creating IDs and connecting countries to their region 
SELECT
    RIGHT('0000' + CAST(ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS VARCHAR(10)), 4) AS Country_ID,
	RIGHT('0000' + CAST(ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS VARCHAR(10)), 4) AS Region_ID,
    country_name,
	region_name
INTO Countries
FROM countries_done

CREATE TABLE Countries (
   Country_ID INT PRIMARY KEY,
   country_name VARCHAR(50),
   region_name VARCHAR(50)
);

INSERT INTO Countries (Country_ID, country_name, region_name)
SELECT
    CAST(RIGHT('0000' + CAST(ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS VARCHAR(10)), 4) AS INT) AS Country_ID,
    country_name,
    region_name
FROM countries_done

--linking country and region names to ID 

UPDATE RANK_ALL
SET RANK_ALL.countryid = Countries.Country_ID
FROM RANK_ALL
INNER JOIN Countries
	ON Countries.country_name = RANK_ALL.countryid

ALTER TABLE RANK_ALL
DROP COLUMN regionid_ph

--checking if ID's are connected correctly
SELECT *
FROM RANK_ALL
INNER JOIN Countries
	ON Countries.Country_ID = RANK_ALL.countryid
WHERE country_name =  'Norway'

--changing ID type to int and creating relationship
ALTER TABLE RANK_ALL
ALTER COLUMN countryid int

ALTER TABLE RANK_ALL
ADD CONSTRAINT FK_RANK_ALL_Countries FOREIGN KEY (countryid) REFERENCES Countries (Country_ID)



