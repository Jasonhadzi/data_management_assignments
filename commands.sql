CREATE TABLE country (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name VARCHAR,
    code INTEGER
);

INSERT INTO 'country' ('name', 'code') VALUES ('United States of America', 'USA');
INSERT INTO 'country' ('name', 'code') VALUES ('Greece', 'GR');

SELECT * FROM country;

SELECT country.name as 'cname' FROM country;

SELECT * FROM country WHERE id=1;

SELECT name FROM country WHERE code ='USA';

UPDATE country SET name='United States' WHERE id=1;

.tables
-- color    country  pattern  project  raveler  state    yarn   
.schema yarn

SELECT COUNT(*) FROM yarn;
SELECT DISTINCT COUNT(*) FROM yarn;

SELECT weight, avg(price) FROM yarn GROUP BY weight;

SELECT weight, ROUND(avg(price), 2) FROM yarn GROUP BY weight;

SELECT date('now');
SELECT datetime('now');
SELECT datetime('now', 'localtime');

-- Write queries to verify the number of rows in 2 tables.
SELECT COUNT(*) FROM color;
SELECT COUNT(*) FROM country;

-- Write query to find the total yardage per brand.
SELECT brand, sum(yardage) FROM yarn GROUP BY brand ORDER BY 2 DESC;


SELECT state.*, country.name FROM state JOIN country ON state.countryid = country.id;