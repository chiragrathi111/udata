======================================================================================================
Temperature Humidity Query:-
SELECT 
    t.name AS deviceName, 
    TO_CHAR(t.created, 'DD/MM/YY') AS Dates, 
    TO_CHAR(t.created, 'HH12:MI AM') AS Time,
    lt.name AS RoomType,
    dd.tc_devicedata_id,
    dd.value,
    t.m_locatortype_id,
    ts.name AS status, 
    ts.tc_tempstatus_id,
    t.temperature,
    t.humidity,
    t.created AS dateTime, 
    t.created::Date AS Date,

    -- Subqueries to fetch min and max temperature for 'Normal' status with default values
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
======================================================================================================
Temperatue Humidity Jasper Report:-
SELECT 
    t.name AS deviceName, TO_CHAR(t.created, 'DD/MM/YY') AS Dates, TO_CHAR(t.created, 'HH12:MI AM') AS Time,
    lt.name AS RoomType,dd.tc_devicedata_id,dd.value,
    t.m_locatortype_id,
    ts.name AS status, ts.tc_tempstatus_id,
    t.temperature,
    t.humidity,
    t.created AS dateTime, t.created::Date AS Date,
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
 JOIN adempiere.tc_devicedata dd ON dd.tc_devicedata_id = t.tc_devicedata_id
WHERE 
    t.ad_client_id = $P{AD_CLIENT_ID} AND
    ($P{deviceId} IS NULL OR dd.tc_devicedata_id IN ($P!{deviceId})) AND
    ($P{RoomtId} IS NULL OR lt.name = $P{RoomtId}) AND
    ($P{statusId} IS NULL OR ts.tc_tempstatus_id IN ($P!{statusId})) AND
    t.created >= $P{FromDate} AND
    t.created < ($P{ToDate}::timestamp + INTERVAL '1 day')
ORDER BY 
    t.m_locatortype_id, t.created;
==========================================================================================    