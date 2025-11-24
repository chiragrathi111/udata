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






=======================================================================================================
List<PO> poList = new Query(ctx, "TC_VisitType", "ad_client_id=?", trxName)
			        .setParameters(clientId)
			        .list();

			StringBuilder visitTypeListQuoted = new StringBuilder();

			for (int i = 0; i < poList.size(); i++) {
			    PO record = poList.get(i);
			    X_TC_VisitType tt = new X_TC_VisitType(ctx, record.get_ID(), trxName);
			    String name = tt.getName();

			    if (i > 0) visitTypeListQuoted.append(",");
			    visitTypeListQuoted.append("'").append(name).append("'");
			}

			String allVisitTypes = visitTypeListQuoted.toString();

			if (visitType == null || visitType.trim().isEmpty() || visitType.equalsIgnoreCase("all")) {
			    visitType = allVisitTypes;
			}else {
		        visitType = "'" + visitType + "'";
		    }
			
			String sql = null;
			if (userInput.equals("day")) {
				sql = "SELECT TO_CHAR(CURRENT_DATE, 'Day') AS day_name,CURRENT_DATE AS date,COUNT(DISTINCT v.tc_visit_id) AS visit_count\n"
						+ "FROM adempiere.tc_visit v INNER JOIN adempiere.ad_user u ON u.ad_user_id = v.updatedby\n"
						+ "INNER JOIN adempiere.tc_status s ON s.tc_status_id = v.tc_status_id AND s.name = 'Completed'\n"
						+ "INNER JOIN adempiere.tc_visittype vt ON vt.tc_visittype_id = v.tc_visittype_id\n"
						+ "AND vt.name IN (" + visitType + ")  WHERE v.updated::date = CURRENT_DATE\n"
						+ "AND v.ad_client_id = ? AND u.name = ?;";
			} else if (userInput.equals("week")) {
				sql = "WITH days AS (SELECT generate_series(0, 6) AS day_of_week),\n"
						+ "visit_counts AS (SELECT v.updated::date AS visit_day,to_char(v.updated::date, 'FMDay') AS day_name,\n"
						+ "EXTRACT(dow FROM v.updated::date)::int AS day_of_week,COUNT(DISTINCT v.tc_visit_id) AS visit_count\n"
						+ "FROM adempiere.tc_visit v JOIN adempiere.ad_user u ON u.ad_user_id = v.updatedby           \n"
						+ "JOIN adempiere.tc_status s ON s.tc_status_id = v.tc_status_id AND s.name = 'Completed'\n"
						+ "JOIN adempiere.tc_visittype vt ON vt.tc_visittype_id = v.tc_visittype_id\n"
						+ "AND vt.name IN (" + visitType + ") WHERE v.ad_client_id = ? AND TRIM(u.name) = ?\n"
						+ "AND v.updated::date BETWEEN (CURRENT_DATE - INTERVAL '6 days')::date AND CURRENT_DATE\n"
						+ "GROUP BY v.updated::date,to_char(v.updated::date, 'FMDay'),EXTRACT(dow FROM v.updated::date))\n"
						+ "SELECT (CURRENT_DATE - INTERVAL '6 days' + d.day_of_week * INTERVAL '1 day')::date AS dates,\n"
						+ "COALESCE(vc.day_name,to_char((CURRENT_DATE - INTERVAL '6 days' + d.day_of_week * INTERVAL '1 day')::date, 'FMDay')) AS day_name,\n"
						+ "COALESCE(vc.visit_count, 0) AS visit_count FROM days d\n"
						+ "LEFT JOIN visit_counts vc ON (CURRENT_DATE - INTERVAL '6 days' + d.day_of_week * INTERVAL '1 day')::date = vc.visit_day ORDER BY dates;";
			} else if (userInput.equals("month")) {
				sql = "WITH weeks AS (SELECT generate_series(0, 4) AS week_number),\n"
						+ "visit_counts AS (SELECT date_trunc('week', v.updated)::date AS week_start,\n"
						+ "to_char(date_trunc('week', v.updated), 'YYYY-MM-DD') AS week_start_str,COUNT(*) AS visit_count\n"
						+ "FROM adempiere.tc_visit v JOIN adempiere.ad_user u ON u.ad_user_id = v.updatedby\n"
						+ "JOIN adempiere.tc_status s ON s.tc_status_id = v.tc_status_id AND s.name = 'Completed'\n"
						+ "JOIN adempiere.tc_visittype vt ON vt.tc_visittype_id = v.tc_visittype_id AND vt.name IN (" + visitType + ") \n"
						+ "WHERE v.ad_client_id = ? AND u.name = ? AND v.updated::date >= (current_date - interval '29 days')::date\n"
						+ "AND v.updated::date <= current_date GROUP BY date_trunc('week', v.updated)),\n"
						+ "date_range AS (SELECT (current_date - interval '29 days')::date + generate_series(0, 29) AS day)\n"
						+ "SELECT to_char(date_trunc('week', day), 'YYYY-MM-DD') AS week_start,COALESCE(vc.visit_count, 0) AS visit_count\n"
						+ "FROM date_range LEFT JOIN visit_counts vc ON date_trunc('week', day) = vc.week_start\n"
						+ "GROUP BY date_trunc('week', day),vc.visit_count ORDER BY week_start;";
			} else if (userInput.equals("year")) {
				sql = "WITH months AS (SELECT generate_series(0, 11) AS month),\n"
						+ "visit_counts AS (SELECT date_trunc('month', v.updated)::date AS month_year,to_char(v.updated, 'FMMonth') AS month_name,COUNT(*) AS visit_count\n"
						+ "FROM adempiere.tc_visit v JOIN adempiere.ad_user u ON u.ad_user_id = v.updatedby\n"
						+ "JOIN adempiere.tc_status s ON s.tc_status_id = v.tc_status_id AND s.name = 'Completed'\n"
						+ "JOIN adempiere.tc_visittype vt ON vt.tc_visittype_id = v.tc_visittype_id AND vt.name IN (" + visitType + ") \n"
						+ "WHERE v.ad_client_id = ? AND u.name = ?\n"
						+ "AND v.updated::date >= (current_date - interval '364 days')::date AND v.updated::date <= current_date\n"
						+ "GROUP BY date_trunc('month', v.updated),to_char(v.updated, 'FMMonth'))\n"
						+ "SELECT to_char(date_trunc('month', current_date)  - (m.month || ' months')::interval, 'YYYY-MM-01') AS month_date,\n"
						+ "COALESCE(vc.visit_count, 0) AS visit_count FROM months m LEFT JOIN visit_counts vc\n"
						+ "ON date_trunc('month', current_date) - (m.month || ' months')::interval = vc.month_year\n"
						+ "ORDER BY date_trunc('month', current_date) - (m.month || ' months')::interval;";
			} else if (userInput.equals("all")) {
				sql = "WITH year_counts AS (SELECT date_trunc('year', v.updated)::date AS year_start,COUNT(*) AS counts\n"
						+ "FROM adempiere.tc_visit v JOIN adempiere.ad_user u ON u.ad_user_id = v.updatedby\n"
						+ "JOIN adempiere.tc_status s ON s.tc_status_id = v.tc_status_id AND s.name = 'Completed'\n"
						+ "JOIN adempiere.tc_visittype vt ON vt.tc_visittype_id = v.tc_visittype_id AND vt.name IN (" + visitType + ") \n"
						+ "WHERE v.ad_client_id = ? AND u.name = ? GROUP BY date_trunc('year', v.updated)),\n"
						+ "year_range AS (SELECT date_trunc('year', CURRENT_DATE)::date AS year_start\n"
						+ "UNION ALL\n"
						+ "SELECT generate_series((SELECT MIN(year_start) FROM year_counts),date_trunc('year', CURRENT_DATE)::date,interval '1 year')::date AS year_start),\n"
						+ "all_years AS (SELECT DISTINCT year_start FROM year_range)\n"
						+ "SELECT to_char(a.year_start, 'YYYY-01-01') AS year_date,COALESCE(y.counts, 0) AS counts FROM all_years a\n"
						+ "LEFT JOIN year_counts y ON a.year_start = y.year_start ORDER BY a.year_start;";

			}			


