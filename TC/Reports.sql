Reports:-
FO Visit Count Report:-
-- SELECT TO_CHAR(CURRENT_DATE, 'Day') AS day_name,CURRENT_DATE AS date,COUNT(DISTINCT v.tc_visit_id) AS visit_count
-- FROM adempiere.tc_visit v INNER JOIN adempiere.ad_user u ON u.ad_user_id = v.updatedby
-- INNER JOIN adempiere.tc_status s ON s.tc_status_id = v.tc_status_id AND s.name = 'Completed'
-- INNER JOIN adempiere.tc_visittype vt ON vt.tc_visittype_id = v.tc_visittype_id
-- AND vt.name = 'First Visit'
-- WHERE v.updated::date = CURRENT_DATE
-- AND v.ad_client_id = 1000002 
-- AND u.name = 'tilak1';

-- WITH days AS (SELECT generate_series(0, 6) AS day_of_week),
-- visit_counts AS (SELECT v.updated::date AS visit_day,to_char(v.updated::date, 'FMDay') AS day_name,
-- EXTRACT(dow FROM v.updated::date)::int AS day_of_week,COUNT(DISTINCT v.tc_visit_id) AS visit_count
-- FROM adempiere.tc_visit v JOIN adempiere.ad_user u ON u.ad_user_id = v.updatedby           
-- JOIN adempiere.tc_status s ON s.tc_status_id = v.tc_status_id AND LOWER(TRIM(s.name)) = ?
-- JOIN adempiere.tc_visittype vt ON vt.tc_visittype_id = v.tc_visittype_id
-- AND TRIM(vt.name) = ? WHERE v.ad_client_id = ? AND TRIM(u.name) = 'tilak1'
-- AND v.updated::date BETWEEN (CURRENT_DATE - INTERVAL '6 days')::date AND CURRENT_DATE
-- GROUP BY v.updated::date,to_char(v.updated::date, 'FMDay'),EXTRACT(dow FROM v.updated::date))
-- SELECT (CURRENT_DATE - INTERVAL '6 days' + d.day_of_week * INTERVAL '1 day')::date AS dates,
-- COALESCE(vc.day_name,to_char((CURRENT_DATE - INTERVAL '6 days' + d.day_of_week * INTERVAL '1 day')::date, 'FMDay')) AS day_name,
-- COALESCE(vc.visit_count, 0) AS visit_count FROM days d
-- LEFT JOIN visit_counts vc ON (CURRENT_DATE - INTERVAL '6 days' + d.day_of_week * INTERVAL '1 day')::date = vc.visit_day ORDER BY dates;


-- WITH weeks AS (SELECT generate_series(0, 4) AS week_number),
-- visit_counts AS (SELECT date_trunc('week', v.updated)::date AS week_start,
-- to_char(date_trunc('week', v.updated), 'YYYY-MM-DD') AS week_start_str,COUNT(*) AS visit_count
-- FROM adempiere.tc_visit v JOIN adempiere.ad_user u ON u.ad_user_id = v.updatedby
-- JOIN adempiere.tc_status s ON s.tc_status_id = v.tc_status_id AND s.name = 'Completed'
-- JOIN adempiere.tc_visittype vt ON vt.tc_visittype_id = v.tc_visittype_id AND vt.name = ?
-- WHERE v.ad_client_id = ? AND u.name = ? AND v.updated::date >= (current_date - interval '29 days')::date
-- AND v.updated::date <= current_date GROUP BY date_trunc('week', v.updated)),
-- date_range AS (SELECT (current_date - interval '29 days')::date + generate_series(0, 29) AS day)
-- SELECT to_char(date_trunc('week', day), 'YYYY-MM-DD') AS week_start,COALESCE(vc.visit_count, 0) AS visit_count
-- FROM date_range LEFT JOIN visit_counts vc ON date_trunc('week', day) = vc.week_start
-- GROUP BY date_trunc('week', day),vc.visit_count ORDER BY week_start;

-- WITH months AS (SELECT generate_series(0, 11) AS month),
-- visit_counts AS (SELECT date_trunc('month', v.updated)::date AS month_year,to_char(v.updated, 'FMMonth') AS month_name,COUNT(*) AS visit_count
-- FROM adempiere.tc_visit v JOIN adempiere.ad_user u ON u.ad_user_id = v.updatedby
-- JOIN adempiere.tc_status s ON s.tc_status_id = v.tc_status_id AND s.name = 'Completed'
-- JOIN adempiere.tc_visittype vt ON vt.tc_visittype_id = v.tc_visittype_id AND vt.name = ?
-- WHERE v.ad_client_id = ? AND u.name = ?
-- AND v.updated::date >= (current_date - interval '364 days')::date AND v.updated::date <= current_date
-- GROUP BY date_trunc('month', v.updated),to_char(v.updated, 'FMMonth'))
-- SELECT to_char(date_trunc('month', current_date)  - (m.month || ' months')::interval, 'YYYY-MM-01') AS month_date,
-- COALESCE(vc.visit_count, 0) AS visit_count FROM months m LEFT JOIN visit_counts vc
-- ON date_trunc('month', current_date) - (m.month || ' months')::interval = vc.month_year
-- ORDER BY date_trunc('month', current_date) - (m.month || ' months')::interval;


WITH year_counts AS (SELECT date_trunc('year', v.updated)::date AS year_start,COUNT(*) AS counts
FROM adempiere.tc_visit v JOIN adempiere.ad_user u ON u.ad_user_id = v.updatedby
JOIN adempiere.tc_status s ON s.tc_status_id = v.tc_status_id AND s.name = 'Completed'
JOIN adempiere.tc_visittype vt ON vt.tc_visittype_id = v.tc_visittype_id AND vt.name = ?
WHERE v.ad_client_id = ? AND u.name = ? GROUP BY date_trunc('year', v.updated)),
year_range AS (SELECT date_trunc('year', CURRENT_DATE)::date AS year_start
UNION ALL
SELECT generate_series((SELECT MIN(year_start) FROM year_counts),date_trunc('year', CURRENT_DATE)::date,interval '1 year')::date AS year_start),
all_years AS (SELECT DISTINCT year_start FROM year_range)
SELECT to_char(a.year_start, 'YYYY-01-01') AS year_date,COALESCE(y.counts, 0) AS counts FROM all_years a
LEFT JOIN year_counts y ON a.year_start = y.year_start ORDER BY a.year_start;

====================================================================================================================
Media Report:-
-- SELECT day_info.day_name AS day_name,current_date AS date,COALESCE(COUNT(v.*), 0) AS counts
-- FROM (SELECT to_char(current_date, 'FMDay') AS day_name) AS day_info
-- LEFT JOIN adempiere.tc_medialabelqr v ON v.created::date = current_date
-- AND v.ad_client_id = 1000002 AND v.isdiscarded = 'N'
-- AND v.createdby IN (SELECT ad_user_id FROM adempiere.ad_user WHERE name = 'muthu1' )
-- AND v.tc_mediatype_id IN (Select tc_mediatype_id FROM adempiere.tc_mediatype Where name = 'CR' )
-- GROUP BY day_info.day_name;

-- WITH days AS (SELECT generate_series(0, 6) AS day_of_week),
-- visit_counts AS (SELECT date_trunc('day', v.created) AS visit_day,to_char(v.created, 'FMDay') AS day_name,
-- EXTRACT(dow FROM v.created) AS day_of_week,COUNT(*) AS visit_count FROM adempiere.tc_medialabelqr v
-- JOIN adempiere.ad_user u ON u.ad_user_id = v.createdby
-- JOIN adempiere.tc_mediatype mt ON mt.tc_mediatype_id = v.tc_mediatype_id
-- WHERE v.ad_client_id = ? AND v.isdiscarded = 'N' AND u.name = ? AND mt.name = ?
-- AND v.created::date >= current_date - interval '6 days' AND v.created::date <= current_date
-- GROUP BY date_trunc('day', v.created), to_char(v.created, 'FMDay'),EXTRACT(dow FROM v.created))
-- SELECT (current_date - interval '6 days' + d.day_of_week * interval '1 day')::date AS dates,
-- COALESCE(vc.day_name,to_char(current_date - interval '6 days' + d.day_of_week * interval '1 day', 'FMDay')) AS day_name,
-- COALESCE(vc.visit_count, 0) AS counts FROM days d
-- LEFT JOIN visit_counts vc  ON date_trunc('day', current_date - interval '6 days' + d.day_of_week * interval '1 day') = vc.visit_day
-- ORDER BY dates;

-- WITH weeks AS (SELECT generate_series(0, 4) AS week_number),
-- counts AS (SELECT date_trunc('week', v.created) AS week_start,to_char(date_trunc('week', v.created), 'YYYY-MM-DD') AS week_start_str,
-- COUNT(*) AS counts FROM adempiere.tc_medialabelqr v JOIN adempiere.ad_user u ON u.ad_user_id = v.createdby
-- JOIN adempiere.tc_mediatype mt ON mt.tc_mediatype_id = v.tc_mediatype_id WHERE v.ad_client_id = ?
-- AND v.isdiscarded = 'N' AND u.name = ? AND mt.name = ?
-- AND v.created::date >= current_date - interval '29 days' AND v.created::date <= current_date
-- GROUP BY date_trunc('week', v.created)),
-- date_range AS (SELECT (current_date - interval '29 days')::date + generate_series(0, 29) AS day)
-- SELECT to_char(date_trunc('week', day), 'YYYY-MM-DD') AS week_start,COALESCE(vc.counts, 0) AS counts
-- FROM date_range LEFT JOIN counts vc ON date_trunc('week', day) = vc.week_start
-- GROUP BY date_trunc('week', day), vc.counts ORDER BY week_start;

-- WITH months AS (SELECT generate_series(0, 11) AS month),
-- visit_counts AS (SELECT date_trunc('month', v.created) AS month_year,to_char(v.created, 'FMMonth') AS month_name,
-- COUNT(*) AS visit_count FROM adempiere.tc_medialabelqr v JOIN adempiere.ad_user u ON u.ad_user_id = v.createdby
-- JOIN adempiere.tc_mediatype mt ON mt.tc_mediatype_id = v.tc_mediatype_id WHERE v.ad_client_id = ?
-- AND v.isdiscarded = 'N' AND u.name = ? AND mt.name = ? AND v.created::date >= (current_date - interval '364 days')
-- AND v.created::date <= current_date GROUP BY date_trunc('month', v.created),to_char(v.created, 'FMMonth'))
-- SELECT to_char(date_trunc('month', current_date) - (m.month || ' months')::interval,'YYYY-MM-01') AS month_date,
-- COALESCE(vc.visit_count, 0) AS counts FROM months m
-- LEFT JOIN visit_counts vc ON date_trunc('month', current_date) - (m.month || ' months')::interval = vc.month_year
-- ORDER BY date_trunc('month', current_date) - (m.month || ' months')::interval;

-- WITH year_counts AS (SELECT date_trunc('year', v.created) AS year_start,COUNT(*) AS counts
-- FROM adempiere.tc_medialabelqr v JOIN adempiere.ad_user u ON u.ad_user_id = v.createdby
-- JOIN adempiere.tc_mediatype mt ON mt.tc_mediatype_id = v.tc_mediatype_id		
-- WHERE v.ad_client_id = ? AND v.isdiscarded = 'N' AND u.name = ? AND mt.name = ?
-- GROUP BY date_trunc('year', v.created)),
-- year_range AS (SELECT date_trunc('year', CURRENT_DATE) AS year_start UNION ALL
-- SELECT generate_series((SELECT MIN(year_start) FROM year_counts),date_trunc('year', CURRENT_DATE),interval '1 year') AS year_start),
-- all_years AS (SELECT DISTINCT year_start FROM year_range)
-- SELECT to_char(a.year_start, 'YYYY-01-01') AS year_date,COALESCE(y.counts, 0) AS counts
-- FROM all_years a LEFT JOIN year_counts y ON a.year_start = y.year_start ORDER BY a.year_start;


=================================================================================
SELECT pr.m_product_id,pr.name AS mediacategory,pr.description AS codeifany,
COALESCE(ml.openingstock, 0::numeric) AS openingbalance,COALESCE(ml.stocked, 0::numeric) AS mediastocked,
COALESCE(mol.totalqty, 0::numeric) AS issuetoct,COALESCE(ml.openingstock, 0::numeric) + COALESCE(ml.stocked, 0::numeric)
 - COALESCE(mol.totalqty, 0::numeric) - COALESCE(di.discarded_qty, 0::numeric) AS balance,ml.updated,
COALESCE(di.discarded_qty, 0::numeric) AS discardedquantity FROM adempiere.m_product pr
LEFT JOIN (SELECT  pr_1.m_product_id,MAX(date(ml_1.updated)) AS updated,        
SUM(CASE WHEN date(ml_1.created) < '2025-11-06' THEN ml_1.quantity ELSE 0  END) AS openingstock,        
SUM(CASE  WHEN date(ml_1.created) BETWEEN '2025-11-06' AND '2025-11-13' THEN ml_1.quantity ELSE 0  END) AS stocked
FROM adempiere.tc_medialine ml_1 JOIN adempiere.m_product pr_1 ON pr_1.m_product_id = ml_1.m_product_id
WHERE ml_1.ad_client_id = 1000002  GROUP BY pr_1.m_product_id) ml ON pr.m_product_id = ml.m_product_id
LEFT JOIN (SELECT pro.m_product_id,
SUM(CASE  WHEN date(mol_1.created) BETWEEN '2025-11-06' AND '2025-11-13' THEN mol_1.quantity  ELSE 0  END) AS totalqty
FROM adempiere.tc_mediaoutline mol_1 JOIN adempiere.m_product pro ON pro.m_product_id = mol_1.m_product_id
WHERE mol_1.ad_client_id = 1000002 GROUP BY pro.m_product_id) mol ON pr.m_product_id = mol.m_product_id
LEFT JOIN (SELECT ml_1.m_product_id,
SUM(CASE  WHEN mlq.isdiscarded = 'Y' AND date(ml_1.created) BETWEEN '2025-11-06' AND '2025-11-13' THEN ml_1.quantity ELSE 0  END) AS discarded_qty
FROM adempiere.tc_medialine ml_1 JOIN adempiere.tc_medialabelqr mlq ON ml_1.tc_medialine_id = mlq.tc_medialine_id
WHERE ml_1.ad_client_id = 1000002 GROUP BY ml_1.m_product_id) di ON pr.m_product_id = di.m_product_id
JOIN adempiere.m_product_category pc ON pr.m_product_category_id = pc.m_product_category_id
WHERE pc.name = 'BMedia' AND pr.ad_client_id = 1000002;
=======================================================================================================
Media Production (Old Jasper):
SELECT pr.m_product_id,pr.name AS mediacategory,pr.description AS codeifany,
COALESCE(ml.openingstock, 0::numeric) AS openingbalance,COALESCE(ml.stocked, 0::numeric) AS mediastocked,
COALESCE(mol.totalqty, 0::numeric) AS issuetoct,COALESCE(ml.openingstock, 0::numeric) + COALESCE(ml.stocked, 0::numeric)
 - COALESCE(mol.totalqty, 0::numeric) - COALESCE(di.discarded_qty, 0::numeric) AS balance,ml.updated,
COALESCE(di.discarded_qty, 0::numeric) AS discardedquantity FROM adempiere.m_product pr
LEFT JOIN (SELECT  pr_1.m_product_id,MAX(date(ml_1.updated)) AS updated,        
SUM(CASE WHEN date(ml_1.created) < $P{Date} THEN ml_1.quantity ELSE 0  END) AS openingstock,        
SUM(CASE  WHEN date(ml_1.created) BETWEEN  $P{Date} AND $P{DateTo} THEN ml_1.quantity ELSE 0  END) AS stocked
FROM adempiere.tc_medialine ml_1 JOIN adempiere.m_product pr_1 ON pr_1.m_product_id = ml_1.m_product_id
WHERE ml_1.ad_client_id = $P{AD_CLIENT_ID}  GROUP BY pr_1.m_product_id) ml ON pr.m_product_id = ml.m_product_id
LEFT JOIN (SELECT pro.m_product_id,
SUM(CASE  WHEN date(mol_1.created) BETWEEN  $P{Date} AND $P{DateTo} THEN mol_1.quantity  ELSE 0  END) AS totalqty
FROM adempiere.tc_mediaoutline mol_1 JOIN adempiere.m_product pro ON pro.m_product_id = mol_1.m_product_id
WHERE mol_1.ad_client_id = $P{AD_CLIENT_ID} GROUP BY pro.m_product_id) mol ON pr.m_product_id = mol.m_product_id
LEFT JOIN (SELECT ml_1.m_product_id,
SUM(CASE  WHEN mlq.isdiscarded = 'Y' AND date(ml_1.created) BETWEEN  $P{Date}  AND $P{DateTo} THEN ml_1.quantity ELSE 0  END) AS discarded_qty
FROM adempiere.tc_medialine ml_1 JOIN adempiere.tc_medialabelqr mlq ON ml_1.tc_medialine_id = mlq.tc_medialine_id
WHERE ml_1.ad_client_id = $P{AD_CLIENT_ID} GROUP BY ml_1.m_product_id) di ON pr.m_product_id = di.m_product_id
JOIN adempiere.m_product_category pc ON pr.m_product_category_id = pc.m_product_category_id
WHERE pc.name = 'BMedia' AND pr.ad_client_id = $P{AD_CLIENT_ID} ;


-------------------------------------------------------------------------
Media Production Report with Date:-
WITH params AS (SELECT DATE '2025-11-01' AS fromDate,DATE '2025-11-21' AS toDate),
opening AS (
SELECT  ml.m_product_id,SUM(CASE WHEN ml.created::date < (SELECT fromDate FROM params) THEN ml.quantity ELSE 0 END) AS openingstock
FROM adempiere.tc_medialine ml WHERE ml.ad_client_id = 1000002 GROUP BY ml.m_product_id),
stocked AS (
SELECT ml.m_product_id,ml.updated::date AS tx_date,SUM(CASE WHEN ml.updated::date BETWEEN 
(SELECT fromDate FROM params) AND (SELECT toDate FROM params) THEN ml.quantity ELSE 0 END) AS stocked_qty
FROM adempiere.tc_medialine ml WHERE ml.ad_client_id = 1000002 GROUP BY ml.m_product_id, ml.updated::date),
issued AS (
SELECT mol.m_product_id,mol.updated::date AS tx_date,SUM(CASE WHEN mol.updated::date BETWEEN 
(SELECT fromDate FROM params) AND (SELECT toDate FROM params) THEN mol.quantity ELSE 0 END) AS issued_qty
FROM adempiere.tc_mediaoutline mol WHERE mol.ad_client_id = 1000002 GROUP BY mol.m_product_id, mol.updated::date),
discarded AS (
SELECT ml.m_product_id,ml.updated::date AS tx_date,SUM(CASE WHEN mlq.isdiscarded = 'Y' AND ml.updated::date BETWEEN 
(SELECT fromDate FROM params) AND (SELECT toDate FROM params) THEN ml.quantity ELSE 0 END) AS discarded_qty
FROM adempiere.tc_medialine ml JOIN adempiere.tc_medialabelqr mlq ON ml.tc_medialine_id = mlq.tc_medialine_id
WHERE ml.ad_client_id = 1000002 GROUP BY ml.m_product_id, ml.updated::date),
all_dates AS (
SELECT generate_series((SELECT fromDate FROM params),(SELECT toDate FROM params),interval '1 day')::date AS tx_date)
SELECT pr.m_product_id,pr.name AS mediacategory,pr.description AS codeifany,op.openingstock AS openingbalance,
COALESCE(st.stocked_qty, 0) AS stocked,COALESCE(isu.issued_qty, 0) AS issuetoct,COALESCE(di.discarded_qty, 0) AS discardedquantity,
(op.openingstock  + COALESCE(st.stocked_qty, 0) - COALESCE(isu.issued_qty, 0) - COALESCE(di.discarded_qty, 0)) AS balance,
TO_CHAR(d.tx_date, 'DD/MM/YY') AS updated,
(SELECT COALESCE(SUM(st2.stocked_qty),0) FROM stocked st2 WHERE st2.m_product_id = pr.m_product_id) AS total_stocked,
(SELECT COALESCE(SUM(isu2.issued_qty),0) FROM issued isu2 WHERE isu2.m_product_id = pr.m_product_id) AS total_issued,
(SELECT COALESCE(SUM(di2.discarded_qty),0) FROM discarded di2 WHERE di2.m_product_id = pr.m_product_id) AS total_discarded
FROM adempiere.m_product pr JOIN adempiere.m_product_category pc ON pr.m_product_category_id = pc.m_product_category_id
LEFT JOIN opening op ON pr.m_product_id = op.m_product_id LEFT JOIN all_dates d ON TRUE
LEFT JOIN stocked st ON st.m_product_id = pr.m_product_id AND st.tx_date = d.tx_date
LEFT JOIN issued isu ON isu.m_product_id = pr.m_product_id AND isu.tx_date = d.tx_date
LEFT JOIN discarded di ON di.m_product_id = pr.m_product_id AND di.tx_date = d.tx_date
WHERE pc.name = 'BMedia' AND pr.ad_client_id = 1000002
AND (COALESCE(st.stocked_qty, 0) <> 0 OR COALESCE(isu.issued_qty, 0) <> 0 OR COALESCE(di.discarded_qty, 0) <> 0)
ORDER BY pr.m_product_id, d.tx_date;

--------------------------
Working jasper code
WITH params AS (
SELECT CAST($P{Date} AS DATE) AS fromDate,
        CAST($P{DateTo} AS DATE) AS toDate
),
opening AS (
SELECT  ml.m_product_id,SUM(CASE WHEN ml.created::date < (SELECT fromDate FROM params) THEN ml.quantity ELSE 0 END) AS openingstock
FROM adempiere.tc_medialine ml WHERE ml.ad_client_id = $P{AD_CLIENT_ID} GROUP BY ml.m_product_id),
stocked AS (
SELECT ml.m_product_id,ml.updated::date AS tx_date,SUM(CASE WHEN ml.updated::date BETWEEN 
(SELECT fromDate FROM params) AND (SELECT toDate FROM params) THEN ml.quantity ELSE 0 END) AS stocked_qty
FROM adempiere.tc_medialine ml WHERE ml.ad_client_id = $P{AD_CLIENT_ID} GROUP BY ml.m_product_id, ml.updated::date),
issued AS (
SELECT mol.m_product_id,mol.updated::date AS tx_date,SUM(CASE WHEN mol.updated::date BETWEEN 
(SELECT fromDate FROM params) AND (SELECT toDate FROM params) THEN mol.quantity ELSE 0 END) AS issued_qty
FROM adempiere.tc_mediaoutline mol WHERE mol.ad_client_id = $P{AD_CLIENT_ID} GROUP BY mol.m_product_id, mol.updated::date),
discarded AS (
SELECT ml.m_product_id,ml.updated::date AS tx_date,SUM(CASE WHEN mlq.isdiscarded = 'Y' AND ml.updated::date BETWEEN 
(SELECT fromDate FROM params) AND (SELECT toDate FROM params) THEN ml.quantity ELSE 0 END) AS discarded_qty
FROM adempiere.tc_medialine ml JOIN adempiere.tc_medialabelqr mlq ON ml.tc_medialine_id = mlq.tc_medialine_id
WHERE ml.ad_client_id = $P{AD_CLIENT_ID} GROUP BY ml.m_product_id, ml.updated::date),
all_dates AS (
SELECT generate_series((SELECT fromDate FROM params),(SELECT toDate FROM params),interval '1 day')::date AS tx_date)
SELECT pr.m_product_id,pr.name AS mediacategory,pr.description AS codeifany,op.openingstock AS openingbalance,
COALESCE(st.stocked_qty, 0) AS stocked,COALESCE(isu.issued_qty, 0) AS issuetoct,
COALESCE(di.discarded_qty, 0) AS discardedquantity,
(op.openingstock  + (SELECT COALESCE(SUM(st2.stocked_qty),0) FROM stocked st2 WHERE st2.m_product_id = pr.m_product_id)
- (SELECT COALESCE(SUM(isu2.issued_qty),0) FROM issued isu2 WHERE isu2.m_product_id = pr.m_product_id)
- (SELECT COALESCE(SUM(di2.discarded_qty),0) FROM discarded di2 WHERE di2.m_product_id = pr.m_product_id)) AS balance,
TO_CHAR(d.tx_date, 'DD/MM/YY') AS updated,
(SELECT COALESCE(SUM(st2.stocked_qty),0) FROM stocked st2 WHERE st2.m_product_id = pr.m_product_id) AS total_stocked,
(SELECT COALESCE(SUM(isu2.issued_qty),0) FROM issued isu2 WHERE isu2.m_product_id = pr.m_product_id) AS total_issued,
(SELECT COALESCE(SUM(di2.discarded_qty),0) FROM discarded di2 WHERE di2.m_product_id = pr.m_product_id) AS total_discarded
FROM adempiere.m_product pr JOIN adempiere.m_product_category pc ON pr.m_product_category_id = pc.m_product_category_id
LEFT JOIN opening op ON pr.m_product_id = op.m_product_id LEFT JOIN all_dates d ON TRUE
LEFT JOIN stocked st ON st.m_product_id = pr.m_product_id AND st.tx_date = d.tx_date
LEFT JOIN issued isu ON isu.m_product_id = pr.m_product_id AND isu.tx_date = d.tx_date
LEFT JOIN discarded di ON di.m_product_id = pr.m_product_id AND di.tx_date = d.tx_date
WHERE pc.name = 'BMedia' AND pr.ad_client_id = $P{AD_CLIENT_ID}
AND (COALESCE(st.stocked_qty, 0) <> 0 OR COALESCE(isu.issued_qty, 0) <> 0 OR COALESCE(di.discarded_qty, 0) <> 0)
ORDER BY pr.m_product_id, d.tx_date;


=======================================================
Working Pgadmin running query (Day,month,year):-

WITH params AS (SELECT 
DATE '2025-09-01' AS fromDate,
DATE '2025-11-24' AS toDate,
'MONTH'::text AS reportType,
1000002::int AS target_client_id),
day_series AS (SELECT generate_series((SELECT fromDate FROM params),(SELECT toDate FROM params),interval '1 day')::date AS period_start),
month_series AS (SELECT date_trunc('month', gs)::date AS period_start FROM generate_series(date_trunc('month', (SELECT fromDate FROM params)),
date_trunc('month', (SELECT toDate FROM params)), interval '1 month') AS gs),
year_series AS (SELECT date_trunc('year', gs)::date AS period_start FROM generate_series(date_trunc('year', (SELECT fromDate FROM params)),
date_trunc('year', (SELECT toDate FROM params)),interval '1 year') AS gs),
periods AS (SELECT period_start FROM day_series  WHERE (SELECT reportType FROM params) = 'DAY'
UNION ALL
SELECT period_start FROM month_series WHERE (SELECT reportType FROM params) = 'MONTH'
UNION ALL
SELECT period_start FROM year_series WHERE (SELECT reportType FROM params) = 'YEAR'),
opening AS (SELECT ml.m_product_id,SUM(CASE WHEN ml.created::date < (SELECT fromDate FROM params) THEN ml.quantity ELSE 0 END) AS openingstock
FROM adempiere.tc_medialine ml WHERE ml.ad_client_id = (SELECT target_client_id FROM params)GROUP BY ml.m_product_id),
stocked AS (SELECT ml.m_product_id,
CASE  
WHEN (SELECT reportType FROM params) = 'DAY'   THEN ml.updated::date
WHEN (SELECT reportType FROM params) = 'MONTH' THEN date_trunc('month', ml.updated)::date
ELSE date_trunc('year', ml.updated)::date END AS period_start,
SUM(CASE WHEN ml.updated::date BETWEEN (SELECT fromDate FROM params) AND (SELECT toDate FROM params) THEN ml.quantity ELSE 0 END) AS stocked_qty
FROM adempiere.tc_medialine ml WHERE ml.ad_client_id = (SELECT target_client_id FROM params) GROUP BY ml.m_product_id,
CASE 
WHEN (SELECT reportType FROM params) = 'DAY'   THEN ml.updated::date
WHEN (SELECT reportType FROM params) = 'MONTH' THEN date_trunc('month', ml.updated)::date
ELSE date_trunc('year', ml.updated)::date END),
issued AS (SELECT mol.m_product_id,
CASE 
WHEN (SELECT reportType FROM params) = 'DAY'   THEN mol.updated::date
WHEN (SELECT reportType FROM params) = 'MONTH' THEN date_trunc('month', mol.updated)::date
ELSE date_trunc('year', mol.updated)::date END AS period_start,
SUM(CASE WHEN mol.updated::date BETWEEN (SELECT fromDate FROM params) AND (SELECT toDate FROM params)
THEN mol.quantity ELSE 0 END) AS issued_qty
FROM adempiere.tc_mediaoutline mol WHERE mol.ad_client_id = (SELECT target_client_id FROM params)GROUP BY mol.m_product_id,
CASE 
WHEN (SELECT reportType FROM params) = 'DAY'   THEN mol.updated::date
WHEN (SELECT reportType FROM params) = 'MONTH' THEN date_trunc('month', mol.updated)::date
ELSE date_trunc('year', mol.updated)::date END),
discarded AS (SELECT ml.m_product_id,
CASE 
WHEN (SELECT reportType FROM params) = 'DAY'   THEN ml.updated::date
WHEN (SELECT reportType FROM params) = 'MONTH' THEN date_trunc('month', ml.updated)::date
ELSE date_trunc('year', ml.updated)::date END AS period_start,
SUM(
CASE WHEN mlq.isdiscarded = 'Y' AND ml.updated::date BETWEEN (SELECT fromDate FROM params) AND (SELECT toDate FROM params)
THEN ml.quantity ELSE 0 END) AS discarded_qty FROM adempiere.tc_medialine ml 
JOIN adempiere.tc_medialabelqr mlq ON ml.tc_medialine_id = mlq.tc_medialine_id
WHERE ml.ad_client_id = (SELECT target_client_id FROM params) GROUP BY ml.m_product_id,
CASE 
WHEN (SELECT reportType FROM params) = 'DAY'   THEN ml.updated::date
WHEN (SELECT reportType FROM params) = 'MONTH' THEN date_trunc('month', ml.updated)::date
ELSE date_trunc('year', ml.updated)::date END)
SELECT pr.m_product_id,pr.name AS mediacategory,pr.description AS codeifany,COALESCE(op.openingstock, 0) AS openingbalance,
CASE 
WHEN (SELECT reportType FROM params) = 'DAY'   THEN to_char(p.period_start, 'DD/MM/YY')
WHEN (SELECT reportType FROM params) = 'MONTH' THEN to_char(p.period_start, 'Mon YYYY')
ELSE to_char(p.period_start, 'YYYY') END AS period_label,
COALESCE(st.stocked_qty, 0)   AS stocked,COALESCE(isu.issued_qty, 0)   AS issued,COALESCE(di.discarded_qty, 0) AS discarded,
(COALESCE(op.openingstock, 0) + COALESCE((SELECT SUM(s2.stocked_qty) FROM stocked s2 WHERE s2.m_product_id = pr.m_product_id), 0)
 - COALESCE((SELECT SUM(i2.issued_qty) FROM issued i2 WHERE i2.m_product_id = pr.m_product_id), 0) 
 - COALESCE((SELECT SUM(d2.discarded_qty) FROM discarded d2 WHERE d2.m_product_id = pr.m_product_id), 0)) AS balance,
COALESCE((SELECT SUM(s2.stocked_qty) FROM stocked s2 WHERE s2.m_product_id = pr.m_product_id), 0)    AS total_stocked,
COALESCE((SELECT SUM(i2.issued_qty) FROM issued i2 WHERE i2.m_product_id = pr.m_product_id), 0)      AS total_issued,
COALESCE((SELECT SUM(d2.discarded_qty) FROM discarded d2 WHERE d2.m_product_id = pr.m_product_id), 0)  AS total_discarded
FROM adempiere.m_product pr JOIN adempiere.m_product_category pc ON pr.m_product_category_id = pc.m_product_category_id
LEFT JOIN opening op ON op.m_product_id = pr.m_product_id CROSS JOIN periods p
LEFT JOIN stocked st ON st.m_product_id = pr.m_product_id AND st.period_start = p.period_start
LEFT JOIN issued isu  ON isu.m_product_id  = pr.m_product_id AND isu.period_start  = p.period_start
LEFT JOIN discarded di ON di.m_product_id = pr.m_product_id AND di.period_start = p.period_start
WHERE pc.name = 'BMedia'
AND pr.ad_client_id = (SELECT target_client_id FROM params) AND (COALESCE(st.stocked_qty, 0) <> 0 
OR COALESCE(isu.issued_qty, 0) <> 0 OR COALESCE(di.discarded_qty, 0) <> 0)
ORDER BY pr.m_product_id, p.period_start;
======================================================================================================================
Working Jasper Report running query (Day,month,year):-

WITH params AS (SELECT 
CAST($P{Date} AS DATE) AS fromDate,
CAST($P{DateTo} AS DATE) AS toDate,
$P{Type}::text AS reportType,  
$P{AD_CLIENT_ID}::int AS target_client_id),
day_series AS (SELECT generate_series((SELECT fromDate FROM params),(SELECT toDate FROM params),interval '1 day')::date AS period_start),
month_series AS (SELECT date_trunc('month', gs)::date AS period_start FROM generate_series(date_trunc('month', (SELECT fromDate FROM params)),
date_trunc('month', (SELECT toDate FROM params)), interval '1 month') AS gs),
year_series AS (SELECT date_trunc('year', gs)::date AS period_start FROM generate_series(date_trunc('year', (SELECT fromDate FROM params)),
date_trunc('year', (SELECT toDate FROM params)),interval '1 year') AS gs),
periods AS (SELECT period_start FROM day_series  WHERE (SELECT reportType FROM params) = 'DAY'
UNION ALL
SELECT period_start FROM month_series WHERE (SELECT reportType FROM params) = 'MONTH'
UNION ALL
SELECT period_start FROM year_series WHERE (SELECT reportType FROM params) = 'YEAR'),
opening AS (SELECT ml.m_product_id,SUM(CASE WHEN ml.created::date < (SELECT fromDate FROM params) THEN ml.quantity ELSE 0 END) AS openingstock
FROM adempiere.tc_medialine ml WHERE ml.ad_client_id = (SELECT target_client_id FROM params)GROUP BY ml.m_product_id),
stocked AS (SELECT ml.m_product_id,
CASE  
WHEN (SELECT reportType FROM params) = 'DAY'   THEN ml.updated::date
WHEN (SELECT reportType FROM params) = 'MONTH' THEN date_trunc('month', ml.updated)::date
ELSE date_trunc('year', ml.updated)::date END AS period_start,
SUM(CASE WHEN ml.updated::date BETWEEN (SELECT fromDate FROM params) AND (SELECT toDate FROM params) THEN ml.quantity ELSE 0 END) AS stocked_qty
FROM adempiere.tc_medialine ml WHERE ml.ad_client_id = (SELECT target_client_id FROM params) GROUP BY ml.m_product_id,
CASE 
WHEN (SELECT reportType FROM params) = 'DAY'   THEN ml.updated::date
WHEN (SELECT reportType FROM params) = 'MONTH' THEN date_trunc('month', ml.updated)::date
ELSE date_trunc('year', ml.updated)::date END),
issued AS (SELECT mol.m_product_id,
CASE 
WHEN (SELECT reportType FROM params) = 'DAY'   THEN mol.updated::date
WHEN (SELECT reportType FROM params) = 'MONTH' THEN date_trunc('month', mol.updated)::date
ELSE date_trunc('year', mol.updated)::date END AS period_start,
SUM(CASE WHEN mol.updated::date BETWEEN (SELECT fromDate FROM params) AND (SELECT toDate FROM params)
THEN mol.quantity ELSE 0 END) AS issued_qty
FROM adempiere.tc_mediaoutline mol WHERE mol.ad_client_id = (SELECT target_client_id FROM params)GROUP BY mol.m_product_id,
CASE 
WHEN (SELECT reportType FROM params) = 'DAY'   THEN mol.updated::date
WHEN (SELECT reportType FROM params) = 'MONTH' THEN date_trunc('month', mol.updated)::date
ELSE date_trunc('year', mol.updated)::date END),
discarded AS (SELECT ml.m_product_id,
CASE 
WHEN (SELECT reportType FROM params) = 'DAY'   THEN ml.updated::date
WHEN (SELECT reportType FROM params) = 'MONTH' THEN date_trunc('month', ml.updated)::date
ELSE date_trunc('year', ml.updated)::date END AS period_start,
SUM(
CASE WHEN mlq.isdiscarded = 'Y' AND ml.updated::date BETWEEN (SELECT fromDate FROM params) AND (SELECT toDate FROM params)
THEN ml.quantity ELSE 0 END) AS discarded_qty FROM adempiere.tc_medialine ml 
JOIN adempiere.tc_medialabelqr mlq ON ml.tc_medialine_id = mlq.tc_medialine_id
WHERE ml.ad_client_id = (SELECT target_client_id FROM params) GROUP BY ml.m_product_id,
CASE 
WHEN (SELECT reportType FROM params) = 'DAY'   THEN ml.updated::date
WHEN (SELECT reportType FROM params) = 'MONTH' THEN date_trunc('month', ml.updated)::date
ELSE date_trunc('year', ml.updated)::date END)
SELECT pr.m_product_id,pr.name AS mediacategory,pr.description AS codeifany,COALESCE(op.openingstock, 0) AS openingbalance,
CASE 
WHEN (SELECT reportType FROM params) = 'DAY'   THEN to_char(p.period_start, 'DD/MM/YY')
WHEN (SELECT reportType FROM params) = 'MONTH' THEN to_char(p.period_start, 'Mon YYYY')
ELSE to_char(p.period_start, 'YYYY') END AS period_label,
COALESCE(st.stocked_qty, 0)   AS stocked,COALESCE(isu.issued_qty, 0)   AS issued,COALESCE(di.discarded_qty, 0) AS discarded,
(COALESCE(op.openingstock, 0) + COALESCE((SELECT SUM(s2.stocked_qty) FROM stocked s2 WHERE s2.m_product_id = pr.m_product_id), 0)
 - COALESCE((SELECT SUM(i2.issued_qty) FROM issued i2 WHERE i2.m_product_id = pr.m_product_id), 0) 
 - COALESCE((SELECT SUM(d2.discarded_qty) FROM discarded d2 WHERE d2.m_product_id = pr.m_product_id), 0)) AS balance,
COALESCE((SELECT SUM(s2.stocked_qty) FROM stocked s2 WHERE s2.m_product_id = pr.m_product_id), 0)    AS total_stocked,
COALESCE((SELECT SUM(i2.issued_qty) FROM issued i2 WHERE i2.m_product_id = pr.m_product_id), 0)      AS total_issued,
COALESCE((SELECT SUM(d2.discarded_qty) FROM discarded d2 WHERE d2.m_product_id = pr.m_product_id), 0)  AS total_discarded
FROM adempiere.m_product pr JOIN adempiere.m_product_category pc ON pr.m_product_category_id = pc.m_product_category_id
LEFT JOIN opening op ON op.m_product_id = pr.m_product_id CROSS JOIN periods p
LEFT JOIN stocked st ON st.m_product_id = pr.m_product_id AND st.period_start = p.period_start
LEFT JOIN issued isu  ON isu.m_product_id  = pr.m_product_id AND isu.period_start  = p.period_start
LEFT JOIN discarded di ON di.m_product_id = pr.m_product_id AND di.period_start = p.period_start
WHERE pc.name = 'BMedia'
AND pr.ad_client_id = (SELECT target_client_id FROM params) AND (COALESCE(st.stocked_qty, 0) <> 0 
OR COALESCE(isu.issued_qty, 0) <> 0 OR COALESCE(di.discarded_qty, 0) <> 0)
ORDER BY pr.m_product_id, p.period_start;

++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
============================================================================================================


SELECT pr.m_product_id,pr.name AS mediacategory,pr.description AS codeifany,
COALESCE(ml.openingstock, 0::numeric) AS openingbalance,COALESCE(ml.stocked, 0::numeric) AS mediastocked,
COALESCE(mol.totalqty, 0::numeric) AS issuetoct,COALESCE(ml.openingstock, 0::numeric) + COALESCE(ml.stocked, 0::numeric)
 - COALESCE(mol.totalqty, 0::numeric) - COALESCE(di.discarded_qty, 0::numeric) AS balance,ml.updated,
COALESCE(di.discarded_qty, 0::numeric) AS discardedquantity FROM adempiere.m_product pr
LEFT JOIN (SELECT  pr_1.m_product_id,MAX(date(ml_1.updated)) AS updated,        
SUM(CASE WHEN date(ml_1.created) < $P{Date} THEN ml_1.quantity ELSE 0  END) AS openingstock,        
SUM(CASE  WHEN date(ml_1.created) BETWEEN  $P{Date} AND $P{DateTo} THEN ml_1.quantity ELSE 0  END) AS stocked
FROM adempiere.tc_medialine ml_1 JOIN adempiere.m_product pr_1 ON pr_1.m_product_id = ml_1.m_product_id
WHERE ml_1.ad_client_id = $P{AD_CLIENT_ID}  GROUP BY pr_1.m_product_id) ml ON pr.m_product_id = ml.m_product_id
LEFT JOIN (SELECT pro.m_product_id,
SUM(CASE  WHEN date(mol_1.created) BETWEEN  $P{Date} AND $P{DateTo} THEN mol_1.quantity  ELSE 0  END) AS totalqty
FROM adempiere.tc_mediaoutline mol_1 JOIN adempiere.m_product pro ON pro.m_product_id = mol_1.m_product_id
WHERE mol_1.ad_client_id = $P{AD_CLIENT_ID} GROUP BY pro.m_product_id) mol ON pr.m_product_id = mol.m_product_id
LEFT JOIN (SELECT ml_1.m_product_id,
SUM(CASE  WHEN mlq.isdiscarded = 'Y' AND date(ml_1.created) BETWEEN  $P{Date}  AND $P{DateTo} THEN ml_1.quantity ELSE 0  END) AS discarded_qty
FROM adempiere.tc_medialine ml_1 JOIN adempiere.tc_medialabelqr mlq ON ml_1.tc_medialine_id = mlq.tc_medialine_id
WHERE ml_1.ad_client_id = $P{AD_CLIENT_ID} GROUP BY ml_1.m_product_id) di ON pr.m_product_id = di.m_product_id
JOIN adempiere.m_product_category pc ON pr.m_product_category_id = pc.m_product_category_id
WHERE pc.name = 'BMedia' AND pr.ad_client_id = $P{AD_CLIENT_ID} ;


-----------------------------------------------------------------------------------------------------------------------------
*****************************************************************************************************************************
-----------------------------------------------------------------------------------------------------------------------------
Sales Invoices updated Postgres Query:-

select iv.c_invoice_id, iv.documentno as Invoice_No, to_char(iv.DateInvoiced, 'DD-Mon-YYYY') as Date_Invoiced, org.name as OrgName, org_loc.address as org_address, org_loc.city as org_city, org_loc.regionname as org_regionname,
org_loc.countryname as org_countryname, org_loc.postal as org_postal, bp_loc.address as bp_address, bp_loc.city as bp_city, bp_loc.regionname as bp_regionname,
bp_loc.countryname as bp_countryname, bp_loc.postal as bp_postal,ivl.description,
(case when ivl.m_product_id>0 then mp.name else cha.name end) as item,
iv.totallines as SubTotal, iv.grandtotal as Total_Amount, (iv.grandtotal-iv.totallines) as Tax_Amount,
ivl.line as Product_SNo, mp.name as Product_Name, ivl.qtyinvoiced as Product_Qty_Invoiced, round(ivl.priceentered,2) as Product_Price_Entered,
cr.iso_code as Product_Currency_Name, tax.name as Product_Tax_Name, tax.rate as Product_Tax_Rate, ivl.taxamt as Product_Tax_Amount, mp.hsncode as Product_HSN,
ivl.linenetamt as Product_Line_Amount, iv.description, iv.poreference, bp.name as customer_name,
to_char(
    CASE 
        WHEN sh.created IS NOT NULL THEN sh.created
        WHEN ph.created IS NOT NULL THEN ph.created
        ELSE NULL
    END,
    'DD/MM/YYYY'
) AS date_of_hardening,
CASE 
    WHEN sh.parentcultureline IS NOT NULL THEN sh.parentcultureline
    WHEN ph.parentcultureline IS NOT NULL THEN ph.parentcultureline
    ELSE NULL
END AS parentcultureline,
CASE 
    WHEN sh.tc_variety_id IS NOT NULL THEN tv_sh.name
    WHEN ph.tc_variety_id IS NOT NULL THEN tv_ph.name
END AS variety,

-- fnNumberToWords(iv.grandtotal::BIGINT) as AmountInWord,
	cr.description as currency_name,cor.secondaryhardeninguuid As secondaryhardeninguuid,
wh.name as wareName, ware_loc.address as ware_address, ware_loc.city as ware_city, ware_loc.regionname as ware_regionname, io.documentno as InOutNo, to_char(io.movementdate, 'DD-Mon-YYYY') as InOutDate,
ware_loc.countryname as ware_countryname, ware_loc.postal as ware_postal, orginfo.Phone,
cli.gstno client_gstno, cli.panno as client_panno, bp.gstno as bp_gstno, bp.panno as bp_panno, cr.cursymbol, encode(org_img.binarydata,'base64') as logo_binarydata, cli.Name as companyname
from adempiere.c_invoice iv
left join adempiere.c_invoiceline ivl on (iv.c_invoice_id=ivl.c_invoice_id)
left join adempiere.c_order cor On (cor.c_order_id = iv.c_order_id) 	
left join adempiere.m_inout io on (cor.c_order_id=io.c_order_id)
left join adempiere.c_bpartner bp on (bp.c_bpartner_id=iv.c_bpartner_id)
left join adempiere.ad_org org on (org.AD_Org_ID=iv.AD_Org_ID)
left join adempiere.ad_orginfo orginfo on (orginfo.AD_Org_ID=iv.AD_Org_ID)
left join adempiere.ad_image org_img on (orginfo.Logo_ID=org_img.ad_image_id)
left join adempiere.m_warehouse wh on (wh.m_warehouse_id=orginfo.m_warehouse_id)
left join adempiere.ad_client cli on (cli.ad_client_id=iv.ad_client_id)
left join adempiere.location_details ware_loc on (ware_loc.c_location_id=wh.c_location_id)
left join adempiere.location_details org_loc on (org_loc.c_location_id=orginfo.c_location_id)
left join adempiere.c_bpartner_location bpl on (bpl.c_bpartner_location_id=iv.c_bpartner_location_id)
left join adempiere.location_details bp_loc on (bp_loc.c_location_id=bpl.c_location_id)
left join adempiere.m_product mp on (mp.m_product_id=ivl.m_product_id)
left join adempiere.c_charge cha on (cha.c_charge_id=ivl.c_charge_id)
left join adempiere.c_uom uom on (uom.c_uom_id=ivl.c_uom_id)
left join adempiere.c_tax tax on (tax.c_tax_id=ivl.c_tax_id)
left join adempiere.c_currency cr on (cr.c_currency_id=iv.c_currency_id)
LEFT JOIN adempiere.TC_SecondaryHardeningLabel sh ON sh.c_uuid = cor.secondaryhardeninguuid
LEFT JOIN adempiere.TC_PrimaryHardeningLabel ph ON ph.c_uuid = cor.secondaryhardeninguuid
LEFT JOIN adempiere.tc_variety tv_sh ON tv_sh.tc_variety_id = sh.tc_variety_id
LEFT JOIN adempiere.tc_variety tv_ph ON tv_ph.tc_variety_id = ph.tc_variety_id

where (iv.C_Invoice_ID = 1000034 OR iv.C_Invoice_ID = 1000034 ) AND iv.ad_client_id = 1000002 
Order by ivl.line;



</textField>
			<line>
				<reportElement positionType="Float" stretchType="RelativeToTallestObject" x="77" y="69" width="1" height="19" forecolor="#000000" uuid="942d1447-2172-4786-a868-4bbff026d52c"/>
				<graphicElement>
					<pen lineWidth="1.0"/>
				</graphicElement>
			</line>
			<textField textAdjust="StretchHeight">
				<reportElement positionType="Float" stretchType="RelativeToBandHeight" x="34" y="69" width="171" height="19" uuid="0cd1b030-dd52-4c52-93df-cf8b8515cd2f"/>
				<textElement verticalAlignment="Middle"/>
				<textFieldExpression><![CDATA[$F{product_name}]]></textFieldExpression>
			</textField>
		</band>





=======================================================================================================
Customer invoice & Sales QR line align query and its working on Postgres:-

SELECT iv.c_invoice_id,iv.documentno AS Invoice_No,TO_CHAR(iv.DateInvoiced, 'DD-Mon-YYYY') AS Date_Invoiced,org.name AS OrgName,
org_loc.address AS org_address,org_loc.city AS org_city,org_loc.regionname AS org_regionname,org_loc.countryname AS org_countryname,
org_loc.postal AS org_postal,bp_loc.address AS bp_address,bp_loc.city AS bp_city,bp_loc.regionname AS bp_regionname,
bp_loc.countryname AS bp_countryname,bp_loc.postal AS bp_postal,ivl.description,(CASE WHEN ivl.m_product_id>0 THEN mp.name ELSE cha.name END) AS item,
iv.totallines AS SubTotal,iv.grandtotal AS Total_Amount,(iv.grandtotal-iv.totallines) AS Tax_Amount,ivl.line AS Product_SNo,
mp.name AS Product_Name,ivl.qtyinvoiced AS Product_Qty_Invoiced,ROUND(ivl.priceentered,2) AS Product_Price_Entered,
cr.iso_code AS Product_Currency_Name,tax.name AS Product_Tax_Name,tax.rate AS Product_Tax_Rate,ivl.taxamt AS Product_Tax_Amount,
mp.hsncode AS Product_HSN,ivl.linenetamt AS Product_Line_Amount,iv.description,iv.poreference,bp.name AS customer_name,
TO_CHAR(CASE 
WHEN sh.created IS NOT NULL THEN sh.created WHEN ph.created IS NOT NULL THEN ph.created
    ELSE NULL END, 'DD/MM/YYYY') AS date_of_hardening,
CASE 
WHEN sh.parentcultureline IS NOT NULL THEN sh.parentcultureline WHEN ph.parentcultureline IS NOT NULL THEN ph.parentcultureline
    ELSE NULL  END AS parentcultureline,
CASE 
WHEN sh.tc_variety_id IS NOT NULL THEN tv_sh.name WHEN ph.tc_variety_id IS NOT NULL THEN tv_ph.name
    END AS variety,
-- fnNumberToWords(iv.grandtotal::BIGINT) as AmountInWord,
cor.secondaryhardeninguuid,q2.village,q2.talukname,q2.district,q2.collection_updated_date,cr.description AS currency_name,
wh.name AS wareName,ware_loc.address AS ware_address,ware_loc.city AS ware_city,ware_loc.regionname AS ware_regionname,
io.documentno AS InOutNo,TO_CHAR(io.movementdate, 'DD-Mon-YYYY') AS InOutDate,ware_loc.countryname AS ware_countryname,
ware_loc.postal AS ware_postal,orginfo.Phone,cli.gstno AS client_gstno,cli.panno AS client_panno,bp.gstno AS bp_gstno,bp.panno AS bp_panno,
cr.cursymbol,ENCODE(org_img.binarydata,'base64') AS logo_binarydata,cli.Name AS companyname
FROM adempiere.c_invoice iv LEFT JOIN adempiere.c_invoiceline ivl ON (iv.c_invoice_id=ivl.c_invoice_id)
LEFT JOIN adempiere.c_order cor ON (cor.c_order_id = iv.c_order_id) LEFT JOIN adempiere.m_inout io ON (cor.c_order_id=io.c_order_id)
LEFT JOIN adempiere.c_bpartner bp ON (bp.c_bpartner_id=iv.c_bpartner_id) LEFT JOIN adempiere.ad_org org ON (org.AD_Org_ID=iv.AD_Org_ID)
LEFT JOIN adempiere.ad_orginfo orginfo ON (orginfo.AD_Org_ID=iv.AD_Org_ID) LEFT JOIN adempiere.ad_image org_img ON (orginfo.Logo_ID=org_img.ad_image_id)
LEFT JOIN adempiere.m_warehouse wh ON (wh.m_warehouse_id=orginfo.m_warehouse_id) LEFT JOIN adempiere.ad_client cli ON (cli.ad_client_id=iv.ad_client_id)
LEFT JOIN adempiere.location_details ware_loc ON (ware_loc.c_location_id=wh.c_location_id) LEFT JOIN adempiere.location_details org_loc ON (org_loc.c_location_id=orginfo.c_location_id)
LEFT JOIN adempiere.c_bpartner_location bpl ON (bpl.c_bpartner_location_id=iv.c_bpartner_location_id) LEFT JOIN adempiere.location_details bp_loc ON (bp_loc.c_location_id=bpl.c_location_id)
LEFT JOIN adempiere.m_product mp ON (mp.m_product_id=ivl.m_product_id) LEFT JOIN adempiere.c_charge cha ON (cha.c_charge_id=ivl.c_charge_id)
LEFT JOIN adempiere.c_uom uom ON (uom.c_uom_id=ivl.c_uom_id) LEFT JOIN adempiere.c_tax tax ON (tax.c_tax_id=ivl.c_tax_id)
LEFT JOIN adempiere.c_currency cr ON (cr.c_currency_id=iv.c_currency_id) LEFT JOIN adempiere.TC_SecondaryHardeningLabel sh ON sh.c_uuid = cor.secondaryhardeninguuid
LEFT JOIN adempiere.TC_PrimaryHardeningLabel ph ON ph.c_uuid = cor.secondaryhardeninguuid LEFT JOIN adempiere.tc_variety tv_sh ON tv_sh.tc_variety_id = sh.tc_variety_id
LEFT JOIN adempiere.tc_variety tv_ph ON tv_ph.tc_variety_id = ph.tc_variety_id
LEFT JOIN LATERAL (
WITH RECURSIVE cte AS (
SELECT cl.parentuuid,cl.c_uuid,cl.created,var.name AS variety,NULL AS village,NULL AS talukname,NULL AS district,NULL AS collection_updated_date
FROM adempiere.tc_culturelabel cl JOIN adempiere.tc_variety var ON var.tc_variety_id = cl.tc_variety_id
WHERE cl.c_uuid = cor.secondaryhardeninguuid
UNION ALL
SELECT phs.cultureuuid AS parentuuid,cl.c_uuid,cl.created,var.name AS variety,NULL AS village,NULL AS talukname,NULL AS district,
NULL AS collection_updated_date FROM adempiere.TC_PrimaryHardeningLabel ph
JOIN adempiere.tc_primaryHardeningcultureS phs ON phs.TC_PrimaryHardeningLabel_id = ph.TC_PrimaryHardeningLabel_id
JOIN adempiere.tc_culturelabel cl ON phs.cultureuuid = cl.c_uuid JOIN adempiere.tc_variety var ON var.tc_variety_id = cl.tc_variety_id
WHERE ph.c_uuid = cor.secondaryhardeninguuid
UNION ALL
SELECT phs.cultureuuid AS parentuuid,cl.c_uuid,cl.created,var.name AS variety,NULL AS village,NULL AS talukname,NULL AS district,
NULL AS collection_updated_date FROM adempiere.TC_SecondaryHardeningLabel sh JOIN adempiere.TC_PrimaryHardeningLabel ph ON sh.parentuuid = ph.c_uuid
JOIN adempiere.tc_primaryHardeningcultureS phs ON phs.TC_PrimaryHardeningLabel_id = ph.TC_PrimaryHardeningLabel_id
JOIN adempiere.tc_culturelabel cl ON phs.cultureuuid = cl.c_uuid JOIN adempiere.tc_variety var ON var.tc_variety_id = cl.tc_variety_id
WHERE sh.c_uuid = cor.secondaryhardeninguuid
UNION ALL
SELECT cl2.parentuuid,cl2.c_uuid,cl2.created,var.name AS variety,NULL AS village,NULL AS talukname,NULL AS district,
NULL AS collection_updated_date FROM cte JOIN adempiere.tc_culturelabel cl2 ON cte.parentuuid = cl2.c_uuid
JOIN adempiere.tc_variety var ON var.tc_variety_id = cl2.tc_variety_id),
culture_result AS (
SELECT cte.parentuuid,cte.c_uuid,cte.created,cte.variety,cte.village,cte.talukname,cte.district,cte.collection_updated_date
FROM cte GROUP BY cte.parentuuid, cte.c_uuid, cte.created, cte.variety, cte.village, cte.talukname, cte.district, cte.collection_updated_date
UNION ALL
SELECT DISTINCT tcc.parentuuid,tcc.c_uuid,tcc.created,cte.variety,cte.village,cte.talukname,cte.district,NULL AS collection_updated_date
FROM cte LEFT JOIN adempiere.tc_explantlabel tcc ON cte.parentuuid = tcc.c_uuid
UNION ALL
SELECT DISTINCT NULL,tpt.c_uuid,tpt.created,cte.variety,f.villagename2 AS village,f.talukname,f.district,
TO_CHAR(cp.updated, 'DD/MM/YYYY') AS collection_updated_date FROM cte
LEFT JOIN adempiere.tc_explantlabel tcc ON cte.parentuuid = tcc.c_uuid LEFT JOIN adempiere.tc_planttag tpt ON tcc.parentuuid = tpt.c_uuid
JOIN adempiere.tc_plantdetails pd ON pd.planttaguuid = tpt.c_uuid
JOIN adempiere.TC_collectionjoinplant cp ON cp.TC_PlantDetails_ID = pd.TC_PlantDetails_ID
JOIN adempiere.tc_farmer f ON pd.tc_farmer_id = f.tc_farmer_id WHERE tpt.c_uuid IS NOT NULL),
explant_result AS (
SELECT DISTINCT tcc.parentuuid,tcc.c_uuid,tcc.created,var.name AS variety,NULL AS village,NULL AS talukname,NULL AS district,
NULL AS collection_updated_date FROM adempiere.tc_explantlabel tcc
JOIN adempiere.tc_variety var ON var.tc_variety_id = tcc.tc_variety_id WHERE tcc.c_uuid = cor.secondaryhardeninguuid
UNION ALL
SELECT DISTINCT NULL,tpt.c_uuid,tpt.created,var.name AS variety,f.villagename2 AS village,f.talukname,f.district,
TO_CHAR(cp.updated, 'DD/MM/YYYY') AS collection_updated_date FROM adempiere.tc_planttag tpt
JOIN adempiere.tc_explantlabel tcc ON tcc.parentuuid = tpt.c_uuid JOIN adempiere.tc_plantdetails pd ON pd.planttaguuid = tpt.c_uuid
JOIN adempiere.TC_collectionjoinplant cp ON cp.TC_PlantDetails_ID = pd.TC_PlantDetails_ID JOIN adempiere.tc_farmer f ON pd.tc_farmer_id = f.tc_farmer_id
JOIN adempiere.tc_variety var ON var.tc_variety_id = pd.tc_variety_id
WHERE tcc.c_uuid = cor.secondaryhardeninguuid AND tpt.c_uuid IS NOT NULL),
plant_tag_result AS (
SELECT DISTINCT NULL,tpt.c_uuid,tpt.created,var.name AS variety,f.villagename2 AS village,f.talukname,f.district,
TO_CHAR(cp.updated, 'DD/MM/YYYY') AS collection_updated_date FROM adempiere.tc_planttag tpt
JOIN adempiere.tc_plantdetails pd ON pd.planttaguuid = tpt.c_uuid JOIN adempiere.TC_collectionjoinplant cp ON cp.TC_PlantDetails_ID = pd.TC_PlantDetails_ID
JOIN adempiere.tc_farmer f ON pd.tc_farmer_id = f.tc_farmer_id JOIN adempiere.tc_variety var ON var.tc_variety_id = pd.tc_variety_id
WHERE tpt.c_uuid = cor.secondaryhardeninguuid),
primary_result AS (
SELECT phs.cultureuuid AS parentuuid,ph.c_uuid,ph.created,var.name AS variety,NULL AS village,NULL AS talukname,NULL AS district,
NULL AS collection_updated_date FROM adempiere.TC_PrimaryHardeningLabel ph
JOIN adempiere.tc_primaryHardeningcultureS phs ON phs.TC_PrimaryHardeningLabel_id = ph.TC_PrimaryHardeningLabel_id
JOIN adempiere.tc_variety var ON var.tc_variety_id = ph.tc_variety_id WHERE ph.c_uuid = cor.secondaryhardeninguuid),
secondary_result AS (
SELECT sh.parentuuid,sh.c_uuid,sh.created,var.name AS variety,NULL AS village,NULL AS talukname,NULL AS district,NULL AS collection_updated_date
FROM adempiere.TC_SecondaryHardeningLabel sh JOIN adempiere.tc_variety var ON var.tc_variety_id = sh.tc_variety_id
WHERE sh.c_uuid = cor.secondaryhardeninguuid
UNION ALL
SELECT phs.cultureuuid AS parentuuid,ph.c_uuid,ph.created,var.name AS variety,NULL AS village,NULL AS talukname,NULL AS district,
NULL AS collection_updated_date FROM adempiere.TC_SecondaryHardeningLabel sh
JOIN adempiere.TC_PrimaryHardeningLabel ph ON sh.parentuuid = ph.c_uuid
JOIN adempiere.tc_primaryHardeningcultureS phs ON phs.TC_PrimaryHardeningLabel_id = ph.TC_PrimaryHardeningLabel_id
JOIN adempiere.tc_variety var ON var.tc_variety_id = ph.tc_variety_id WHERE sh.c_uuid = cor.secondaryhardeninguuid)
SELECT * FROM secondary_result	
UNION ALL
SELECT * FROM primary_result
UNION ALL
SELECT * FROM culture_result WHERE (parentuuid IS NULL OR parentuuid <> c_uuid)
UNION ALL
SELECT * FROM explant_result WHERE NOT EXISTS (SELECT 1 FROM culture_result)
UNION ALL
SELECT * FROM plant_tag_result WHERE NOT EXISTS (SELECT 1 FROM explant_result) AND NOT EXISTS (SELECT 1 FROM culture_result) ORDER BY created ASC LIMIT 1	
) q2 ON TRUE
WHERE (iv.C_Invoice_ID = 1000034) AND iv.ad_client_id = 1000002 ORDER BY ivl.line;

-----------------------------------------------------------------------------------------------------------------		


