CREATE DATABASE hospital;

USE hospital;
CREATE TABLE hospital_patient_records (
    PatientID INT PRIMARY KEY AUTO_INCREMENT,
    Name VARCHAR(100),
    Age TINYINT UNSIGNED,
    Gender VARCHAR(255),
    Diagnosis VARCHAR(255),
    Medication VARCHAR(255),
    AdmissionDate DATE,
    DischargeDate DATE,
    Doctor VARCHAR(100),
    Department VARCHAR(100),
    Status VARCHAR(255)
);

SET SQL_SAFE_UPDATES = 0;
# 1-Remove duplicate records.
WITH CTE AS (
    SELECT 
        *, 
        ROW_NUMBER() OVER (PARTITION BY PatientID ORDER BY AdmissionDate) AS rn
    FROM hospital_patient_records
)
DELETE FROM hospital_patient_records
WHERE PatientID IN (
    SELECT PatientID FROM CTE WHERE rn > 1
);
SET SQL_SAFE_UPDATES = 1;
SELECT * From hospital_patient_records;

# 2-Standardize the AdmissionDate column to a consistent format (e.g., YYYY-MM-DD). 

SET SQL_SAFE_UPDATES = 0;
UPDATE hospital_patient_records 
SET 
    AdmissionDate = CASE
        WHEN AdmissionDate LIKE '%/%' THEN STR_TO_DATE(AdmissionDate, '%d/%m/%Y')
        WHEN AdmissionDate LIKE '%,%' THEN STR_TO_DATE(AdmissionDate, '%M %d, %Y')
        ELSE AdmissionDate
    END;
SELECT * From hospital_patient_records;
SET SQL_SAFE_UPDATES = 1;

# 3-Convert the Age column to a numeric type. 

SET SQL_SAFE_UPDATES = 0;
UPDATE hospital_patient_records
SET Age = CASE 
  WHEN Age = 'forty-five' THEN 45 
  ELSE CAST(Age AS UNSIGNED) 
END;
SET SQL_SAFE_UPDATES = 1;

# 4-Normalize the Status column to lowercase. 
SET SQL_SAFE_UPDATES = 0;
UPDATE hospital_patient_records
SET Status = LOWER(Status);
SET SQL_SAFE_UPDATES = 1;

# 5-Replace missing values in the Age and Diagnosis columns with default values (e.g., Unknown). 

SET SQL_SAFE_UPDATES = 0;
UPDATE hospital_patient_records
SET 
  Diagnosis = COALESCE(NULLIF(Diagnosis, ''), 'Unknown'),
  Age = COALESCE(NULLIF(Age, ''), 'Unknown'),
  Doctor = COALESCE(NULLIF(Doctor, ''), 'Unassigned'),
  Name = COALESCE(NULLIF(Name, ''), 'Unassigned');
SET SQL_SAFE_UPDATES = 1;

############ Part 2: Data Exploration and Analysis (SQL and Python)  ############
# 1-What is the average age of patients for each diagnosis? 
SELECT Diagnosis, AVG(Age) AS Average_Age
FROM cleaned_data_py
GROUP BY Diagnosis;

# 2-Which department has the highest number of admitted patients?
SELECT 
    Department, COUNT(*) AS Total_Admissions
FROM
    cleaned_data_py
WHERE
    Status = 'admitted'
GROUP BY Department
ORDER BY Total_Admissions DESC
LIMIT 1;

# 3-How many patients have been discharged per month? 
SELECT 
    MONTH(DischargeDate) AS Month, COUNT(*) AS Total_Discharged
FROM
    cleaned_data_py
WHERE
    Status = 'discharged'
GROUP BY MONTH(DischargeDate)
ORDER BY Month;

# 4-What is the most common diagnosis among patients?
SELECT 
    Diagnosis, COUNT(*) AS Count
FROM
    cleaned_data_py
GROUP BY Diagnosis
ORDER BY Count DESC
LIMIT 1;

# 5-Which doctor has treated the most patients? 
SELECT 
    Doctor, COUNT(*) AS Total_Patients_Treated
FROM
    cleaned_data_py
GROUP BY Doctor
ORDER BY Total_Patients_Treated DESC
LIMIT 1;