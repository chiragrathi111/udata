Current Consolidate:-
WITH status_durations AS (SELECT l.m_locatortype_id,l.tc_devicedata_id,lt.name AS room_name,
TO_CHAR(COALESCE(l.custom_timestamp, l.created), 'DD/MM/YY') AS dates,
COALESCE(l.custom_timestamp::Date, l.created::Date) AS only_date,
dd.value AS device_name,ls.name AS status_name,l.created AS created_ts,
COALESCE(NULLIF(l.appearance, ''), '0')::numeric AS ampere,LEAD(l.created) OVER (PARTITION BY l.tc_devicedata_id ORDER BY l.created) AS next_time
FROM adempiere.tc_light l JOIN adempiere.m_locatortype lt ON lt.m_locatortype_id = l.m_locatortype_id
JOIN adempiere.tc_lightstatus ls ON ls.tc_lightstatus_id = l.tc_lightstatus_id
JOIN adempiere.tc_devicedata dd ON dd.tc_devicedata_id = l.tc_devicedata_id
WHERE l.ad_client_id = 1000000 
AND COALESCE(l.custom_timestamp, l.created) >= '2025-09-15'
AND COALESCE(l.custom_timestamp, l.created) < ('2025-09-16'::timestamp + INTERVAL '1 day')
-- AND l.created >= '2025-09-15'
-- AND l.created < ('2025-09-16'::timestamp + INTERVAL '1 day')
-- AND ($P{deviceId} IS NULL OR dd.tc_devicedata_id IN ($P!{deviceId}))
-- AND ($P{RoomType} IS NULL OR lt.name = $P{RoomType}) 
-- AND  ($P{LightStatus}  IS NULL OR ls.name =  $P{LightStatus})
)
SELECT only_date AS date,dates,m_locatortype_id,tc_devicedata_id,room_name,device_name,status_name,COUNT(*) AS status_count,
ROUND(AVG(ampere), 2) AS avg_ampere,FLOOR(LEAST(SUM(EXTRACT(EPOCH FROM (next_time - created_ts)) / 60), 1440) / 60) || ' hour ' ||
FLOOR(LEAST(SUM(EXTRACT(EPOCH FROM (next_time - created_ts)) / 60), 1440) % 60) || ' min' AS duration
FROM status_durations GROUP BY m_locatortype_id,tc_devicedata_id,only_date,room_name,device_name,status_name,dates
ORDER BY  room_name, device_name,only_date DESC, status_name;
===================================================================================
Temperatue:-
SELECT t.humidityStatus,ts.name AS status, COALESCE(t.battery_percentage, '') AS battery_percentage,
    CASE
        WHEN TRIM(COALESCE(t.humidityStatus, '')) = '' THEN ts.name
        WHEN LOWER(TRIM(t.humidityStatus)) = 'normal' AND LOWER(TRIM(ts.name)) = 'normal' THEN 'Normal'
        
        WHEN LOWER(TRIM(t.humidityStatus)) = 'normal' THEN ts.name
        WHEN LOWER(TRIM(ts.name)) = 'normal' THEN t.humidityStatus
        
        ELSE ts.name || ',' || t.humidityStatus
    END AS final_status,
t.name AS deviceName,
TO_CHAR(COALESCE(t.custom_timestamp, t.created), 'DD/MM/YY') AS Dates,
 TO_CHAR(COALESCE(t.custom_timestamp, t.created), 'HH12:MI AM') AS Time,
lt.name AS RoomType,dd.tc_devicedata_id,dd.value,t.m_locatortype_id,ts.tc_tempstatus_id,t.temperature,
t.humidity,
COALESCE(t.custom_timestamp, t.created) AS dateTime,
 COALESCE(t.custom_timestamp::Date, t.created::Date) AS Date,
COALESCE((
        SELECT tts.min_temperature
        FROM adempiere.tc_tempstatus tts
        WHERE tts.name = 'Normal' AND tts.ad_client_id = 1000000 
        LIMIT 1
    ), '21') AS min_temp_for_normal,
COALESCE((
        SELECT tts.max_temperature
        FROM adempiere.tc_tempstatus tts
        WHERE tts.name = 'Normal' AND tts.ad_client_id = 1000000
        LIMIT 1
    ), '26') AS max_temp_for_normal,
 COALESCE((
        SELECT tts.min_humidity
        FROM adempiere.tc_tempstatus tts
        WHERE tts.name = 'Normal' AND tts.ad_client_id = 1000000
        LIMIT 1
    ), '40') AS min_humidity,
COALESCE((
        SELECT tts.max_humidity
        FROM adempiere.tc_tempstatus tts
        WHERE tts.name = 'Normal' AND tts.ad_client_id = 1000000
        LIMIT 1
    ), '70') AS max_humidity   
FROM adempiere.tc_temperatureStatus t JOIN adempiere.m_locatortype lt ON lt.m_locatortype_id = t.m_locatortype_id
JOIN adempiere.tc_tempstatus ts ON ts.tc_tempstatus_id = t.tc_tempstatus_id JOIN adempiere.tc_devicedata dd ON dd.tc_devicedata_id = t.tc_devicedata_id
WHERE t.ad_client_id = 1000000 
-- AND ($P{deviceId} IS NULL OR dd.tc_devicedata_id IN ($P!{deviceId})) AND
--     ($P{RoomtId} IS NULL OR lt.name = $P{RoomtId}) AND
--     ($P{statusId} IS NULL OR ts.tc_tempstatus_id IN ($P!{statusId})) 
   -- AND t.created >= $P{FromDate} AND
   --  t.created < ($P{ToDate}::timestamp + INTERVAL '1 day')
   AND COALESCE(t.custom_timestamp, t.created) >= '2025-09-15'
AND COALESCE(t.custom_timestamp, t.created) < ('2025-09-16'::timestamp + INTERVAL '1 day')

ORDER BY t.m_locatortype_id, t.created;
===============================================================================