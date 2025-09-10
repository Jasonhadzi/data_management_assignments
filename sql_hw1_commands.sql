-- EASY
select first_name, last_name, gender from patients where gender="M";
SELECT first_name, last_name from patients where allergies IS NULL;
SELECT first_name from patients where first_name like 'C%';
SELECT first_name, last_name from patients where weight >= 100 and weight <= 120;
UPDATE patients SET allergies='NKA' where allergies is NULL;
select concat(first_name, ' ', last_name) as full_name from patients;
select first_name, last_name, province_name from patients inner JOIN province_names on patients.province_id = province_names.province_id;
select count(*) as total_patients from patients where YEAR(birth_date) = 2010;
select first_name, last_name, height from patients WHERE height=(select MAX(height) from patients);
select * from patients where patient_id in (1,45,534,879,1000);
select count(*) as total_admissions from admissions;
select * from admissions where admission_date = discharge_date;
select patient_id, count(*) as total_admissions from admissions where patient_id=579;
select DISTINCT city as unique_cities from patients where province_id='NS';
SELECT first_name, last_name, birth_date from patients where height > 160 and weight > 70;
select first_name, last_name, allergies from patients where allergies is not NULL and city='Hamilton';
-- MEDIUM
select distinct(YEAR(birth_date)) as birth_year from patients order by birth_year ASC;
SELECT first_name from patients group by first_name having count(*) = 1;
select patient_id, first_name from patients where first_name LIKE 'S%' and first_name like '%s' and length(first_name) >= 6;
select patients.patient_id, first_name, last_name from patients inner join admissions on patients.patient_id = admissions.patient_id where admissions.diagnosis='Dementia';
select first_name from patients order by LENGTH(first_name) ASC, first_name ASC;
select sum(gender='M') as male_count, sum(gender='F') as female_count from patients;
select first_name, last_name, allergies from patients where allergies='Penicillin' or allergies='Morphine' order by allergies asc, first_name ASC, last_name ASC;
select patient_id, diagnosis from admissions group by patient_id, diagnosis having count(diagnosis) > 1;
select city, count(*) as num_patients from patients group by city order by num_patients desc, city asc;
select first_name, last_name, 'Patient' as role from patients union all select first_name, last_name, 'Doctor' as role from doctors;
select allergies, count(*) as total_diagnosis from patients where allergies is not NULL group by allergies order by total_diagnosis DESC;
select first_name, last_name, birth_date from patients where YEAR(birth_date) >=1970 and year(birth_date) < 1980 order by birth_date;
select concat(UPPER(last_name), ',', LOWER(first_name)) as new_name_format from patients order by first_name desc;
SELECT province_id, SUM(height) AS sum_height FROM patients GROUP BY province_id HAVING sum_height >= 7000;
select (MAX(weight) - MIN(weight)) as weight_delta from patients where last_name='Maroni';
select DAY(admission_date) as day_number, count(patient_id) as number_of_admissions from admissions GROUP BY day_number order by number_of_admissions DESC;
select * from admissions where patient_id=542 ORDER BY admission_date DESC LIMIT 1;
select patient_id, attending_doctor_id, diagnosis from admissions where patient_id % 2 = 1 and attending_doctor_id in (1, 5, 19) or (attending_doctor_id like '%2%' and LENGTH(patient_id) = 3);
select first_name, last_name, count(a.attending_doctor_id) as admissions_total from admissions a inner join doctors d on a.attending_doctor_id = d.doctor_id GROUP BY first_name, last_name;
SELECT d.doctor_id, CONCAT(d.first_name, ' ', d.last_name) AS full_name, MIN(a.admission_date) AS first_admission_date, MAX(a.admission_date) AS last_admission_date FROM doctors d JOIN admissions a ON d.doctor_id = a.attending_doctor_id GROUP BY d.doctor_id, full_name;
SELECT pro.province_name, COUNT(p.patient_id) AS patient_count FROM province_names pro JOIN patients p ON pro.province_id = p.province_id GROUP BY pro.province_name ORDER BY patient_count DESC;
SELECT CONCAT(p.first_name, ' ', p.last_name) AS patient_name, a.diagnosis, CONCAT(d.first_name, ' ', d.last_name) AS doctor_name FROM patients p JOIN admissions a ON p.patient_id = a.patient_id JOIN doctors d ON a.attending_doctor_id = d.doctor_id;
SELECT first_name, last_name, COUNT() AS number_of_duplicates FROM patients GROUP BY first_name, last_name HAVING COUNT() > 1;
SELECT 
    CONCAT(first_name, ' ', last_name) AS full_name,
    ROUND(height / 30.48, 1) AS height_in_feet,
    ROUND(weight * 2.205, 0) AS weight_in_pounds,
    birth_date,
    CASE 
        WHEN gender = 'M' THEN 'Male'
        WHEN gender = 'F' THEN 'Female'
        ELSE 'Unknown'
    END AS gender_non_abbreviated
FROM 
    patients;
SELECT
  p.patient_id,
  p.first_name,
  p.last_name
FROM
  patients AS p
WHERE NOT EXISTS (
  SELECT
    1
  FROM
    admissions AS a
  WHERE
    a.patient_id = p.patient_id
);
SELECT
    MAX(daily_admissions.admissions_count) AS max_visits,
    MIN(daily_admissions.admissions_count) AS min_visits,
    ROUND(AVG(daily_admissions.admissions_count), 2) AS average_visits
FROM (
    SELECT
        admission_date,
        COUNT(*) AS admissions_count
    FROM
        admissions
    GROUP BY
        admission_date
) AS daily_admissions;