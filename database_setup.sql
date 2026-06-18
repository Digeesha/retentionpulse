-- ============================================================================
-- RetentionPulse Database Setup
-- PostgreSQL schema and sample employee data generation
-- ============================================================================

-- Drop existing tables if they exist (development only)
DROP TABLE IF EXISTS employee_engagement CASCADE;
DROP TABLE IF EXISTS employee_performance CASCADE;
DROP TABLE IF EXISTS employee_compensation CASCADE;
DROP TABLE IF EXISTS employees CASCADE;
DROP TABLE IF EXISTS departments CASCADE;

-- ============================================================================
-- SCHEMA DEFINITION
-- ============================================================================

-- Departments lookup table
CREATE TABLE departments (
    department_id SERIAL PRIMARY KEY,
    department_name VARCHAR(100) NOT NULL UNIQUE,
    headcount_budget INTEGER NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Core employee information
CREATE TABLE employees (
    employee_id SERIAL PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    department_id INTEGER NOT NULL REFERENCES departments(department_id),
    job_title VARCHAR(100) NOT NULL,
    hire_date DATE NOT NULL,
    employment_status VARCHAR(20) NOT NULL CHECK (employment_status IN ('Active', 'Terminated', 'On Leave')),
    termination_date DATE,
    age INTEGER NOT NULL CHECK (age >= 18 AND age <= 70),
    gender VARCHAR(20),
    education_level VARCHAR(50) NOT NULL,
    distance_from_home_km NUMERIC(5,2) NOT NULL,
    years_at_company NUMERIC(4,2) NOT NULL,
    years_in_current_role NUMERIC(4,2) NOT NULL,
    years_since_last_promotion NUMERIC(4,2) NOT NULL,
    years_with_current_manager NUMERIC(4,2) NOT NULL,
    attrition BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Employee compensation data
CREATE TABLE employee_compensation (
    compensation_id SERIAL PRIMARY KEY,
    employee_id INTEGER NOT NULL REFERENCES employees(employee_id) ON DELETE CASCADE,
    base_salary NUMERIC(10,2) NOT NULL,
    bonus_percentage NUMERIC(5,2) DEFAULT 0,
    stock_options INTEGER DEFAULT 0,
    salary_increase_percentage NUMERIC(5,2) DEFAULT 0,
    last_salary_review_date DATE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(employee_id)
);

-- Employee performance metrics
CREATE TABLE employee_performance (
    performance_id SERIAL PRIMARY KEY,
    employee_id INTEGER NOT NULL REFERENCES employees(employee_id) ON DELETE CASCADE,
    review_period VARCHAR(20) NOT NULL,
    performance_rating INTEGER NOT NULL CHECK (performance_rating >= 1 AND performance_rating <= 5),
    projects_completed INTEGER DEFAULT 0,
    training_hours INTEGER DEFAULT 0,
    certifications_earned INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(employee_id, review_period)
);

-- Employee engagement data
CREATE TABLE employee_engagement (
    engagement_id SERIAL PRIMARY KEY,
    employee_id INTEGER NOT NULL REFERENCES employees(employee_id) ON DELETE CASCADE,
    survey_date DATE NOT NULL,
    job_satisfaction INTEGER NOT NULL CHECK (job_satisfaction >= 1 AND job_satisfaction <= 5),
    work_life_balance INTEGER NOT NULL CHECK (work_life_balance >= 1 AND work_life_balance <= 5),
    environment_satisfaction INTEGER NOT NULL CHECK (environment_satisfaction >= 1 AND environment_satisfaction <= 5),
    relationship_satisfaction INTEGER NOT NULL CHECK (relationship_satisfaction >= 1 AND relationship_satisfaction <= 5),
    overtime_hours_monthly INTEGER DEFAULT 0,
    business_travel_frequency VARCHAR(20) NOT NULL CHECK (business_travel_frequency IN ('None', 'Rarely', 'Frequently')),
    remote_work_days_per_week INTEGER DEFAULT 0 CHECK (remote_work_days_per_week >= 0 AND remote_work_days_per_week <= 5),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(employee_id, survey_date)
);

-- Create indexes for performance optimization
CREATE INDEX idx_employees_department ON employees(department_id);
CREATE INDEX idx_employees_status ON employees(employment_status);
CREATE INDEX idx_employees_attrition ON employees(attrition);
CREATE INDEX idx_employees_hire_date ON employees(hire_date);
CREATE INDEX idx_compensation_employee ON employee_compensation(employee_id);
CREATE INDEX idx_performance_employee ON employee_performance(employee_id);
CREATE INDEX idx_engagement_employee ON employee_engagement(employee_id);
CREATE INDEX idx_engagement_survey_date ON employee_engagement(survey_date);

-- ============================================================================
-- SEED DATA GENERATION
-- ============================================================================

-- Insert departments
INSERT INTO departments (department_name, headcount_budget) VALUES
    ('Engineering', 120),
    ('Sales', 80),
    ('Marketing', 50),
    ('Human Resources', 25),
    ('Finance', 30),
    ('Operations', 60),
    ('Customer Success', 45),
    ('Product Management', 35),
    ('Data & Analytics', 40),
    ('Legal', 15);

-- Generate sample employee data using PostgreSQL random functions
-- This creates a realistic distribution of employees with varying characteristics

INSERT INTO employees (
    first_name, last_name, email, department_id, job_title, hire_date,
    employment_status, termination_date, age, gender, education_level,
    distance_from_home_km, years_at_company, years_in_current_role,
    years_since_last_promotion, years_with_current_manager, attrition
)
SELECT
    'Employee' || gs AS first_name,
    'User' || gs AS last_name,
    'employee' || gs || '@retentionpulse.com' AS email,
    (gs % 10) + 1 AS department_id,
    CASE 
        WHEN gs % 15 = 0 THEN 'Senior Manager'
        WHEN gs % 10 = 0 THEN 'Manager'
        WHEN gs % 5 = 0 THEN 'Senior Specialist'
        ELSE 'Specialist'
    END AS job_title,
    CURRENT_DATE - (RANDOM() * 3650)::INTEGER AS hire_date,
    CASE 
        WHEN RANDOM() < 0.15 THEN 'Terminated'
        WHEN RANDOM() < 0.02 THEN 'On Leave'
        ELSE 'Active'
    END AS employment_status,
    CASE 
        WHEN RANDOM() < 0.15 THEN CURRENT_DATE - (RANDOM() * 180)::INTEGER
        ELSE NULL
    END AS termination_date,
    18 + (RANDOM() * 47)::INTEGER AS age,
    CASE 
        WHEN RANDOM() < 0.48 THEN 'Female'
        WHEN RANDOM() < 0.96 THEN 'Male'
        ELSE 'Non-binary'
    END AS gender,
    CASE 
        WHEN RANDOM() < 0.15 THEN 'High School'
        WHEN RANDOM() < 0.45 THEN 'Bachelor''s'
        WHEN RANDOM() < 0.85 THEN 'Master''s'
        ELSE 'Doctorate'
    END AS education_level,
    (RANDOM() * 50)::NUMERIC(5,2) AS distance_from_home_km,
    (RANDOM() * 10)::NUMERIC(4,2) AS years_at_company,
    (RANDOM() * 7)::NUMERIC(4,2) AS years_in_current_role,
    (RANDOM() * 5)::NUMERIC(4,2) AS years_since_last_promotion,
    (RANDOM() * 6)::NUMERIC(4,2) AS years_with_current_manager,
    CASE 
        WHEN RANDOM() < 0.15 THEN TRUE
        ELSE FALSE
    END AS attrition
FROM generate_series(1, 500) gs;

-- Update termination dates to match attrition status
UPDATE employees 
SET termination_date = hire_date + (years_at_company * 365)::INTEGER,
    employment_status = 'Terminated'
WHERE attrition = TRUE;

-- Generate compensation data for all employees
INSERT INTO employee_compensation (
    employee_id, base_salary, bonus_percentage, stock_options,
    salary_increase_percentage, last_salary_review_date
)
SELECT
    employee_id,
    CASE 
        WHEN job_title LIKE '%Senior Manager%' THEN 120000 + (RANDOM() * 80000)::NUMERIC(10,2)
        WHEN job_title LIKE '%Manager%' THEN 90000 + (RANDOM() * 50000)::NUMERIC(10,2)
        WHEN job_title LIKE '%Senior%' THEN 75000 + (RANDOM() * 35000)::NUMERIC(10,2)
        ELSE 50000 + (RANDOM() * 40000)::NUMERIC(10,2)
    END AS base_salary,
    (RANDOM() * 20)::NUMERIC(5,2) AS bonus_percentage,
    CASE 
        WHEN job_title LIKE '%Manager%' THEN (RANDOM() * 5000)::INTEGER
        WHEN job_title LIKE '%Senior%' THEN (RANDOM() * 2000)::INTEGER
        ELSE (RANDOM() * 500)::INTEGER
    END AS stock_options,
    (RANDOM() * 8)::NUMERIC(5,2) AS salary_increase_percentage,
    CURRENT_DATE - (RANDOM() * 365)::INTEGER AS last_salary_review_date
FROM employees;

-- Generate performance data for all active employees
INSERT INTO employee_performance (
    employee_id, review_period, performance_rating,
    projects_completed, training_hours, certifications_earned
)
SELECT
    employee_id,
    '2024-Q1' AS review_period,
    1 + (RANDOM() * 4)::INTEGER AS performance_rating,
    (RANDOM() * 12)::INTEGER AS projects_completed,
    (RANDOM() * 80)::INTEGER AS training_hours,
    CASE 
        WHEN RANDOM() < 0.3 THEN (RANDOM() * 3)::INTEGER
        ELSE 0
    END AS certifications_earned
FROM employees
WHERE employment_status = 'Active';

-- Generate engagement data for all active employees
INSERT INTO employee_engagement (
    employee_id, survey_date, job_satisfaction, work_life_balance,
    environment_satisfaction, relationship_satisfaction,
    overtime_hours_monthly, business_travel_frequency, remote_work_days_per_week
)
SELECT
    employee_id,
    CURRENT_DATE - (RANDOM() * 90)::INTEGER AS survey_date,
    1 + (RANDOM() * 4)::INTEGER AS job_satisfaction,
    1 + (RANDOM() * 4)::INTEGER AS work_life_balance,
    1 + (RANDOM() * 4)::INTEGER AS environment_satisfaction,
    1 + (RANDOM() * 4)::INTEGER AS relationship_satisfaction,
    (RANDOM() * 40)::INTEGER AS overtime_hours_monthly,
    CASE 
        WHEN RANDOM() < 0.5 THEN 'None'
        WHEN RANDOM() < 0.85 THEN 'Rarely'
        ELSE 'Frequently'
    END AS business_travel_frequency,
    (RANDOM() * 5)::INTEGER AS remote_work_days_per_week
FROM employees
WHERE employment_status = 'Active';

-- Add realistic correlations: Lower satisfaction for employees who left
UPDATE employee_engagement e
SET 
    job_satisfaction = GREATEST(1, job_satisfaction - 2),
    work_life_balance = GREATEST(1, work_life_balance - 1),
    overtime_hours_monthly = overtime_hours_monthly