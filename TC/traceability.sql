Taking time Tracebility Report:-
WITH RECURSIVE cte AS (
    ----------------------------------------------------------------
    -- 1. Start from CULTURE UUID
    ----------------------------------------------------------------
    SELECT cl.parentuuid,cl.tc_in_id,cl.tc_out_id,cl.c_uuid,loc.value AS location,cl.created,
           cl.cycleno,ps.name AS cropType,cs.name AS stage,var.name AS variety,
           cl.personal_code,ts.temperature AS temp,ts.humidity AS humidity,1 AS level
    FROM adempiere.tc_culturelabel cl
    JOIN adempiere.tc_out o ON o.tc_out_id = cl.tc_out_id
    JOIN adempiere.m_locator loc ON loc.m_locator_id = o.m_locator_id
    JOIN adempiere.tc_plantspecies ps ON ps.tc_plantspecies_id = cl.tc_species_id
    JOIN adempiere.tc_culturestage cs ON cs.tc_culturestage_id = cl.tc_culturestage_id
    JOIN adempiere.tc_variety var ON var.tc_variety_id = cl.tc_variety_id
    JOIN adempiere.m_locatortype lt ON lt.m_locatortype_id = loc.m_locatortype_id
    JOIN adempiere.tc_temperaturestatus ts ON ts.m_locatortype_id = lt.m_locatortype_id
    WHERE TRIM(cl.c_uuid) = TRIM('b451dfaf-f068-4e31-beaf-6fa18e9bbae8')
      AND cl.ad_client_id = 1000002
      AND DATE(ts.created) = (
          SELECT MAX(DATE(created))
          FROM adempiere.tc_temperaturestatus
          WHERE ad_client_id = 1000002
      )

    UNION ALL
    ----------------------------------------------------------------
    -- 2. Start from PRIMARY HARDENING UUID (connect to ROOTING culture)
    ----------------------------------------------------------------
    SELECT phs.cultureuuid AS parentuuid,cl.tc_in_id,cl.tc_out_id,cl.c_uuid,loc.value AS location,cl.created,
           cl.cycleno,ps.name AS cropType,cs.name AS stage,var.name AS variety,
           cl.personal_code,null AS temp,null AS humidity,1 AS level
    FROM adempiere.TC_PrimaryHardeningLabel ph
	JOIN adempiere.tc_primaryHardeningcultureS phs ON phs.TC_PrimaryHardeningLabel_id = ph.TC_PrimaryHardeningLabel_id
    JOIN adempiere.tc_culturelabel cl ON phs.cultureuuid = cl.c_uuid
    JOIN adempiere.tc_out o ON o.tc_out_id = cl.tc_out_id
    JOIN adempiere.m_locator loc ON loc.m_locator_id = o.m_locator_id
    JOIN adempiere.tc_plantspecies ps ON ps.tc_plantspecies_id = cl.tc_species_id
    JOIN adempiere.tc_culturestage cs ON cs.tc_culturestage_id = cl.tc_culturestage_id
    JOIN adempiere.tc_variety var ON var.tc_variety_id = cl.tc_variety_id
    JOIN adempiere.m_locatortype lt ON lt.m_locatortype_id = loc.m_locatortype_id
    WHERE TRIM(ph.c_uuid) = TRIM('b451dfaf-f068-4e31-beaf-6fa18e9bbae8')
      AND ph.ad_client_id = 1000002
    UNION ALL
    ----------------------------------------------------------------
    -- 3. Recursive step: culture → parent culture
    ----------------------------------------------------------------
    SELECT cl2.parentuuid,cl2.tc_in_id,cl2.tc_out_id,cl2.c_uuid,loc.value AS location,cl2.created,
           cl2.cycleno,ps.name AS cropType,cs.name AS stage,var.name AS variety,
           cl2.personal_code,ts.temperature AS temp,ts.humidity AS humidity,cte.level + 1 AS level
    FROM cte
    JOIN adempiere.tc_culturelabel cl2 ON cte.parentuuid = cl2.c_uuid
    JOIN adempiere.tc_out o ON o.tc_out_id = cl2.tc_out_id
    JOIN adempiere.m_locator loc ON loc.m_locator_id = o.m_locator_id
    JOIN adempiere.tc_plantspecies ps ON ps.tc_plantspecies_id = cl2.tc_species_id
    JOIN adempiere.tc_culturestage cs ON cs.tc_culturestage_id = cl2.tc_culturestage_id
    JOIN adempiere.tc_variety var ON var.tc_variety_id = cl2.tc_variety_id
    JOIN adempiere.m_locatortype lt ON lt.m_locatortype_id = loc.m_locatortype_id
    JOIN adempiere.tc_temperaturestatus ts ON ts.m_locatortype_id = lt.m_locatortype_id
),
----------------------------------------------------------------
-- Culture stage aggregation
----------------------------------------------------------------
culture_result AS (
    SELECT cte.parentuuid,cte.tc_in_id,cte.tc_out_id,cte.c_uuid,cte.location,cte.created,cte.cycleno,
           cte.cropType,cte.stage,cte.variety,cte.personal_code,
           MIN(cte.temp) AS min_temperature,MAX(cte.temp) AS max_temperature,
           MIN(cte.humidity) AS min_humidity,MAX(cte.humidity) AS max_humidity,cte.level
    FROM cte
    GROUP BY cte.parentuuid, cte.tc_in_id, cte.tc_out_id, cte.c_uuid,cte.location,
             cte.created, cte.cycleno, cte.cropType, cte.stage, cte.variety,
             cte.personal_code, cte.level

    UNION ALL
    -- Explant from culture
    SELECT DISTINCT tcc.parentuuid,tcc.tc_in_id,tcc.tc_out_id,tcc.c_uuid,loc.value AS location,tcc.created,0 AS cycleno,
           cte.cropType,pr.name AS stage,cte.variety,tcc.personalcode AS personal_code,
           NULL AS min_temperature,NULL AS max_temperature,NULL AS min_humidity,NULL AS max_humidity,cte.level
    FROM cte
    LEFT JOIN adempiere.tc_explantlabel tcc ON cte.parentuuid = tcc.c_uuid
    JOIN adempiere.tc_out eo ON eo.tc_out_id = tcc.tc_out_id
    JOIN adempiere.m_locator loc ON loc.m_locator_id = eo.m_locator_id
    JOIN adempiere.m_product pr ON pr.m_product_id = eo.m_product_id

    UNION ALL
    -- Plant tag from explant
    SELECT DISTINCT NULL AS parentuuid,0 AS tc_in_id,0 AS tc_out_id,tpt.c_uuid,NULL AS location,tpt.created,0 AS cycleno,
           cte.cropType,'Plant Tag' AS stage,cte.variety,NULL AS personal_code,
           NULL AS min_temperature,NULL AS max_temperature,NULL AS min_humidity,NULL AS max_humidity,cte.level
    FROM cte
    LEFT JOIN adempiere.tc_explantlabel tcc ON cte.parentuuid = tcc.c_uuid
    LEFT JOIN adempiere.tc_planttag tpt ON tcc.parentuuid = tpt.c_uuid
    WHERE tpt.c_uuid IS NOT NULL
),
----------------------------------------------------------------
-- Explant starting point
----------------------------------------------------------------
explant_result AS (
    SELECT DISTINCT tcc.parentuuid,tcc.tc_in_id,tcc.tc_out_id,tcc.c_uuid,loc.value AS location,tcc.created,0 AS cycleno,
           ps.name AS cropType,pr.name AS stage,var.name AS variety,tcc.personalcode AS personal_code,
           NULL AS min_temperature,NULL AS max_temperature,NULL AS min_humidity,NULL AS max_humidity,1 AS level
    FROM adempiere.tc_explantlabel tcc
    JOIN adempiere.tc_out eo ON eo.tc_out_id = tcc.tc_out_id
    JOIN adempiere.m_locator loc ON loc.m_locator_id = eo.m_locator_id
    JOIN adempiere.tc_plantspecies ps ON ps.tc_plantspecies_id = tcc.tc_species_id
    JOIN adempiere.tc_variety var ON var.tc_variety_id = tcc.tc_variety_id
    JOIN adempiere.m_product pr ON pr.m_product_id = eo.m_product_id
    WHERE TRIM(tcc.c_uuid) = TRIM('b451dfaf-f068-4e31-beaf-6fa18e9bbae8')
      AND tcc.ad_client_id = 1000002

    UNION ALL
    SELECT DISTINCT NULL AS parentuuid,0 AS tc_in_id,0 AS tc_out_id,tpt.c_uuid,NULL AS location,tpt.created,0 AS cycleno,
           ps.name AS cropType,'Plant Tag' AS stage,var.name AS variety,NULL AS personal_code,
           NULL AS min_temperature,NULL AS max_temperature,NULL AS min_humidity,NULL AS max_humidity,2 AS level
    FROM adempiere.tc_planttag tpt
    JOIN adempiere.tc_explantlabel tcc ON tcc.parentuuid = tpt.c_uuid
    JOIN adempiere.tc_plantdetails pd ON pd.planttaguuid = tpt.c_uuid
    JOIN adempiere.tc_plantspecies ps ON ps.tc_plantspecies_id = pd.tc_species_id
    JOIN adempiere.tc_variety var ON var.tc_variety_id = pd.tc_variety_id
    WHERE TRIM(tcc.c_uuid) = TRIM('b451dfaf-f068-4e31-beaf-6fa18e9bbae8')
      AND tpt.c_uuid IS NOT NULL
),
----------------------------------------------------------------
-- Plant tag starting point
----------------------------------------------------------------
plant_tag_result AS (
    SELECT DISTINCT NULL AS parentuuid,0 AS tc_in_id,0 AS tc_out_id,tpt.c_uuid,NULL AS location,tpt.created,0 AS cycleno,
           ps.name AS cropType,'Plant Tag' AS stage,var.name AS variety,NULL AS personal_code,
           NULL AS min_temperature,NULL AS max_temperature,NULL AS min_humidity,NULL AS max_humidity,1 AS level
    FROM adempiere.tc_planttag tpt
    JOIN adempiere.tc_plantdetails pd ON pd.planttaguuid = tpt.c_uuid
    JOIN adempiere.tc_plantspecies ps ON ps.tc_plantspecies_id = pd.tc_species_id
    JOIN adempiere.tc_variety var ON var.tc_variety_id = pd.tc_variety_id
    WHERE TRIM(tpt.c_uuid) = TRIM('b451dfaf-f068-4e31-beaf-6fa18e9bbae8')
      AND tpt.ad_client_id = 1000002
),
----------------------------------------------------------------
-- Primary Hardening standalone (to show itself)
----------------------------------------------------------------
primary_result AS (
    SELECT phs.cultureuuid AS parentuuid,ph.tc_in_id,ph.tc_out_id,ph.c_uuid,loc.value AS location,ph.created,0 AS cycleno,
           ps.name AS cropType,'Primary Hardening' AS stage,var.name AS variety,
           ph.personalcode AS personal_code,NULL AS min_temperature,NULL AS max_temperature,
           NULL AS min_humidity,NULL AS max_humidity,0 AS level
    FROM adempiere.TC_PrimaryHardeningLabel ph
	JOIN adempiere.tc_primaryHardeningcultureS phs ON phs.TC_PrimaryHardeningLabel_id = ph.TC_PrimaryHardeningLabel_id
    JOIN adempiere.tc_out o ON o.tc_out_id = ph.tc_out_id
    JOIN adempiere.m_locator loc ON loc.m_locator_id = o.m_locator_id
    JOIN adempiere.tc_plantspecies ps ON ps.tc_plantspecies_id = ph.tc_species_id
    JOIN adempiere.tc_variety var ON var.tc_variety_id = ph.tc_variety_id
    WHERE TRIM(ph.c_uuid) = TRIM('b451dfaf-f068-4e31-beaf-6fa18e9bbae8')
      AND ph.ad_client_id = 1000002
)
----------------------------------------------------------------
-- FINAL OUTPUT
----------------------------------------------------------------
SELECT * FROM primary_result 
UNION ALL
SELECT * FROM culture_result
WHERE (parentuuid IS NULL OR parentuuid <> c_uuid)
UNION ALL
SELECT * FROM explant_result WHERE NOT EXISTS (SELECT 1 FROM culture_result)
UNION ALL 
SELECT * FROM plant_tag_result 
WHERE NOT EXISTS (SELECT 1 FROM explant_result) AND NOT EXISTS (SELECT 1 FROM culture_result)
ORDER BY created ASC;
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
Less Taking time:-
WITH RECURSIVE 
----------------------------------------------------------------
-- Latest temperature date (computed ONCE instead of per row)
----------------------------------------------------------------
-- last_ts AS (
--     SELECT created::date AS created_date
--     FROM adempiere.tc_temperaturestatus
--     WHERE ad_client_id = 1000002
--     ORDER BY created DESC
--     LIMIT 1
-- ),
----------------------------------------------------------------
-- Recursive culture chain
----------------------------------------------------------------
cte AS (
    -- 1. Start from CULTURE UUID
    SELECT cl.parentuuid,cl.tc_in_id,cl.tc_out_id,cl.c_uuid,loc.value AS location,cl.created,
           cl.cycleno,ps.name AS cropType,cs.name AS stage,var.name AS variety,
           cl.personal_code,1 AS level
		   -- ts.temperature AS temp,ts.humidity AS humidity
    FROM adempiere.tc_culturelabel cl
    JOIN adempiere.tc_out o ON o.tc_out_id = cl.tc_out_id
    JOIN adempiere.m_locator loc ON loc.m_locator_id = o.m_locator_id
    JOIN adempiere.tc_plantspecies ps ON ps.tc_plantspecies_id = cl.tc_species_id
    JOIN adempiere.tc_culturestage cs ON cs.tc_culturestage_id = cl.tc_culturestage_id
    JOIN adempiere.tc_variety var ON var.tc_variety_id = cl.tc_variety_id
    -- JOIN adempiere.m_locatortype lt ON lt.m_locatortype_id = loc.m_locatortype_id
    -- JOIN adempiere.tc_temperaturestatus ts 
    --      ON ts.m_locatortype_id = lt.m_locatortype_id
    --     AND ts.created::date = (SELECT created_date FROM last_ts)  -- use precomputed latest
    WHERE TRIM(cl.c_uuid) = TRIM('b451dfaf-f068-4e31-beaf-6fa18e9bbae8')
      AND cl.ad_client_id = 1000002

    UNION ALL
    -- 2. Primary Hardening → Rooting culture
    SELECT phs.cultureuuid AS parentuuid,cl.tc_in_id,cl.tc_out_id,cl.c_uuid,loc.value AS location,cl.created,
           cl.cycleno,ps.name AS cropType,cs.name AS stage,var.name AS variety,
           cl.personal_code,1 AS level
		   -- NULL AS temp,NULL AS humidity
    FROM adempiere.TC_PrimaryHardeningLabel ph
    JOIN adempiere.tc_primaryHardeningcultureS phs ON phs.TC_PrimaryHardeningLabel_id = ph.TC_PrimaryHardeningLabel_id
    JOIN adempiere.tc_culturelabel cl ON phs.cultureuuid = cl.c_uuid
    JOIN adempiere.tc_out o ON o.tc_out_id = cl.tc_out_id
    JOIN adempiere.m_locator loc ON loc.m_locator_id = o.m_locator_id
    JOIN adempiere.tc_plantspecies ps ON ps.tc_plantspecies_id = cl.tc_species_id
    JOIN adempiere.tc_culturestage cs ON cs.tc_culturestage_id = cl.tc_culturestage_id
    JOIN adempiere.tc_variety var ON var.tc_variety_id = cl.tc_variety_id
    -- JOIN adempiere.m_locatortype lt ON lt.m_locatortype_id = loc.m_locatortype_id
    WHERE TRIM(ph.c_uuid) = TRIM('b451dfaf-f068-4e31-beaf-6fa18e9bbae8')
      AND ph.ad_client_id = 1000002

    UNION ALL
    -- 3. Recursive step: culture → parent culture
    SELECT cl2.parentuuid,cl2.tc_in_id,cl2.tc_out_id,cl2.c_uuid,loc.value AS location,cl2.created,
           cl2.cycleno,ps.name AS cropType,cs.name AS stage,var.name AS variety,
           cl2.personal_code,cte.level + 1 AS level
		   -- ts.temperature AS temp,ts.humidity AS humidity
    FROM cte
    JOIN adempiere.tc_culturelabel cl2 ON cte.parentuuid = cl2.c_uuid
    JOIN adempiere.tc_out o ON o.tc_out_id = cl2.tc_out_id
    JOIN adempiere.m_locator loc ON loc.m_locator_id = o.m_locator_id
    JOIN adempiere.tc_plantspecies ps ON ps.tc_plantspecies_id = cl2.tc_species_id
    JOIN adempiere.tc_culturestage cs ON cs.tc_culturestage_id = cl2.tc_culturestage_id
    JOIN adempiere.tc_variety var ON var.tc_variety_id = cl2.tc_variety_id
    -- JOIN adempiere.m_locatortype lt ON lt.m_locatortype_id = loc.m_locatortype_id
    -- JOIN adempiere.tc_temperaturestatus ts 
    --      ON ts.m_locatortype_id = lt.m_locatortype_id
    --     AND ts.created::date = (SELECT created_date FROM last_ts)
),
----------------------------------------------------------------
-- Culture stage aggregation
----------------------------------------------------------------
culture_result AS (
    SELECT cte.parentuuid,cte.tc_in_id,cte.tc_out_id,cte.c_uuid,cte.location,cte.created,cte.cycleno,
           cte.cropType,cte.stage,cte.variety,cte.personal_code,cte.level AS level
           -- MIN(cte.temp) AS min_temperature,MAX(cte.temp) AS max_temperature,
           -- MIN(cte.humidity) AS min_humidity,MAX(cte.humidity) AS max_humidity
    FROM cte
    GROUP BY cte.parentuuid, cte.tc_in_id, cte.tc_out_id, cte.c_uuid,cte.location,
             cte.created, cte.cycleno, cte.cropType, cte.stage, cte.variety,
             cte.personal_code, cte.level

    UNION ALL
    -- Explant from culture
    SELECT DISTINCT tcc.parentuuid,tcc.tc_in_id,tcc.tc_out_id,tcc.c_uuid,loc.value AS location,tcc.created,0 AS cycleno,
           cte.cropType,pr.name AS stage,cte.variety,tcc.personalcode AS personal_code,cte.level AS level
           -- NULL,NULL
		   -- NULL,NULL
    FROM cte
    LEFT JOIN adempiere.tc_explantlabel tcc ON cte.parentuuid = tcc.c_uuid
    JOIN adempiere.tc_out eo ON eo.tc_out_id = tcc.tc_out_id
    JOIN adempiere.m_locator loc ON loc.m_locator_id = eo.m_locator_id
    JOIN adempiere.m_product pr ON pr.m_product_id = eo.m_product_id

    UNION ALL
    -- Plant tag from explant
    SELECT DISTINCT NULL,0,0,tpt.c_uuid,NULL,tpt.created,0 AS cycleno,
           cte.cropType,'Plant Tag' AS stage,cte.variety,NULL,cte.level AS level
           -- NULL,NULL
		   -- ,NULL,NULL
    FROM cte
    LEFT JOIN adempiere.tc_explantlabel tcc ON cte.parentuuid = tcc.c_uuid
    LEFT JOIN adempiere.tc_planttag tpt ON tcc.parentuuid = tpt.c_uuid
    WHERE tpt.c_uuid IS NOT NULL
),
----------------------------------------------------------------
-- Explant starting point
----------------------------------------------------------------
explant_result AS (
    SELECT DISTINCT tcc.parentuuid AS parentuuid,tcc.tc_in_id,tcc.tc_out_id,tcc.c_uuid,loc.value AS location,tcc.created,0 AS cycleno,
           ps.name,pr.name  AS stage,var.name,tcc.personalcode,1 AS level
           -- NULL,NULL
		   -- ,NULL,NULL
    FROM adempiere.tc_explantlabel tcc
    JOIN adempiere.tc_out eo ON eo.tc_out_id = tcc.tc_out_id
    JOIN adempiere.m_locator loc ON loc.m_locator_id = eo.m_locator_id
    JOIN adempiere.tc_plantspecies ps ON ps.tc_plantspecies_id = tcc.tc_species_id
    JOIN adempiere.tc_variety var ON var.tc_variety_id = tcc.tc_variety_id
    JOIN adempiere.m_product pr ON pr.m_product_id = eo.m_product_id
    WHERE TRIM(tcc.c_uuid) = TRIM('b451dfaf-f068-4e31-beaf-6fa18e9bbae8')
      AND tcc.ad_client_id = 1000002

    UNION ALL
    SELECT DISTINCT NULL AS parentuuid,0,0,tpt.c_uuid,NULL,tpt.created,0 AS cycleno,
           ps.name,'Plant Tag' AS stage,var.name,NULL,2 AS level
           -- NULL,NULL,
		   -- ,NULL,NULL
    FROM adempiere.tc_planttag tpt
    JOIN adempiere.tc_explantlabel tcc ON tcc.parentuuid = tpt.c_uuid
    JOIN adempiere.tc_plantdetails pd ON pd.planttaguuid = tpt.c_uuid
    JOIN adempiere.tc_plantspecies ps ON ps.tc_plantspecies_id = pd.tc_species_id
    JOIN adempiere.tc_variety var ON var.tc_variety_id = pd.tc_variety_id
    WHERE TRIM(tcc.c_uuid) = TRIM('b451dfaf-f068-4e31-beaf-6fa18e9bbae8')
      AND tpt.c_uuid IS NOT NULL
),
----------------------------------------------------------------
-- Plant tag starting point
----------------------------------------------------------------
plant_tag_result AS (
    SELECT DISTINCT NULL AS parentuuid,0,0,tpt.c_uuid,NULL,tpt.created,0 AS cycleno,
           ps.name,'Plant Tag' AS stage,var.name,NULL,1 AS level
           -- NULL,NULL
		   -- ,NULL,NULL
    FROM adempiere.tc_planttag tpt
    JOIN adempiere.tc_plantdetails pd ON pd.planttaguuid = tpt.c_uuid
    JOIN adempiere.tc_plantspecies ps ON ps.tc_plantspecies_id = pd.tc_species_id
    JOIN adempiere.tc_variety var ON var.tc_variety_id = pd.tc_variety_id
    WHERE TRIM(tpt.c_uuid) = TRIM('b451dfaf-f068-4e31-beaf-6fa18e9bbae8')
      AND tpt.ad_client_id = 1000002
),
----------------------------------------------------------------
-- Primary Hardening standalone
----------------------------------------------------------------
primary_result AS (
    SELECT phs.cultureuuid AS parentuuid,ph.tc_in_id,ph.tc_out_id,ph.c_uuid,loc.value,ph.created,0 AS cycleno,
           ps.name,'Primary Hardening' AS stage,var.name,
           ph.personalcode,0 AS level
		   -- ,NULL,NULL
		   -- ,NULL,NULL
    FROM adempiere.TC_PrimaryHardeningLabel ph
    JOIN adempiere.tc_primaryHardeningcultureS phs ON phs.TC_PrimaryHardeningLabel_id = ph.TC_PrimaryHardeningLabel_id
    JOIN adempiere.tc_out o ON o.tc_out_id = ph.tc_out_id
    JOIN adempiere.m_locator loc ON loc.m_locator_id = o.m_locator_id
    JOIN adempiere.tc_plantspecies ps ON ps.tc_plantspecies_id = ph.tc_species_id
    JOIN adempiere.tc_variety var ON var.tc_variety_id = ph.tc_variety_id
    WHERE TRIM(ph.c_uuid) = TRIM('b451dfaf-f068-4e31-beaf-6fa18e9bbae8')
      AND ph.ad_client_id = 1000002
)
----------------------------------------------------------------
-- FINAL OUTPUT
----------------------------------------------------------------
SELECT * FROM primary_result 
UNION ALL
SELECT * FROM culture_result
WHERE (parentuuid IS NULL OR parentuuid <> c_uuid)
UNION ALL
SELECT * FROM explant_result WHERE NOT EXISTS (SELECT 1 FROM culture_result)
UNION ALL 
SELECT * FROM plant_tag_result 
WHERE NOT EXISTS (SELECT 1 FROM explant_result) AND NOT EXISTS (SELECT 1 FROM culture_result)
ORDER BY created ASC;


+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
Fast Working :-
WITH RECURSIVE
----------------------------------------------------------------
-- Recursive culture chain
----------------------------------------------------------------
cte AS (
    -- 1. Start from CULTURE UUID
    SELECT cl.parentuuid,cl.tc_in_id,cl.tc_out_id,cl.c_uuid,loc.value AS location,cl.created,
           cl.cycleno,ps.name AS cropType,cs.name AS stage,var.name AS variety,
           cl.personal_code,1 AS level
    FROM adempiere.tc_culturelabel cl
    JOIN adempiere.tc_out o ON o.tc_out_id = cl.tc_out_id
    JOIN adempiere.m_locator loc ON loc.m_locator_id = o.m_locator_id
    JOIN adempiere.tc_plantspecies ps ON ps.tc_plantspecies_id = cl.tc_species_id
    JOIN adempiere.tc_culturestage cs ON cs.tc_culturestage_id = cl.tc_culturestage_id
    JOIN adempiere.tc_variety var ON var.tc_variety_id = cl.tc_variety_id
    WHERE TRIM(cl.c_uuid) = TRIM('b451dfaf-f068-4e31-beaf-6fa18e9bbae8')
      AND cl.ad_client_id = 1000002

    UNION ALL
    -- 2. Primary Hardening → Rooting culture
    SELECT phs.cultureuuid AS parentuuid,cl.tc_in_id,cl.tc_out_id,cl.c_uuid,loc.value AS location,cl.created,
           cl.cycleno,ps.name AS cropType,cs.name AS stage,var.name AS variety,
           cl.personal_code,1 AS level
    FROM adempiere.TC_PrimaryHardeningLabel ph
    JOIN adempiere.tc_primaryHardeningcultureS phs ON phs.TC_PrimaryHardeningLabel_id = ph.TC_PrimaryHardeningLabel_id
    JOIN adempiere.tc_culturelabel cl ON phs.cultureuuid = cl.c_uuid
    JOIN adempiere.tc_out o ON o.tc_out_id = cl.tc_out_id
    JOIN adempiere.m_locator loc ON loc.m_locator_id = o.m_locator_id
    JOIN adempiere.tc_plantspecies ps ON ps.tc_plantspecies_id = cl.tc_species_id
    JOIN adempiere.tc_culturestage cs ON cs.tc_culturestage_id = cl.tc_culturestage_id
    JOIN adempiere.tc_variety var ON var.tc_variety_id = cl.tc_variety_id
    WHERE TRIM(ph.c_uuid) = TRIM('b451dfaf-f068-4e31-beaf-6fa18e9bbae8')
      AND ph.ad_client_id = 1000002

    UNION ALL
    -- 3. Recursive step: culture → parent culture
    SELECT cl2.parentuuid,cl2.tc_in_id,cl2.tc_out_id,cl2.c_uuid,loc.value AS location,cl2.created,
           cl2.cycleno,ps.name AS cropType,cs.name AS stage,var.name AS variety,
           cl2.personal_code,cte.level + 1 AS level
    FROM cte
    JOIN adempiere.tc_culturelabel cl2 ON cte.parentuuid = cl2.c_uuid
    JOIN adempiere.tc_out o ON o.tc_out_id = cl2.tc_out_id
    JOIN adempiere.m_locator loc ON loc.m_locator_id = o.m_locator_id
    JOIN adempiere.tc_plantspecies ps ON ps.tc_plantspecies_id = cl2.tc_species_id
    JOIN adempiere.tc_culturestage cs ON cs.tc_culturestage_id = cl2.tc_culturestage_id
    JOIN adempiere.tc_variety var ON var.tc_variety_id = cl2.tc_variety_id
),
----------------------------------------------------------------
-- Culture stage aggregation
----------------------------------------------------------------
culture_result AS (
    SELECT cte.parentuuid,cte.tc_in_id,cte.tc_out_id,cte.c_uuid,cte.location,cte.created,cte.cycleno,
           cte.cropType,cte.stage,cte.variety,cte.personal_code,cte.level AS level
    FROM cte
    GROUP BY cte.parentuuid, cte.tc_in_id, cte.tc_out_id, cte.c_uuid,cte.location,
             cte.created, cte.cycleno, cte.cropType, cte.stage, cte.variety,
             cte.personal_code, cte.level

    UNION ALL
    -- Explant from culture
    SELECT DISTINCT tcc.parentuuid,tcc.tc_in_id,tcc.tc_out_id,tcc.c_uuid,loc.value AS location,tcc.created,0 AS cycleno,
           cte.cropType,pr.name AS stage,cte.variety,tcc.personalcode AS personal_code,cte.level AS level
    FROM cte
    LEFT JOIN adempiere.tc_explantlabel tcc ON cte.parentuuid = tcc.c_uuid
    JOIN adempiere.tc_out eo ON eo.tc_out_id = tcc.tc_out_id
    JOIN adempiere.m_locator loc ON loc.m_locator_id = eo.m_locator_id
    JOIN adempiere.m_product pr ON pr.m_product_id = eo.m_product_id

    UNION ALL
    -- Plant tag from explant
    SELECT DISTINCT NULL,0,0,tpt.c_uuid,NULL,tpt.created,0 AS cycleno,
           cte.cropType,'Plant Tag' AS stage,cte.variety,NULL,cte.level AS level
    FROM cte
    LEFT JOIN adempiere.tc_explantlabel tcc ON cte.parentuuid = tcc.c_uuid
    LEFT JOIN adempiere.tc_planttag tpt ON tcc.parentuuid = tpt.c_uuid
    WHERE tpt.c_uuid IS NOT NULL
),
----------------------------------------------------------------
-- Explant starting point
----------------------------------------------------------------
explant_result AS (
    SELECT DISTINCT tcc.parentuuid AS parentuuid,tcc.tc_in_id,tcc.tc_out_id,tcc.c_uuid,loc.value AS location,tcc.created,0 AS cycleno,
           ps.name,pr.name  AS stage,var.name,tcc.personalcode,1 AS level
    FROM adempiere.tc_explantlabel tcc
    JOIN adempiere.tc_out eo ON eo.tc_out_id = tcc.tc_out_id
    JOIN adempiere.m_locator loc ON loc.m_locator_id = eo.m_locator_id
    JOIN adempiere.tc_plantspecies ps ON ps.tc_plantspecies_id = tcc.tc_species_id
    JOIN adempiere.tc_variety var ON var.tc_variety_id = tcc.tc_variety_id
    JOIN adempiere.m_product pr ON pr.m_product_id = eo.m_product_id
    WHERE TRIM(tcc.c_uuid) = TRIM('b451dfaf-f068-4e31-beaf-6fa18e9bbae8')
      AND tcc.ad_client_id = 1000002

    UNION ALL
    SELECT DISTINCT NULL AS parentuuid,0,0,tpt.c_uuid,NULL,tpt.created,0 AS cycleno,
           ps.name,'Plant Tag' AS stage,var.name,NULL,2 AS level
    FROM adempiere.tc_planttag tpt
    JOIN adempiere.tc_explantlabel tcc ON tcc.parentuuid = tpt.c_uuid
    JOIN adempiere.tc_plantdetails pd ON pd.planttaguuid = tpt.c_uuid
    JOIN adempiere.tc_plantspecies ps ON ps.tc_plantspecies_id = pd.tc_species_id
    JOIN adempiere.tc_variety var ON var.tc_variety_id = pd.tc_variety_id
    WHERE TRIM(tcc.c_uuid) = TRIM('b451dfaf-f068-4e31-beaf-6fa18e9bbae8')
      AND tpt.c_uuid IS NOT NULL),
----------------------------------------------------------------
-- Plant tag starting point
----------------------------------------------------------------
plant_tag_result AS (
    SELECT DISTINCT NULL AS parentuuid,0,0,tpt.c_uuid,NULL,tpt.created,0 AS cycleno,
           ps.name,'Plant Tag' AS stage,var.name,NULL,1 AS level
    FROM adempiere.tc_planttag tpt
    JOIN adempiere.tc_plantdetails pd ON pd.planttaguuid = tpt.c_uuid
    JOIN adempiere.tc_plantspecies ps ON ps.tc_plantspecies_id = pd.tc_species_id
    JOIN adempiere.tc_variety var ON var.tc_variety_id = pd.tc_variety_id
    WHERE TRIM(tpt.c_uuid) = TRIM('b451dfaf-f068-4e31-beaf-6fa18e9bbae8')
      AND tpt.ad_client_id = 1000002
),
----------------------------------------------------------------
-- Primary Hardening standalone
----------------------------------------------------------------
primary_result AS (
    SELECT phs.cultureuuid AS parentuuid,ph.tc_in_id,ph.tc_out_id,ph.c_uuid,loc.value,ph.created,0 AS cycleno,
           ps.name,'Primary Hardening' AS stage,var.name,
           ph.personalcode,0 AS level
    FROM adempiere.TC_PrimaryHardeningLabel ph
    JOIN adempiere.tc_primaryHardeningcultureS phs ON phs.TC_PrimaryHardeningLabel_id = ph.TC_PrimaryHardeningLabel_id
    JOIN adempiere.tc_out o ON o.tc_out_id = ph.tc_out_id
    JOIN adempiere.m_locator loc ON loc.m_locator_id = o.m_locator_id
    JOIN adempiere.tc_plantspecies ps ON ps.tc_plantspecies_id = ph.tc_species_id
    JOIN adempiere.tc_variety var ON var.tc_variety_id = ph.tc_variety_id
    WHERE TRIM(ph.c_uuid) = TRIM('b451dfaf-f068-4e31-beaf-6fa18e9bbae8')
      AND ph.ad_client_id = 1000002
)
----------------------------------------------------------------
-- FINAL OUTPUT
----------------------------------------------------------------
SELECT * FROM primary_result 
UNION ALL
SELECT * FROM culture_result
WHERE (parentuuid IS NULL OR parentuuid <> c_uuid)
UNION ALL
SELECT * FROM explant_result WHERE NOT EXISTS (SELECT 1 FROM culture_result)
UNION ALL 
SELECT * FROM plant_tag_result 
WHERE NOT EXISTS (SELECT 1 FROM explant_result) AND NOT EXISTS (SELECT 1 FROM culture_result)
ORDER BY created ASC;
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
=================================================================================
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
Whole flow is working fine:-
WITH RECURSIVE
----------------------------------------------------------------
-- Recursive culture chain
----------------------------------------------------------------
cte AS (
    -- 1. Start from CULTURE UUID
    SELECT cl.parentuuid,cl.tc_in_id,cl.tc_out_id,cl.c_uuid,loc.value AS location,cl.created,
           cl.cycleno,ps.name AS cropType,cs.name AS stage,var.name AS variety,
           cl.personal_code,1 AS level
    FROM adempiere.tc_culturelabel cl
    JOIN adempiere.tc_out o ON o.tc_out_id = cl.tc_out_id
    JOIN adempiere.m_locator loc ON loc.m_locator_id = o.m_locator_id
    JOIN adempiere.tc_plantspecies ps ON ps.tc_plantspecies_id = cl.tc_species_id
    JOIN adempiere.tc_culturestage cs ON cs.tc_culturestage_id = cl.tc_culturestage_id
    JOIN adempiere.tc_variety var ON var.tc_variety_id = cl.tc_variety_id
    WHERE TRIM(cl.c_uuid) = TRIM('9880d5e1-debb-4ac0-b909-daee0b9ec3c0')
      AND cl.ad_client_id = 1000002

    UNION ALL
    -- 2. Primary Hardening → Rooting culture
    SELECT phs.cultureuuid AS parentuuid,cl.tc_in_id,cl.tc_out_id,cl.c_uuid,loc.value AS location,cl.created,
           cl.cycleno,ps.name AS cropType,cs.name AS stage,var.name AS variety,
           cl.personal_code,1 AS level
    FROM adempiere.TC_PrimaryHardeningLabel ph
    JOIN adempiere.tc_primaryHardeningcultureS phs ON phs.TC_PrimaryHardeningLabel_id = ph.TC_PrimaryHardeningLabel_id
    JOIN adempiere.tc_culturelabel cl ON phs.cultureuuid = cl.c_uuid
    JOIN adempiere.tc_out o ON o.tc_out_id = cl.tc_out_id
    JOIN adempiere.m_locator loc ON loc.m_locator_id = o.m_locator_id
    JOIN adempiere.tc_plantspecies ps ON ps.tc_plantspecies_id = cl.tc_species_id
    JOIN adempiere.tc_culturestage cs ON cs.tc_culturestage_id = cl.tc_culturestage_id
    JOIN adempiere.tc_variety var ON var.tc_variety_id = cl.tc_variety_id
    WHERE TRIM(ph.c_uuid) = TRIM('9880d5e1-debb-4ac0-b909-daee0b9ec3c0')
      AND ph.ad_client_id = 1000002

    UNION ALL
    -- 3. Secondary Hardening → Primary Hardening → Culture
    SELECT phs.cultureuuid AS parentuuid,cl.tc_in_id,cl.tc_out_id,cl.c_uuid,loc.value AS location,cl.created,
           cl.cycleno,ps.name AS cropType,cs.name AS stage,var.name AS variety,
           cl.personal_code,1 AS level
    FROM adempiere.TC_SecondaryHardeningLabel sh
    JOIN adempiere.TC_PrimaryHardeningLabel ph ON sh.parentuuid = ph.c_uuid
    JOIN adempiere.tc_primaryHardeningcultureS phs ON phs.TC_PrimaryHardeningLabel_id = ph.TC_PrimaryHardeningLabel_id
    JOIN adempiere.tc_culturelabel cl ON phs.cultureuuid = cl.c_uuid
    JOIN adempiere.tc_out o ON o.tc_out_id = cl.tc_out_id
    JOIN adempiere.m_locator loc ON loc.m_locator_id = o.m_locator_id
    JOIN adempiere.tc_plantspecies ps ON ps.tc_plantspecies_id = cl.tc_species_id
    JOIN adempiere.tc_culturestage cs ON cs.tc_culturestage_id = cl.tc_culturestage_id
    JOIN adempiere.tc_variety var ON var.tc_variety_id = cl.tc_variety_id
    WHERE TRIM(sh.c_uuid) = TRIM('9880d5e1-debb-4ac0-b909-daee0b9ec3c0')
      AND sh.ad_client_id = 1000002

    UNION ALL
    -- 4. Recursive step: culture → parent culture
    SELECT cl2.parentuuid,cl2.tc_in_id,cl2.tc_out_id,cl2.c_uuid,loc.value AS location,cl2.created,
           cl2.cycleno,ps.name AS cropType,cs.name AS stage,var.name AS variety,
           cl2.personal_code,cte.level + 1 AS level
    FROM cte
    JOIN adempiere.tc_culturelabel cl2 ON cte.parentuuid = cl2.c_uuid
    JOIN adempiere.tc_out o ON o.tc_out_id = cl2.tc_out_id
    JOIN adempiere.m_locator loc ON loc.m_locator_id = o.m_locator_id
    JOIN adempiere.tc_plantspecies ps ON ps.tc_plantspecies_id = cl2.tc_species_id
    JOIN adempiere.tc_culturestage cs ON cs.tc_culturestage_id = cl2.tc_culturestage_id
    JOIN adempiere.tc_variety var ON var.tc_variety_id = cl2.tc_variety_id
),
----------------------------------------------------------------
-- Culture stage aggregation
----------------------------------------------------------------
culture_result AS (
    SELECT cte.parentuuid,cte.tc_in_id,cte.tc_out_id,cte.c_uuid,cte.location,cte.created,cte.cycleno,
           cte.cropType,cte.stage,cte.variety,cte.personal_code,cte.level AS level
    FROM cte
    GROUP BY cte.parentuuid, cte.tc_in_id, cte.tc_out_id, cte.c_uuid,cte.location,
             cte.created, cte.cycleno, cte.cropType, cte.stage, cte.variety,
             cte.personal_code, cte.level

    UNION ALL
    -- Explant from culture
    SELECT DISTINCT tcc.parentuuid,tcc.tc_in_id,tcc.tc_out_id,tcc.c_uuid,loc.value AS location,tcc.created,0 AS cycleno,
           cte.cropType,pr.name AS stage,cte.variety,tcc.personalcode AS personal_code,cte.level AS level
    FROM cte
    LEFT JOIN adempiere.tc_explantlabel tcc ON cte.parentuuid = tcc.c_uuid
    JOIN adempiere.tc_out eo ON eo.tc_out_id = tcc.tc_out_id
    JOIN adempiere.m_locator loc ON loc.m_locator_id = eo.m_locator_id
    JOIN adempiere.m_product pr ON pr.m_product_id = eo.m_product_id

    UNION ALL
    -- Plant tag from explant
    SELECT DISTINCT NULL,0,0,tpt.c_uuid,NULL,tpt.created,0 AS cycleno,
           cte.cropType,'Plant Tag' AS stage,cte.variety,NULL,cte.level AS level
    FROM cte
    LEFT JOIN adempiere.tc_explantlabel tcc ON cte.parentuuid = tcc.c_uuid
    LEFT JOIN adempiere.tc_planttag tpt ON tcc.parentuuid = tpt.c_uuid
    WHERE tpt.c_uuid IS NOT NULL
),
----------------------------------------------------------------
-- Explant starting point
----------------------------------------------------------------
explant_result AS (
    SELECT DISTINCT tcc.parentuuid AS parentuuid,tcc.tc_in_id,tcc.tc_out_id,tcc.c_uuid,loc.value AS location,tcc.created,0 AS cycleno,
           ps.name,pr.name  AS stage,var.name,tcc.personalcode,1 AS level
    FROM adempiere.tc_explantlabel tcc
    JOIN adempiere.tc_out eo ON eo.tc_out_id = tcc.tc_out_id
    JOIN adempiere.m_locator loc ON loc.m_locator_id = eo.m_locator_id
    JOIN adempiere.tc_plantspecies ps ON ps.tc_plantspecies_id = tcc.tc_species_id
    JOIN adempiere.tc_variety var ON var.tc_variety_id = tcc.tc_variety_id
    JOIN adempiere.m_product pr ON pr.m_product_id = eo.m_product_id
    WHERE TRIM(tcc.c_uuid) = TRIM('9880d5e1-debb-4ac0-b909-daee0b9ec3c0')
      AND tcc.ad_client_id = 1000002

    UNION ALL
    SELECT DISTINCT NULL AS parentuuid,0,0,tpt.c_uuid,NULL,tpt.created,0 AS cycleno,
           ps.name,'Plant Tag' AS stage,var.name,NULL,2 AS level
    FROM adempiere.tc_planttag tpt
    JOIN adempiere.tc_explantlabel tcc ON tcc.parentuuid = tpt.c_uuid
    JOIN adempiere.tc_plantdetails pd ON pd.planttaguuid = tpt.c_uuid
    JOIN adempiere.tc_plantspecies ps ON ps.tc_plantspecies_id = pd.tc_species_id
    JOIN adempiere.tc_variety var ON var.tc_variety_id = pd.tc_variety_id
    WHERE TRIM(tcc.c_uuid) = TRIM('9880d5e1-debb-4ac0-b909-daee0b9ec3c0')
      AND tpt.c_uuid IS NOT NULL
),
----------------------------------------------------------------
-- Plant tag starting point
----------------------------------------------------------------
plant_tag_result AS (
    SELECT DISTINCT NULL AS parentuuid,0,0,tpt.c_uuid,NULL,tpt.created,0 AS cycleno,
           ps.name,'Plant Tag' AS stage,var.name,NULL,1 AS level
    FROM adempiere.tc_planttag tpt
    JOIN adempiere.tc_plantdetails pd ON pd.planttaguuid = tpt.c_uuid
    JOIN adempiere.tc_plantspecies ps ON ps.tc_plantspecies_id = pd.tc_species_id
    JOIN adempiere.tc_variety var ON var.tc_variety_id = pd.tc_variety_id
    WHERE TRIM(tpt.c_uuid) = TRIM('9880d5e1-debb-4ac0-b909-daee0b9ec3c0')
      AND tpt.ad_client_id = 1000002
),
----------------------------------------------------------------
-- Primary Hardening standalone
----------------------------------------------------------------
primary_result AS (
    SELECT phs.cultureuuid AS parentuuid,ph.tc_in_id,ph.tc_out_id,ph.c_uuid,loc.value,ph.created,0 AS cycleno,
           ps.name,'Primary Hardening' AS stage,var.name,
           ph.personalcode,0 AS level
    FROM adempiere.TC_PrimaryHardeningLabel ph
    JOIN adempiere.tc_primaryHardeningcultureS phs ON phs.TC_PrimaryHardeningLabel_id = ph.TC_PrimaryHardeningLabel_id
    JOIN adempiere.tc_out o ON o.tc_out_id = ph.tc_out_id
    JOIN adempiere.m_locator loc ON loc.m_locator_id = o.m_locator_id
    JOIN adempiere.tc_plantspecies ps ON ps.tc_plantspecies_id = ph.tc_species_id
    JOIN adempiere.tc_variety var ON var.tc_variety_id = ph.tc_variety_id
    WHERE TRIM(ph.c_uuid) = TRIM('9880d5e1-debb-4ac0-b909-daee0b9ec3c0')
      AND ph.ad_client_id = 1000002
),
----------------------------------------------------------------
-- Secondary Hardening standalone and linked to Primary
----------------------------------------------------------------
secondary_result AS (
    -- Secondary Hardening record itself
    SELECT sh.parentuuid,sh.tc_in_id,sh.tc_out_id,sh.c_uuid,loc.value AS location,sh.created,0 AS cycleno,
           ps.name,'Secondary Hardening' AS stage,var.name,
           sh.personalcode,0 AS level
    FROM adempiere.TC_SecondaryHardeningLabel sh
    JOIN adempiere.tc_out o ON o.tc_out_id = sh.tc_out_id
    JOIN adempiere.m_locator loc ON loc.m_locator_id = o.m_locator_id
    JOIN adempiere.tc_plantspecies ps ON ps.tc_plantspecies_id = sh.tc_species_id
    JOIN adempiere.tc_variety var ON var.tc_variety_id = sh.tc_variety_id
    WHERE TRIM(sh.c_uuid) = TRIM('9880d5e1-debb-4ac0-b909-daee0b9ec3c0')
      AND sh.ad_client_id = 1000002

    UNION ALL
    -- Linked Primary Hardening record
    SELECT phs.cultureuuid AS parentuuid,ph.tc_in_id,ph.tc_out_id,ph.c_uuid,loc.value AS location,ph.created,0 AS cycleno,
           ps.name,'Primary Hardening' AS stage,var.name,
           ph.personalcode,1 AS level
    FROM adempiere.TC_SecondaryHardeningLabel sh
    JOIN adempiere.TC_PrimaryHardeningLabel ph ON sh.parentuuid = ph.c_uuid
    JOIN adempiere.tc_primaryHardeningcultureS phs ON phs.TC_PrimaryHardeningLabel_id = ph.TC_PrimaryHardeningLabel_id
    JOIN adempiere.tc_out o ON o.tc_out_id = ph.tc_out_id
    JOIN adempiere.m_locator loc ON loc.m_locator_id = o.m_locator_id
    JOIN adempiere.tc_plantspecies ps ON ps.tc_plantspecies_id = ph.tc_species_id
    JOIN adempiere.tc_variety var ON var.tc_variety_id = ph.tc_variety_id
    WHERE TRIM(sh.c_uuid) = TRIM('9880d5e1-debb-4ac0-b909-daee0b9ec3c0')
      AND sh.ad_client_id = 1000002
)
----------------------------------------------------------------
-- FINAL OUTPUT
----------------------------------------------------------------
SELECT * FROM secondary_result
UNION ALL
SELECT * FROM primary_result 
UNION ALL
SELECT * FROM culture_result
WHERE (parentuuid IS NULL OR parentuuid <> c_uuid)
UNION ALL
SELECT * FROM explant_result WHERE NOT EXISTS (SELECT 1 FROM culture_result)
UNION ALL 
SELECT * FROM plant_tag_result 
WHERE NOT EXISTS (SELECT 1 FROM explant_result) AND NOT EXISTS (SELECT 1 FROM culture_result)
ORDER BY created ASC;

+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
=================================================================================
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
Unnecessary space and line removed:-
WITH RECURSIVE
cte AS ( -- 1. Start from CULTURE UUID
SELECT cl.parentuuid,cl.tc_in_id,cl.tc_out_id,cl.c_uuid,loc.value AS location,cl.created,
cl.cycleno,ps.name AS cropType,cs.name AS stage,var.name AS variety,cl.personal_code,1 AS level
FROM adempiere.tc_culturelabel cl JOIN adempiere.tc_out o ON o.tc_out_id = cl.tc_out_id
JOIN adempiere.m_locator loc ON loc.m_locator_id = o.m_locator_id
JOIN adempiere.tc_plantspecies ps ON ps.tc_plantspecies_id = cl.tc_species_id
JOIN adempiere.tc_culturestage cs ON cs.tc_culturestage_id = cl.tc_culturestage_id
JOIN adempiere.tc_variety var ON var.tc_variety_id = cl.tc_variety_id
WHERE TRIM(cl.c_uuid) = TRIM('9880d5e1-debb-4ac0-b909-daee0b9ec3c0') AND cl.ad_client_id = 1000002
UNION ALL -- 2. Primary Hardening → Rooting culture
SELECT phs.cultureuuid AS parentuuid,cl.tc_in_id,cl.tc_out_id,cl.c_uuid,loc.value AS location,cl.created,
cl.cycleno,ps.name AS cropType,cs.name AS stage,var.name AS variety,cl.personal_code,1 AS level
FROM adempiere.TC_PrimaryHardeningLabel ph
JOIN adempiere.tc_primaryHardeningcultureS phs ON phs.TC_PrimaryHardeningLabel_id = ph.TC_PrimaryHardeningLabel_id
JOIN adempiere.tc_culturelabel cl ON phs.cultureuuid = cl.c_uuid JOIN adempiere.tc_out o ON o.tc_out_id = cl.tc_out_id
JOIN adempiere.m_locator loc ON loc.m_locator_id = o.m_locator_id JOIN adempiere.tc_plantspecies ps ON ps.tc_plantspecies_id = cl.tc_species_id
JOIN adempiere.tc_culturestage cs ON cs.tc_culturestage_id = cl.tc_culturestage_id JOIN adempiere.tc_variety var ON var.tc_variety_id = cl.tc_variety_id
WHERE TRIM(ph.c_uuid) = TRIM('9880d5e1-debb-4ac0-b909-daee0b9ec3c0') AND ph.ad_client_id = 1000002
UNION ALL -- 3. Secondary Hardening → Primary Hardening → Culture
SELECT phs.cultureuuid AS parentuuid,cl.tc_in_id,cl.tc_out_id,cl.c_uuid,loc.value AS location,cl.created,
cl.cycleno,ps.name AS cropType,cs.name AS stage,var.name AS variety,cl.personal_code,1 AS level
FROM adempiere.TC_SecondaryHardeningLabel sh JOIN adempiere.TC_PrimaryHardeningLabel ph ON sh.parentuuid = ph.c_uuid
JOIN adempiere.tc_primaryHardeningcultureS phs ON phs.TC_PrimaryHardeningLabel_id = ph.TC_PrimaryHardeningLabel_id
JOIN adempiere.tc_culturelabel cl ON phs.cultureuuid = cl.c_uuid JOIN adempiere.tc_out o ON o.tc_out_id = cl.tc_out_id
JOIN adempiere.m_locator loc ON loc.m_locator_id = o.m_locator_id JOIN adempiere.tc_plantspecies ps ON ps.tc_plantspecies_id = cl.tc_species_id
JOIN adempiere.tc_culturestage cs ON cs.tc_culturestage_id = cl.tc_culturestage_id JOIN adempiere.tc_variety var ON var.tc_variety_id = cl.tc_variety_id
WHERE TRIM(sh.c_uuid) = TRIM('9880d5e1-debb-4ac0-b909-daee0b9ec3c0') AND sh.ad_client_id = 1000002
UNION ALL -- 4. Recursive step: culture → parent culture
SELECT cl2.parentuuid,cl2.tc_in_id,cl2.tc_out_id,cl2.c_uuid,loc.value AS location,cl2.created,
cl2.cycleno,ps.name AS cropType,cs.name AS stage,var.name AS variety,cl2.personal_code,cte.level + 1 AS level
FROM cte JOIN adempiere.tc_culturelabel cl2 ON cte.parentuuid = cl2.c_uuid
JOIN adempiere.tc_out o ON o.tc_out_id = cl2.tc_out_id JOIN adempiere.m_locator loc ON loc.m_locator_id = o.m_locator_id
JOIN adempiere.tc_plantspecies ps ON ps.tc_plantspecies_id = cl2.tc_species_id JOIN adempiere.tc_culturestage cs ON cs.tc_culturestage_id = cl2.tc_culturestage_id
JOIN adempiere.tc_variety var ON var.tc_variety_id = cl2.tc_variety_id
),
----------------------------------------------------------------
-- Culture stage aggregation
----------------------------------------------------------------
culture_result AS (
SELECT cte.parentuuid,cte.tc_in_id,cte.tc_out_id,cte.c_uuid,cte.location,cte.created,cte.cycleno,
cte.cropType,cte.stage,cte.variety,cte.personal_code,cte.level AS level FROM cte
GROUP BY cte.parentuuid, cte.tc_in_id, cte.tc_out_id, cte.c_uuid,cte.location,
cte.created, cte.cycleno, cte.cropType, cte.stage, cte.variety,cte.personal_code, cte.level
UNION ALL
-- Explant from culture
SELECT DISTINCT tcc.parentuuid,tcc.tc_in_id,tcc.tc_out_id,tcc.c_uuid,loc.value AS location,tcc.created,0 AS cycleno,
cte.cropType,pr.name AS stage,cte.variety,tcc.personalcode AS personal_code,cte.level AS level FROM cte
LEFT JOIN adempiere.tc_explantlabel tcc ON cte.parentuuid = tcc.c_uuid JOIN adempiere.tc_out eo ON eo.tc_out_id = tcc.tc_out_id
JOIN adempiere.m_locator loc ON loc.m_locator_id = eo.m_locator_id JOIN adempiere.m_product pr ON pr.m_product_id = eo.m_product_id
UNION ALL
 -- Plant tag from explant
SELECT DISTINCT NULL,0,0,tpt.c_uuid,NULL,tpt.created,0 AS cycleno,cte.cropType,'Plant Tag' AS stage,cte.variety,NULL,cte.level AS level
FROM cte LEFT JOIN adempiere.tc_explantlabel tcc ON cte.parentuuid = tcc.c_uuid
LEFT JOIN adempiere.tc_planttag tpt ON tcc.parentuuid = tpt.c_uuid WHERE tpt.c_uuid IS NOT NULL
),
----------------------------------------------------------------
-- Explant starting point
----------------------------------------------------------------
explant_result AS (
SELECT DISTINCT tcc.parentuuid AS parentuuid,tcc.tc_in_id,tcc.tc_out_id,tcc.c_uuid,loc.value AS location,tcc.created,0 AS cycleno,
ps.name,pr.name  AS stage,var.name,tcc.personalcode,1 AS level FROM adempiere.tc_explantlabel tcc
JOIN adempiere.tc_out eo ON eo.tc_out_id = tcc.tc_out_id JOIN adempiere.m_locator loc ON loc.m_locator_id = eo.m_locator_id
JOIN adempiere.tc_plantspecies ps ON ps.tc_plantspecies_id = tcc.tc_species_id JOIN adempiere.tc_variety var ON var.tc_variety_id = tcc.tc_variety_id
JOIN adempiere.m_product pr ON pr.m_product_id = eo.m_product_id 
WHERE TRIM(tcc.c_uuid) = TRIM('9880d5e1-debb-4ac0-b909-daee0b9ec3c0') AND tcc.ad_client_id = 1000002
UNION ALL
SELECT DISTINCT NULL AS parentuuid,0,0,tpt.c_uuid,NULL,tpt.created,0 AS cycleno,ps.name,'Plant Tag' AS stage,var.name,NULL,2 AS level
FROM adempiere.tc_planttag tpt JOIN adempiere.tc_explantlabel tcc ON tcc.parentuuid = tpt.c_uuid
JOIN adempiere.tc_plantdetails pd ON pd.planttaguuid = tpt.c_uuid JOIN adempiere.tc_plantspecies ps ON ps.tc_plantspecies_id = pd.tc_species_id
JOIN adempiere.tc_variety var ON var.tc_variety_id = pd.tc_variety_id
WHERE TRIM(tcc.c_uuid) = TRIM('9880d5e1-debb-4ac0-b909-daee0b9ec3c0') AND tpt.c_uuid IS NOT NULL
),
----------------------------------------------------------------
-- Plant tag starting point
----------------------------------------------------------------
plant_tag_result AS (
SELECT DISTINCT NULL AS parentuuid,0,0,tpt.c_uuid,NULL,tpt.created,0 AS cycleno,ps.name,'Plant Tag' AS stage,var.name,NULL,1 AS level
FROM adempiere.tc_planttag tpt JOIN adempiere.tc_plantdetails pd ON pd.planttaguuid = tpt.c_uuid
JOIN adempiere.tc_plantspecies ps ON ps.tc_plantspecies_id = pd.tc_species_id JOIN adempiere.tc_variety var ON var.tc_variety_id = pd.tc_variety_id
WHERE TRIM(tpt.c_uuid) = TRIM('9880d5e1-debb-4ac0-b909-daee0b9ec3c0') AND tpt.ad_client_id = 1000002
),
----------------------------------------------------------------
-- Primary Hardening standalone
----------------------------------------------------------------
primary_result AS (
SELECT phs.cultureuuid AS parentuuid,ph.tc_in_id,ph.tc_out_id,ph.c_uuid,loc.value,ph.created,0 AS cycleno,
ps.name,'Primary Hardening' AS stage,var.name,ph.personalcode,0 AS level
FROM adempiere.TC_PrimaryHardeningLabel ph JOIN adempiere.tc_primaryHardeningcultureS phs ON phs.TC_PrimaryHardeningLabel_id = ph.TC_PrimaryHardeningLabel_id
JOIN adempiere.tc_out o ON o.tc_out_id = ph.tc_out_id JOIN adempiere.m_locator loc ON loc.m_locator_id = o.m_locator_id
JOIN adempiere.tc_plantspecies ps ON ps.tc_plantspecies_id = ph.tc_species_id JOIN adempiere.tc_variety var ON var.tc_variety_id = ph.tc_variety_id
WHERE TRIM(ph.c_uuid) = TRIM('9880d5e1-debb-4ac0-b909-daee0b9ec3c0') AND ph.ad_client_id = 1000002
),
----------------------------------------------------------------
-- Secondary Hardening standalone and linked to Primary
----------------------------------------------------------------
secondary_result AS (-- Secondary Hardening record itself
SELECT sh.parentuuid,sh.tc_in_id,sh.tc_out_id,sh.c_uuid,loc.value AS location,sh.created,0 AS cycleno,
ps.name,'Secondary Hardening' AS stage,var.name,sh.personalcode,0 AS level
FROM adempiere.TC_SecondaryHardeningLabel sh JOIN adempiere.tc_out o ON o.tc_out_id = sh.tc_out_id
JOIN adempiere.m_locator loc ON loc.m_locator_id = o.m_locator_id JOIN adempiere.tc_plantspecies ps ON ps.tc_plantspecies_id = sh.tc_species_id
JOIN adempiere.tc_variety var ON var.tc_variety_id = sh.tc_variety_id
WHERE TRIM(sh.c_uuid) = TRIM('9880d5e1-debb-4ac0-b909-daee0b9ec3c0') AND sh.ad_client_id = 1000002
UNION ALL -- Linked Primary Hardening record
SELECT phs.cultureuuid AS parentuuid,ph.tc_in_id,ph.tc_out_id,ph.c_uuid,loc.value AS location,ph.created,0 AS cycleno,
ps.name,'Primary Hardening' AS stage,var.name,ph.personalcode,1 AS level
FROM adempiere.TC_SecondaryHardeningLabel sh JOIN adempiere.TC_PrimaryHardeningLabel ph ON sh.parentuuid = ph.c_uuid
JOIN adempiere.tc_primaryHardeningcultureS phs ON phs.TC_PrimaryHardeningLabel_id = ph.TC_PrimaryHardeningLabel_id
JOIN adempiere.tc_out o ON o.tc_out_id = ph.tc_out_id JOIN adempiere.m_locator loc ON loc.m_locator_id = o.m_locator_id
JOIN adempiere.tc_plantspecies ps ON ps.tc_plantspecies_id = ph.tc_species_id JOIN adempiere.tc_variety var ON var.tc_variety_id = ph.tc_variety_id
WHERE TRIM(sh.c_uuid) = TRIM('9880d5e1-debb-4ac0-b909-daee0b9ec3c0') AND sh.ad_client_id = 1000002
)
----------------------------------------------------------------
-- FINAL OUTPUT
----------------------------------------------------------------
SELECT * FROM secondary_result
UNION ALL
SELECT * FROM primary_result 
UNION ALL
SELECT * FROM culture_result
WHERE (parentuuid IS NULL OR parentuuid <> c_uuid)
UNION ALL
SELECT * FROM explant_result WHERE NOT EXISTS (SELECT 1 FROM culture_result)
UNION ALL 
SELECT * FROM plant_tag_result 
WHERE NOT EXISTS (SELECT 1 FROM explant_result) AND NOT EXISTS (SELECT 1 FROM culture_result)
ORDER BY created ASC;

********************************************************************************
********************************************************************************
********************************************************************************
Jasper Report Working Tracebility Report:-
WITH RECURSIVE
----------------------------------------------------------------
-- Recursive culture chain
----------------------------------------------------------------
cte AS (
    -- 1. Start from CULTURE UUID
    SELECT cl.parentuuid,cl.tc_in_id,cl.tc_out_id,cl.c_uuid,loc.value AS location,cl.created,
           cl.cycleno,ps.name AS cropType,cs.name AS stage,var.name AS variety,
           cl.personal_code,1 AS level,u.name As user,
           'culture' as source_type
    FROM adempiere.tc_culturelabel cl
    JOIN adempiere.tc_out o ON o.tc_out_id = cl.tc_out_id
    JOIN adempiere.m_locator loc ON loc.m_locator_id = o.m_locator_id
    JOIN adempiere.tc_plantspecies ps ON ps.tc_plantspecies_id = cl.tc_species_id
    JOIN adempiere.tc_culturestage cs ON cs.tc_culturestage_id = cl.tc_culturestage_id
    JOIN adempiere.tc_variety var ON var.tc_variety_id = cl.tc_variety_id
    JOIN adempiere.ad_user u ON u.ad_user_id = cl.createdby
    WHERE TRIM(cl.c_uuid) = TRIM( $P{CultureLabelUUId} )
      AND cl.ad_client_id =  $P{AD_CLIENT_ID} 

    UNION ALL
    -- 2. Primary Hardening → Rooting culture
    SELECT phs.cultureuuid AS parentuuid,cl.tc_in_id,cl.tc_out_id,cl.c_uuid,loc.value AS location,cl.created,
           cl.cycleno,ps.name AS cropType,cs.name AS stage,var.name AS variety,
           cl.personal_code,2 AS level,u.name As user,  -- Culture becomes level 2 when coming from Primary
           'culture' as source_type
    FROM adempiere.TC_PrimaryHardeningLabel ph
    JOIN adempiere.tc_primaryHardeningcultureS phs ON phs.TC_PrimaryHardeningLabel_id = ph.TC_PrimaryHardeningLabel_id
    JOIN adempiere.tc_culturelabel cl ON phs.cultureuuid = cl.c_uuid
    JOIN adempiere.tc_out o ON o.tc_out_id = cl.tc_out_id
    JOIN adempiere.m_locator loc ON loc.m_locator_id = o.m_locator_id
    JOIN adempiere.tc_plantspecies ps ON ps.tc_plantspecies_id = cl.tc_species_id
    JOIN adempiere.tc_culturestage cs ON cs.tc_culturestage_id = cl.tc_culturestage_id
    JOIN adempiere.tc_variety var ON var.tc_variety_id = cl.tc_variety_id
    JOIN adempiere.ad_user u ON u.ad_user_id = cl.createdby
    WHERE TRIM(ph.c_uuid) = TRIM( $P{CultureLabelUUId} )
      AND ph.ad_client_id =  $P{AD_CLIENT_ID} 

    UNION ALL
    -- 3. Secondary Hardening → Primary Hardening → Culture
    SELECT phs.cultureuuid AS parentuuid,cl.tc_in_id,cl.tc_out_id,cl.c_uuid,loc.value AS location,cl.created,
           cl.cycleno,ps.name AS cropType,cs.name AS stage,var.name AS variety,
           cl.personal_code,3 AS level,u.name As user,  -- Culture becomes level 3 when coming from Secondary
           'culture' as source_type
    FROM adempiere.TC_SecondaryHardeningLabel sh
    JOIN adempiere.TC_PrimaryHardeningLabel ph ON sh.parentuuid = ph.c_uuid
    JOIN adempiere.tc_primaryHardeningcultureS phs ON phs.TC_PrimaryHardeningLabel_id = ph.TC_PrimaryHardeningLabel_id
    JOIN adempiere.tc_culturelabel cl ON phs.cultureuuid = cl.c_uuid
    JOIN adempiere.tc_out o ON o.tc_out_id = cl.tc_out_id
    JOIN adempiere.m_locator loc ON loc.m_locator_id = o.m_locator_id
    JOIN adempiere.tc_plantspecies ps ON ps.tc_plantspecies_id = cl.tc_species_id
    JOIN adempiere.tc_culturestage cs ON cs.tc_culturestage_id = cl.tc_culturestage_id
    JOIN adempiere.tc_variety var ON var.tc_variety_id = cl.tc_variety_id
    JOIN adempiere.ad_user u ON u.ad_user_id = cl.createdby
    WHERE TRIM(sh.c_uuid) = TRIM( $P{CultureLabelUUId} )
      AND sh.ad_client_id =  $P{AD_CLIENT_ID} 

    UNION ALL
    -- 4. Recursive step: culture → parent culture
    SELECT cl2.parentuuid,cl2.tc_in_id,cl2.tc_out_id,cl2.c_uuid,loc.value AS location,cl2.created,
           cl2.cycleno,ps.name AS cropType,cs.name AS stage,var.name AS variety,
           cl2.personal_code,cte.level + 1 AS level,u.name As user,
           'culture' as source_type
    FROM cte
    JOIN adempiere.tc_culturelabel cl2 ON cte.parentuuid = cl2.c_uuid
    JOIN adempiere.tc_out o ON o.tc_out_id = cl2.tc_out_id
    JOIN adempiere.m_locator loc ON loc.m_locator_id = o.m_locator_id
    JOIN adempiere.tc_plantspecies ps ON ps.tc_plantspecies_id = cl2.tc_species_id
    JOIN adempiere.tc_culturestage cs ON cs.tc_culturestage_id = cl2.tc_culturestage_id
    JOIN adempiere.tc_variety var ON var.tc_variety_id = cl2.tc_variety_id
    JOIN adempiere.ad_user u ON u.ad_user_id = cl2.createdby
),
----------------------------------------------------------------
-- Culture stage aggregation
----------------------------------------------------------------
culture_result AS (
    SELECT cte.parentuuid,cte.tc_in_id,cte.tc_out_id,cte.c_uuid,cte.location,cte.created,cte.cycleno,
           cte.cropType,cte.stage,cte.variety,cte.personal_code,cte.level AS level,cte.user,
           cte.source_type
    FROM cte
    GROUP BY cte.parentuuid, cte.tc_in_id, cte.tc_out_id, cte.c_uuid,cte.location,
             cte.created, cte.cycleno, cte.cropType, cte.stage, cte.variety,
             cte.personal_code, cte.level,cte.user, cte.source_type

    UNION ALL
    -- Explant from culture
    SELECT DISTINCT tcc.parentuuid,tcc.tc_in_id,tcc.tc_out_id,tcc.c_uuid,loc.value AS location,tcc.created,0 AS cycleno,
           cte.cropType,pr.name AS stage,cte.variety,tcc.personalcode AS personal_code,
           cte.level + 1 AS level,u.name As user,  -- Explant is always one level below culture
           'explant' as source_type
    FROM cte
    LEFT JOIN adempiere.tc_explantlabel tcc ON cte.parentuuid = tcc.c_uuid
    JOIN adempiere.tc_out eo ON eo.tc_out_id = tcc.tc_out_id
    JOIN adempiere.m_locator loc ON loc.m_locator_id = eo.m_locator_id
    JOIN adempiere.m_product pr ON pr.m_product_id = eo.m_product_id
    JOIN adempiere.ad_user u ON u.ad_user_id = tcc.createdby

    UNION ALL
    -- Plant tag from explant
    SELECT DISTINCT NULL,0,0,tpt.c_uuid,NULL,tpt.created,0 AS cycleno,
           cte.cropType,'Plant Tag' AS stage,cte.variety,NULL,
           cte.level + 2 AS level,u.name As user,  -- Plant tag is two levels below culture
           'plant_tag' as source_type
    FROM cte
    LEFT JOIN adempiere.tc_explantlabel tcc ON cte.parentuuid = tcc.c_uuid
    LEFT JOIN adempiere.tc_planttag tpt ON tcc.parentuuid = tpt.c_uuid
    LEFT JOIN adempiere.ad_user u ON u.ad_user_id = tpt.createdby
    WHERE tpt.c_uuid IS NOT NULL
),
----------------------------------------------------------------
-- Explant starting point
----------------------------------------------------------------
explant_result AS (
    SELECT DISTINCT tcc.parentuuid AS parentuuid,tcc.tc_in_id,tcc.tc_out_id,tcc.c_uuid,loc.value AS location,tcc.created,0 AS cycleno,
           ps.name AS cropType,pr.name AS stage,var.name AS variety,tcc.personalcode,1 AS level,u.name As user,
           'explant' as source_type
    FROM adempiere.tc_explantlabel tcc
    JOIN adempiere.tc_out eo ON eo.tc_out_id = tcc.tc_out_id
    JOIN adempiere.m_locator loc ON loc.m_locator_id = eo.m_locator_id
    JOIN adempiere.tc_plantspecies ps ON ps.tc_plantspecies_id = tcc.tc_species_id
    JOIN adempiere.tc_variety var ON var.tc_variety_id = tcc.tc_variety_id
    JOIN adempiere.m_product pr ON pr.m_product_id = eo.m_product_id
    JOIN adempiere.ad_user u ON u.ad_user_id = tcc.createdby
    WHERE TRIM(tcc.c_uuid) = TRIM( $P{CultureLabelUUId} )
      AND tcc.ad_client_id =  $P{AD_CLIENT_ID} 

    UNION ALL
    SELECT DISTINCT NULL AS parentuuid,0,0,tpt.c_uuid,NULL,tpt.created,0 AS cycleno,
           ps.name AS cropType,'Plant Tag' AS stage,var.name AS variety,NULL,2 AS level,u.name As user,
           'plant_tag' as source_type
    FROM adempiere.tc_planttag tpt
    JOIN adempiere.tc_explantlabel tcc ON tcc.parentuuid = tpt.c_uuid
    JOIN adempiere.tc_plantdetails pd ON pd.planttaguuid = tpt.c_uuid
    JOIN adempiere.tc_plantspecies ps ON ps.tc_plantspecies_id = pd.tc_species_id
    JOIN adempiere.tc_variety var ON var.tc_variety_id = pd.tc_variety_id
    JOIN adempiere.ad_user u ON u.ad_user_id = tpt.createdby
    WHERE TRIM(tcc.c_uuid) = TRIM( $P{CultureLabelUUId} )
      AND tpt.c_uuid IS NOT NULL
),
----------------------------------------------------------------
-- Plant tag starting point
----------------------------------------------------------------
plant_tag_result AS (
    SELECT DISTINCT NULL AS parentuuid,0,0,tpt.c_uuid,NULL,tpt.created,0 AS cycleno,
           ps.name AS cropType,'Plant Tag' AS stage,var.name AS variety,NULL,1 AS level,u.name As user,
           'plant_tag' as source_type
    FROM adempiere.tc_planttag tpt
    JOIN adempiere.tc_plantdetails pd ON pd.planttaguuid = tpt.c_uuid
    JOIN adempiere.tc_plantspecies ps ON ps.tc_plantspecies_id = pd.tc_species_id
    JOIN adempiere.tc_variety var ON var.tc_variety_id = pd.tc_variety_id
    JOIN adempiere.ad_user u ON u.ad_user_id = tpt.createdby
    WHERE TRIM(tpt.c_uuid) = TRIM( $P{CultureLabelUUId} )
      AND tpt.ad_client_id =  $P{AD_CLIENT_ID} 
),
----------------------------------------------------------------
-- Primary Hardening standalone
----------------------------------------------------------------
primary_result AS (
    SELECT phs.cultureuuid AS parentuuid,ph.tc_in_id,ph.tc_out_id,ph.c_uuid,loc.value,ph.created,0 AS cycleno,
           ps.name AS cropType,'Primary Hardening' AS stage,var.name AS variety,
           u.personalcode,1 AS level,u.name As user,  -- Primary Hardening as level 1
           'primary' as source_type
    FROM adempiere.TC_PrimaryHardeningLabel ph
    JOIN adempiere.tc_primaryHardeningcultureS phs ON phs.TC_PrimaryHardeningLabel_id = ph.TC_PrimaryHardeningLabel_id
    JOIN adempiere.tc_out o ON o.tc_out_id = ph.tc_out_id
    JOIN adempiere.m_locator loc ON loc.m_locator_id = o.m_locator_id
    JOIN adempiere.tc_plantspecies ps ON ps.tc_plantspecies_id = ph.tc_species_id
    JOIN adempiere.tc_variety var ON var.tc_variety_id = ph.tc_variety_id
    JOIN adempiere.ad_user u ON u.ad_user_id = ph.createdby
    WHERE TRIM(ph.c_uuid) = TRIM( $P{CultureLabelUUId} )
      AND ph.ad_client_id =  $P{AD_CLIENT_ID} 
),
----------------------------------------------------------------
-- Secondary Hardening standalone and linked to Primary
----------------------------------------------------------------
secondary_result AS (
    -- Secondary Hardening record itself
    SELECT sh.parentuuid,sh.tc_in_id,sh.tc_out_id,sh.c_uuid,loc.value AS location,sh.created,0 AS cycleno,
           ps.name AS cropType,'Secondary Hardening' AS stage,var.name AS variety,
           u.personalcode,1 AS level,u.name As user,  -- Secondary Hardening as level 1
           'secondary' as source_type
    FROM adempiere.TC_SecondaryHardeningLabel sh
    JOIN adempiere.tc_out o ON o.tc_out_id = sh.tc_out_id
    JOIN adempiere.m_locator loc ON loc.m_locator_id = o.m_locator_id
    JOIN adempiere.tc_plantspecies ps ON ps.tc_plantspecies_id = sh.tc_species_id
    JOIN adempiere.tc_variety var ON var.tc_variety_id = sh.tc_variety_id
    JOIN adempiere.ad_user u ON u.ad_user_id = sh.createdby
    WHERE TRIM(sh.c_uuid) = TRIM( $P{CultureLabelUUId} )
      AND sh.ad_client_id =  $P{AD_CLIENT_ID} 

    UNION ALL
    -- Linked Primary Hardening record
    SELECT phs.cultureuuid AS parentuuid,ph.tc_in_id,ph.tc_out_id,ph.c_uuid,loc.value AS location,ph.created,0 AS cycleno,
           ps.name AS cropType,'Primary Hardening' AS stage,var.name AS variety,
           u.personalcode,2 AS level,u.name As user,  -- Primary becomes level 2 when linked from Secondary
           'primary' as source_type
    FROM adempiere.TC_SecondaryHardeningLabel sh
    JOIN adempiere.TC_PrimaryHardeningLabel ph ON sh.parentuuid = ph.c_uuid
    JOIN adempiere.tc_primaryHardeningcultureS phs ON phs.TC_PrimaryHardeningLabel_id = ph.TC_PrimaryHardeningLabel_id
    JOIN adempiere.tc_out o ON o.tc_out_id = ph.tc_out_id
    JOIN adempiere.m_locator loc ON loc.m_locator_id = o.m_locator_id
    JOIN adempiere.tc_plantspecies ps ON ps.tc_plantspecies_id = ph.tc_species_id
    JOIN adempiere.tc_variety var ON var.tc_variety_id = ph.tc_variety_id
    JOIN adempiere.ad_user u ON u.ad_user_id = sh.createdby
    WHERE TRIM(sh.c_uuid) = TRIM( $P{CultureLabelUUId} )
      AND sh.ad_client_id =  $P{AD_CLIENT_ID} 
)
----------------------------------------------------------------
-- FINAL OUTPUT
----------------------------------------------------------------
SELECT * FROM secondary_result
UNION ALL
SELECT * FROM primary_result 
UNION ALL
SELECT * FROM culture_result
WHERE (parentuuid IS NULL OR parentuuid <> c_uuid)
UNION ALL
SELECT * FROM explant_result WHERE NOT EXISTS (SELECT 1 FROM culture_result)
UNION ALL 
SELECT * FROM plant_tag_result 
WHERE NOT EXISTS (SELECT 1 FROM explant_result) AND NOT EXISTS (SELECT 1 FROM culture_result)
ORDER BY created ASC;

********************************************************************************
********************************************************************************
********************************************************************************