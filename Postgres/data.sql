SELECT 
    -- SUM(REPLACE(salary::TEXT, '0', '')::NUMERIC) OVER() AS zero_salary,
    -- SUM(salary) OVER() AS total_salary,
	SUM(salary) - SUM(REPLACE(salary::TEXT, '0', '')::NUMERIC) AS minus
FROM ad_employee;