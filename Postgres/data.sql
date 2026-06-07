SELECT 
    -- SUM(REPLACE(salary::TEXT, '0', '')::NUMERIC) OVER() AS zero_salary,
    -- SUM(salary) OVER() AS total_salary,
	SUM(salary) - SUM(REPLACE(salary::TEXT, '0', '')::NUMERIC) AS minus
FROM ad_employee;


--------------------------------------------------
Create a Postgres DB :-

sudo -i -u postgres
createdb --template=template0 -E UNICODE awsmonitor

example - DB_Name = awsmonitor

Increse the stress commands :-

sudo apt update
sudo apt install stress

stress --cpu 8