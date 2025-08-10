Media Production View:-

CREATE OR REPLACE VIEW adempiere.tcvn_mediaproduction AS
SELECT 
    pr.m_product_id,
    pr.name AS mediacategory,
    pr.description AS codeifany,
    COALESCE(ml.openingstock, 0) AS openingbalance,
    COALESCE(ml.stocked, 0) AS mediastocked,
    COALESCE(mol.totalqty, 0) AS issuetoct,
    COALESCE(ml.openingstock, 0) + COALESCE(ml.stocked, 0) - COALESCE(mol.totalqty, 0) - COALESCE(di.discarded_qty, 0) AS balance,
    ml.created,
    pr.ad_client_id,
    pr.ad_org_id,
	COALESCE(di.discarded_qty, 0) AS discardedquantity,
    COALESCE(di.discarded_count, 0) AS discarded_count
FROM adempiere.m_product pr
LEFT JOIN (
    SELECT 
        pr_1.m_product_id,
        min(date(ml_1.created)) AS created,
        NULLIF(sum(
            CASE
                WHEN date_trunc('month', ml_1.created)::date = date_trunc('month', CURRENT_DATE::timestamp with time zone)::date THEN ml_1.quantity
                ELSE 0
            END), 0) AS openingstock,
        NULLIF(sum(
            CASE
                WHEN date_trunc('month', ml_1.created)::date <> date_trunc('month', CURRENT_DATE::timestamp with time zone)::date THEN ml_1.quantity
                ELSE 0
            END), 0) AS stocked
    FROM adempiere.tc_medialine ml_1
    JOIN adempiere.m_product pr_1 ON pr_1.m_product_id = ml_1.m_product_id 
    GROUP BY pr_1.m_product_id
) ml ON pr.m_product_id = ml.m_product_id 
LEFT JOIN (
    SELECT 
        pro.m_product_id,
        sum(mol_1.quantity) AS totalqty
    FROM adempiere.tc_mediaoutline mol_1 
    JOIN adempiere.m_product pro ON pro.m_product_id = mol_1.m_product_id
    GROUP BY pro.m_product_id
) mol ON pr.m_product_id = mol.m_product_id
LEFT JOIN (
    SELECT 
        ml.m_product_id,
        sum(CASE WHEN mlq.isdiscarded = 'Y' THEN 1 ELSE 0 END) AS discarded_count,
        sum(CASE WHEN mlq.isdiscarded = 'Y' THEN ml.quantity ELSE 0 END) AS discarded_qty
    FROM adempiere.tc_medialine ml
    JOIN adempiere.tc_mediaLabelQr mlq ON ml.tc_medialine_id = mlq.tc_medialine_id
    GROUP BY ml.m_product_id
) di ON pr.m_product_id = di.m_product_id
JOIN adempiere.m_product_category pc ON pr.m_product_category_id = pc.m_product_category_id 
WHERE pc.name = 'BMedia';

=============================================================================================
SELECT t.humidityStatus,ts.name AS status,
CASE 
    WHEN t.humidityStatus IS NULL OR t.humidityStatus = '' THEN ts.name
    WHEN t.humidityStatus = 'Normal' AND ts.name = 'Normal' THEN 'Normal'
    WHEN t.humidityStatus = 'Less Humidity' AND ts.name = 'Over Cool' THEN CONCAT('Less Humidity,' || ts.name)
    WHEN t.humidityStatus = 'High Humidity' AND ts.name = 'Over Heat' THEN ts.name || ',High Humidity'
    WHEN t.humidityStatus = 'High Humidity' AND ts.name = 'Over Cool' THEN ts.name || ',High Humidity'
    WHEN t.humidityStatus = 'Less Humidity' AND ts.name = 'Over Heat' THEN ts.name || ',Less Humidity'
    WHEN t.humidityStatus = 'High Humidity' AND ts.name = 'Normal' THEN 'High Humidity'
    WHEN t.humidityStatus = 'Less Humidity' AND ts.name = 'Normal' THEN 'Less Humidity'
    WHEN t.humidityStatus = 'Normal' AND ts.name = 'Over Cool' THEN 'Over Cool'
    WHEN t.humidityStatus = 'Normal' AND ts.name = 'Over Heat' THEN 'Over Heat'
    ELSE ts.name
END AS final_status,
    t.name AS deviceName, 
    TO_CHAR(t.created, 'DD/MM/YY') AS Dates, 
    TO_CHAR(t.created, 'HH12:MI AM') AS Time,
    lt.name AS RoomType,
    dd.tc_devicedata_id,
    dd.value,
    t.m_locatortype_id,
    ts.tc_tempstatus_id,
    t.temperature,
    t.humidity,
    t.created AS dateTime, 
    t.created::Date AS Date,

    COALESCE((
        SELECT tts.min_temperature
        FROM adempiere.tc_tempstatus tts
        WHERE tts.name = 'Normal' AND tts.ad_client_id = 1000002
        LIMIT 1
    ), '21') AS min_temp_for_normal,

    COALESCE((
        SELECT tts.max_temperature
        FROM adempiere.tc_tempstatus tts
        WHERE tts.name = 'Normal' AND tts.ad_client_id = 1000002
        LIMIT 1
    ), '35') AS max_temp_for_normal
    

FROM 
    adempiere.tc_temperatureStatus t
JOIN 
    adempiere.m_locatortype lt ON lt.m_locatortype_id = t.m_locatortype_id
JOIN 
    adempiere.tc_tempstatus ts ON ts.tc_tempstatus_id = t.tc_tempstatus_id
JOIN 
    adempiere.tc_devicedata dd ON dd.tc_devicedata_id = t.tc_devicedata_id
WHERE 
    t.ad_client_id = 1000002 
ORDER BY 
    t.m_locatortype_id, t.created;

=============================================================================================
Working temperature report:-

SELECT 
    t.humidityStatus,
    ts.name AS status,
    CASE
        WHEN TRIM(COALESCE(t.humidityStatus, '')) = '' THEN ts.name
        WHEN LOWER(TRIM(t.humidityStatus)) = 'normal' AND LOWER(TRIM(ts.name)) = 'normal' THEN 'Normal'
        
        -- If one is Normal, return the other
        WHEN LOWER(TRIM(t.humidityStatus)) = 'normal' THEN ts.name
        WHEN LOWER(TRIM(ts.name)) = 'normal' THEN t.humidityStatus
        
        -- If both are not normal, return both combined
        ELSE ts.name || ',' || t.humidityStatus
    END AS final_status,

    -- Other columns unchanged
    t.name AS deviceName, 
    TO_CHAR(t.created, 'DD/MM/YY') AS Dates, 
    TO_CHAR(t.created, 'HH12:MI AM') AS Time,
    lt.name AS RoomType,
    dd.tc_devicedata_id,
    dd.value,
    t.m_locatortype_id,
    ts.tc_tempstatus_id,
    t.temperature,
    t.humidity,
    t.created AS dateTime, 
    t.created::Date AS Date,

    COALESCE((
        SELECT tts.min_temperature
        FROM adempiere.tc_tempstatus tts
        WHERE tts.name = 'Normal' AND tts.ad_client_id = 1000002
        LIMIT 1
    ), '21') AS min_temp_for_normal,

    COALESCE((
        SELECT tts.max_temperature
        FROM adempiere.tc_tempstatus tts
        WHERE tts.name = 'Normal' AND tts.ad_client_id = 1000002
        LIMIT 1
    ), '35') AS max_temp_for_normal

FROM 
    adempiere.tc_temperatureStatus t
JOIN 
    adempiere.m_locatortype lt ON lt.m_locatortype_id = t.m_locatortype_id
JOIN 
    adempiere.tc_tempstatus ts ON ts.tc_tempstatus_id = t.tc_tempstatus_id
JOIN 
    adempiere.tc_devicedata dd ON dd.tc_devicedata_id = t.tc_devicedata_id
WHERE 
    t.ad_client_id = 1000002 
ORDER BY 
    t.m_locatortype_id, t.created;
==============================================================================
Changes IOT Query:-
SELECT 
    lt.name AS RoomType, 
    ts.temperature, 
    ts.humidity,
    l.lighton AS time,
    ls.name AS lightstatus,
    ts.updated::DATE AS updated_date,
    TO_CHAR(ts.updated, 'DD-MM-YYYY') AS date
FROM (
    SELECT DISTINCT ON (ts.m_locatortype_id) *
    FROM adempiere.tc_temperaturestatus ts
    WHERE ts.ad_client_id = 1000000
    ORDER BY ts.m_locatortype_id, ts.updated DESC
) ts
JOIN adempiere.m_locatortype lt ON lt.m_locatortype_id = ts.m_locatortype_id
JOIN (
    SELECT DISTINCT ON (l.m_locatortype_id) *
    FROM adempiere.tc_light l
    ORDER BY l.m_locatortype_id, l.updated DESC
) l ON l.m_locatortype_id = lt.m_locatortype_id
JOIN adempiere.tc_lightstatus ls ON ls.tc_lightstatus_id = l.tc_lightstatus_id;
==============================================================================    
OLD IOT Dashboard Query:-
SELECT * 
FROM (
    SELECT 
        lt.name AS RoomType, 
        ts.temperature, 
        ts.humidity,l.lighton As time,ls.name As lightstatus,l.updated::Date, 
        TO_CHAR(ts.updated, 'DD-MM-YYYY') AS date,
        ROW_NUMBER() OVER (PARTITION BY ts.m_locatortype_id ORDER BY ts.updated DESC) AS rn,
        ROW_NUMBER() OVER (PARTITION BY l.m_locatortype_id ORDER BY l.updated DESC) AS rn1 
    FROM 
        adempiere.tc_temperaturestatus ts 
    JOIN 
        adempiere.m_locatortype lt ON lt.m_locatortype_id = ts.m_locatortype_id
    Join adempiere.tc_light l ON l.m_locatortype_id = lt.m_locatortype_id
    JOIN adempiere.tc_lightstatus ls ON ls.tc_lightstatus_id = l.tc_lightstatus_id
    WHERE 
        ts.ad_client_id = 1000002
) subquery 
WHERE 
    subquery.rn = 1;
==============================================================================    
INSERT INTO adempiere.ad_toolbarbuttonrestrict (
    ad_toolbarbuttonrestrict_id,
    ad_client_id,
    ad_org_id,
    isactive,
    created,
    createdby,
    updated,
    updatedby,
    ad_window_id,
    ad_tab_id,
    ad_role_id,
    ad_toolbarbutton_id,
    isexclude,
    ad_toolbarbuttonrestrict_uu,
    action,
    ad_process_id
) VALUES (
    1000001,                        -- your unique ID
    1000000,                        -- your client ID
    1000000,                              -- system org
    'Y',
    now(),
    100,                            -- your user ID
    now(),
    100,
    1000004,                        -- TC_SoilType window ID
    1000007,                        -- specific Tab ID (you can leave null to apply to all tabs)
    1000000,                        -- role ID (use 0 for all roles, or specific role)
    200039,                         -- toolbar button ID (e.g., 200039 = Attachment)
    'Y',                            -- isexclude = 'Y' disables it
    '94642da0-e66b-4d13-8031-751c8493chir', -- unique UUID
    'W',                            -- action type, keep as 'W'
    NULL                            -- ad_process_id, only needed for specific buttons
);

This have window,so dont need to use query
Name - Role Toolbar Button Access
===========================================================================================
SELECT 
    TO_CHAR(t.created::date, 'YYYY-MM-DD') AS date,
    lt.name AS room_name,
    dd.value AS device_name,
    ROUND(AVG(t.temperature::numeric), 2) AS avg_temperature,
    ROUND(AVG(t.humidity::numeric), 2) AS avg_humidity,
    COUNT(*) AS reading_count
FROM 
    adempiere.tc_temperatureStatus t
JOIN 
    adempiere.tc_devicedata dd ON dd.tc_devicedata_id = t.tc_devicedata_id
JOIN 
    adempiere.m_locatortype lt ON lt.m_locatortype_id = t.m_locatortype_id
WHERE 
    t.ad_client_id = 1000000
GROUP BY 
    t.created::date, lt.name, dd.value
ORDER BY 
    t.created::date DESC, lt.name, dd.value;
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
Working Query for Temperature date,deviceName according give one records:-
WITH last_battery AS (SELECT DISTINCT ON (t.tc_devicedata_id, t.created::date)
t.tc_devicedata_id,t.created::date AS date,
COALESCE(NULLIF(t.battery_percentage, ''), '0') AS battery_percentage
FROM adempiere.tc_temperatureStatus t WHERE t.ad_client_id = 1000000
ORDER BY t.tc_devicedata_id, t.created::date, t.created DESC)
SELECT TO_CHAR(t.created::date, 'YYYY-MM-DD') AS date,lt.name AS room_name,
dd.value AS device_name,ROUND(AVG(t.temperature::numeric), 2) AS avg_temperature,
ROUND(AVG(t.humidity::numeric), 2) AS avg_humidity,COUNT(*) AS reading_count,
COALESCE(lb.battery_percentage, '0') AS battery_percentage
FROM adempiere.tc_temperatureStatus t
JOIN adempiere.tc_devicedata dd ON dd.tc_devicedata_id = t.tc_devicedata_id
JOIN adempiere.m_locatortype lt ON lt.m_locatortype_id = t.m_locatortype_id
LEFT JOIN last_battery lb ON lb.tc_devicedata_id = t.tc_devicedata_id AND lb.date = t.created::date
WHERE t.ad_client_id = 1000000
GROUP BY t.created::date, lt.name, dd.value, lb.battery_percentage ORDER BY t.created::date DESC, lt.name, dd.value;    
