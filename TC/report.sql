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
Current Sensor latest Jasper Report Query:-
Not use this logic:
WITH base AS (
SELECT dd.value AS device_name,l.m_locatortype_id AS RoomId,l.tc_devicedata_id AS deviceId,lt.name AS Room,COALESCE(l.custom_timestamp::date) AS Date,
COALESCE(l.appearance, '0') AS ampere,l.custom_timestamp,ls.name AS lightstatus,NULLIF(l.lighton, 'None')::interval AS duration,
LAG(l.custom_timestamp) OVER (PARTITION BY l.tc_devicedata_id ORDER BY l.custom_timestamp) AS prev_ts,
LAG(ls.name) OVER (PARTITION BY l.tc_devicedata_id ORDER BY l.custom_timestamp) AS prev_status,
LAG(NULLIF(l.lighton, 'None')::interval) OVER (PARTITION BY l.tc_devicedata_id ORDER BY l.custom_timestamp) AS prev_duration
FROM adempiere.tc_light l JOIN adempiere.m_locatortype lt ON lt.m_locatortype_id = l.m_locatortype_id
JOIN adempiere.tc_lightstatus ls ON ls.tc_lightstatus_id = l.tc_lightstatus_id JOIN adempiere.tc_devicedata dd ON dd.tc_devicedata_id = l.tc_devicedata_id
WHERE l.ad_client_id = $P{AD_CLIENT_ID} 
AND COALESCE(l.custom_timestamp) >= $P{FromDate} 
AND COALESCE(l.custom_timestamp) < ($P{ToDate}::timestamp + INTERVAL '1 day')
AND ($P{deviceId} IS NULL OR dd.tc_devicedata_id IN ($P!{deviceId}))
AND ($P{RoomType} IS NULL OR lt.name = $P{RoomType}) 
AND  ($P{LightStatus}  IS NULL OR ls.name =  $P{LightStatus}) 
),
diff_calc AS (
SELECT device_name,RoomId,deviceId,Room,Date,ampere,custom_timestamp,lightstatus,duration,prev_ts,
prev_status,prev_duration,(duration - prev_duration) AS diff FROM base),
nightmode AS (
SELECT device_name,RoomId,deviceId,Room,Date,'0.00' AS ampere,
'Night Mode' AS datetime_text,'Off' AS lightstatus,diff AS duration_interval,(prev_ts + INTERVAL '1 millisecond') AS sort_ts,
1 AS ord FROM diff_calc WHERE
prev_status = 'On'  AND lightstatus = 'On' AND diff IS NOT NULL AND diff > INTERVAL '01:10:00'),
regular AS (
SELECT device_name,RoomId,deviceId,Room,Date,ampere,TO_CHAR(custom_timestamp,'DD/MM/YYYY HH12:MI AM')  AS datetime_text,
lightstatus,duration AS duration_interval,custom_timestamp AS sort_ts,2 AS ord FROM diff_calc)
SELECT device_name,RoomId,deviceId,Room,Date,ampere,datetime_text   AS datetime,lightstatus,duration_interval::text  AS duration
FROM (SELECT * FROM nightmode
UNION ALL
SELECT * FROM regular) s
ORDER BY RoomId, deviceId, sort_ts, ord;

==========================================================================================
Current Sensor latest Jasper Report Query:-
Use this logic:

WITH base AS (
SELECT dd.value AS device_name,l.m_locatortype_id AS RoomId,l.tc_devicedata_id AS deviceId,lt.name AS Room,
COALESCE(l.custom_timestamp::date) AS Date,COALESCE(l.appearance, '0') AS ampere,l.custom_timestamp,ls.name AS lightstatus,
NULLIF(l.lighton, 'None')::interval AS duration,
LAG(l.custom_timestamp) OVER (PARTITION BY l.tc_devicedata_id ORDER BY l.custom_timestamp) AS prev_ts,
LAG(ls.name) OVER (PARTITION BY l.tc_devicedata_id ORDER BY l.custom_timestamp) AS prev_status,
LAG(NULLIF(l.lighton, 'None')::interval) OVER (PARTITION BY l.tc_devicedata_id ORDER BY l.custom_timestamp) AS prev_duration
FROM adempiere.tc_light l JOIN adempiere.m_locatortype lt ON lt.m_locatortype_id = l.m_locatortype_id
JOIN adempiere.tc_lightstatus ls ON ls.tc_lightstatus_id = l.tc_lightstatus_id JOIN adempiere.tc_devicedata dd ON dd.tc_devicedata_id = l.tc_devicedata_id
WHERE l.ad_client_id = $P{AD_CLIENT_ID} 
AND COALESCE(l.custom_timestamp) >= $P{FromDate} 
AND COALESCE(l.custom_timestamp) < ($P{ToDate}::timestamp + INTERVAL '1 day')
AND ($P{deviceId} IS NULL OR dd.tc_devicedata_id IN ($P!{deviceId}))
AND ($P{RoomType} IS NULL OR lt.name = $P{RoomType}) 
AND  ($P{LightStatus}  IS NULL OR ls.name =  $P{LightStatus}) 
),
diff_calc AS (
SELECT device_name,RoomId,deviceId,Room,Date,ampere,custom_timestamp,lightstatus,duration,prev_ts,prev_status,prev_duration,
(custom_timestamp - prev_ts) AS diff_ts FROM base),
nightmode AS (
SELECT device_name,RoomId,deviceId,Room,Date,'0.00' AS ampere,'Night Mode' AS datetime_text,'Off' AS lightstatus,diff_ts AS duration_interval,
(prev_ts + INTERVAL '1 millisecond') AS sort_ts,1 AS ord FROM diff_calc 
WHERE prev_status = 'On' AND lightstatus = 'On' AND diff_ts IS NOT NULL AND diff_ts > INTERVAL '01:10:00'),
regular AS (
SELECT device_name,RoomId,deviceId,Room,Date,ampere,TO_CHAR(custom_timestamp,'DD/MM/YYYY HH12:MI AM') AS datetime_text,
lightstatus,duration AS duration_interval,custom_timestamp AS sort_ts,2 AS ord FROM diff_calc)
SELECT device_name,RoomId,deviceId,Room,Date,ampere,datetime_text AS datetime,lightstatus,duration_interval::text AS duration
FROM (SELECT * FROM nightmode
UNION ALL
SELECT * FROM regular) s
ORDER BY RoomId, deviceId, sort_ts, ord;
==========================================================================================





==========================================================================================
With Config Working Query in jasper Report:-

WITH params AS (
SELECT cc.night_mode_start_time AS start_time,cc.night_mode_end_time AS end_time
FROM adempiere.tc_currentconfig cc WHERE cc.AD_CLIENT_ID = $P{AD_CLIENT_ID}),
nm_window AS (
SELECT COALESCE(start_time, '18:00:00'::time) AS nm_start,COALESCE(end_time, '08:00:00'::time) AS nm_end FROM params),
base AS (
SELECT dd.value AS device_name,l.m_locatortype_id AS RoomId,l.tc_devicedata_id AS deviceId,lt.name AS Room,COALESCE(l.custom_timestamp::date) AS Date,
COALESCE(l.appearance, '0') AS ampere,l.custom_timestamp,ls.name AS lightstatus,NULLIF(l.lighton, 'None')::interval AS duration,
LAG(l.custom_timestamp) OVER (PARTITION BY l.tc_devicedata_id ORDER BY l.custom_timestamp) AS prev_ts,
LAG(ls.name) OVER (PARTITION BY l.tc_devicedata_id ORDER BY l.custom_timestamp) AS prev_status,
LAG(NULLIF(l.lighton, 'None')::interval) OVER (PARTITION BY l.tc_devicedata_id ORDER BY l.custom_timestamp) AS prev_duration
FROM adempiere.tc_light l JOIN adempiere.m_locatortype lt ON lt.m_locatortype_id = l.m_locatortype_id
JOIN adempiere.tc_lightstatus ls ON ls.tc_lightstatus_id = l.tc_lightstatus_id JOIN adempiere.tc_devicedata dd ON dd.tc_devicedata_id = l.tc_devicedata_id
WHERE l.ad_client_id = $P{AD_CLIENT_ID} 
AND COALESCE(l.custom_timestamp) >= $P{FromDate} 
AND COALESCE(l.custom_timestamp) < ($P{ToDate}::timestamp + INTERVAL '1 day')
AND ($P{deviceId} IS NULL OR dd.tc_devicedata_id IN ($P!{deviceId}))
AND ($P{RoomType} IS NULL OR lt.name = $P{RoomType}) 
AND ($P{LightStatus}  IS NULL OR ls.name = $P{LightStatus}) 
),
diff_calc AS (
SELECT b.*,(b.custom_timestamp - b.prev_ts) AS diff_ts FROM base b),
nightmode AS (
SELECT d.device_name,d.RoomId,d.deviceId,d.Room,d.Date,'0.00' AS ampere,'Night Mode' AS datetime_text,'Off' AS lightstatus,
d.diff_ts AS duration_interval,(d.prev_ts + INTERVAL '1 millisecond') AS sort_ts,1 AS ord,w.nm_start,w.nm_end FROM diff_calc d
CROSS JOIN nm_window w WHERE d.prev_ts IS NOT NULL AND d.custom_timestamp IS NOT NULL AND d.diff_ts > INTERVAL '01:10:00'
AND ((d.prev_ts::time >= w.nm_start OR d.prev_ts::time <= w.nm_end) OR
(d.custom_timestamp::time >= w.nm_start OR d.custom_timestamp::time <= w.nm_end) OR
(CASE
      WHEN w.nm_start <= w.nm_end THEN
        ( d.prev_ts < date_trunc('day', d.prev_ts) + w.nm_start
          AND d.custom_timestamp >= date_trunc('day', d.prev_ts) + w.nm_end )
      ELSE
        ( d.prev_ts < date_trunc('day', d.prev_ts) + w.nm_start
          AND d.custom_timestamp >= date_trunc('day', d.prev_ts) + INTERVAL '1 day' + w.nm_end )
    END ))),
regular AS (
SELECT  device_name,RoomId,deviceId,Room,Date,ampere,TO_CHAR(custom_timestamp,'DD/MM/YYYY HH12:MI AM') AS datetime_text,
lightstatus,duration AS duration_interval,custom_timestamp AS sort_ts,2 AS ord,w.nm_start,w.nm_end FROM diff_calc CROSS JOIN nm_window w)
SELECT device_name,RoomId,deviceId,Room,Date,ampere,datetime_text AS datetime,lightstatus,duration_interval::text AS duration,nm_start,nm_end
FROM (
SELECT * FROM nightmode
    UNION ALL
SELECT * FROM regular) s
ORDER BY RoomId, deviceId, sort_ts, ord;
===========================================================================================================================

WITH params AS (
SELECT cc.night_mode_start_time AS start_time,cc.night_mode_end_time AS end_time
FROM adempiere.tc_currentconfig cc WHERE cc.AD_CLIENT_ID = 1000002
),
nm_window AS (
    -- 2) Use db values or fallback
    SELECT
        COALESCE(start_time, '18:00:00'::time) AS nm_start,
        COALESCE(end_time, '08:00:00'::time)   AS nm_end
    FROM params
),
base AS (
    SELECT 
        dd.value AS device_name,
        l.m_locatortype_id AS RoomId,
        l.tc_devicedata_id AS deviceId,
        lt.name AS Room,
        COALESCE(l.custom_timestamp::date) AS Date,
        COALESCE(l.appearance, '0') AS ampere,
        l.custom_timestamp,
        ls.name AS lightstatus,
        NULLIF(l.lighton, 'None')::interval AS duration,

        LAG(l.custom_timestamp) OVER (PARTITION BY l.tc_devicedata_id ORDER BY l.custom_timestamp) AS prev_ts,
        LAG(ls.name) OVER (PARTITION BY l.tc_devicedata_id ORDER BY l.custom_timestamp) AS prev_status,
        LAG(NULLIF(l.lighton, 'None')::interval) OVER (PARTITION BY l.tc_devicedata_id ORDER BY l.custom_timestamp) AS prev_duration
    FROM adempiere.tc_light l
    JOIN adempiere.m_locatortype lt ON lt.m_locatortype_id = l.m_locatortype_id
    JOIN adempiere.tc_lightstatus ls ON ls.tc_lightstatus_id = l.tc_lightstatus_id
    JOIN adempiere.tc_devicedata dd ON dd.tc_devicedata_id = l.tc_devicedata_id
),
diff_calc AS (
    SELECT 
        b.*,
        (b.custom_timestamp - b.prev_ts) AS diff_ts
    FROM base b
),
nightmode AS (
    SELECT 
        d.device_name,
        d.RoomId,
        d.deviceId,
        d.Room,
        d.Date,
        '0.00' AS ampere,
        'Night Mode' AS datetime_text,
        'Off' AS lightstatus,
        d.diff_ts AS duration_interval,
        (d.prev_ts + INTERVAL '1 millisecond') AS sort_ts,
        1 AS ord
    FROM diff_calc d
    CROSS JOIN nm_window w
    WHERE 
        d.prev_ts IS NOT NULL
        AND d.custom_timestamp IS NOT NULL
        AND d.diff_ts > INTERVAL '01:10:00'
        AND (
                /* Match if PREVIOUS timestamp inside night window */
                (d.prev_ts::time >= w.nm_start OR d.prev_ts::time <= w.nm_end)
             OR
                /* Match if CURRENT timestamp inside night window */
                (d.custom_timestamp::time >= w.nm_start OR d.custom_timestamp::time <= w.nm_end)
             -- OR
            /* C: Interval crosses night window (middle night mode) */
            OR

  (
    CASE
      WHEN w.nm_start <= w.nm_end THEN
        ( d.prev_ts < date_trunc('day', d.prev_ts) + w.nm_start
          AND d.custom_timestamp >= date_trunc('day', d.prev_ts) + w.nm_end )
      ELSE
        ( d.prev_ts < date_trunc('day', d.prev_ts) + w.nm_start
          AND d.custom_timestamp >= date_trunc('day', d.prev_ts) + INTERVAL '1 day' + w.nm_end )
    END
  )
  )

            -- (
  -- compute base day relative to prev_ts
  -- (
  --   -- night does NOT wrap midnight (start <= end)
  --   CASE
  --     WHEN w.nm_start <= w.nm_end THEN
  --       -- night interval on same day:
  --       -- night_start_ts = date(prev_ts) + nm_start
  --       -- night_end_ts   = date(prev_ts) + nm_end
  --       ( d.prev_ts <  (date_trunc('day', d.prev_ts) + w.nm_start)
  --         AND d.custom_timestamp >= (date_trunc('day', d.prev_ts) + w.nm_end) )
  --     ELSE
  --       -- night WRAPS midnight (start > end), e.g. 18:00 -> 09:00
  --       -- night_start_ts = date(prev_ts) + nm_start (day D)
  --       -- night_end_ts   = date(prev_ts) + 1 day + nm_end (day D+1)
  --       ( d.prev_ts <  (date_trunc('day', d.prev_ts) + w.nm_start)
  --         AND d.custom_timestamp >= (date_trunc('day', d.prev_ts) + INTERVAL '1 day' + w.nm_end) )
  --   END
  -- )
  -- AND d.diff_ts <= INTERVAL '24 hours'
-- )
    --         (
    --             d.prev_ts::time < w.nm_start
    --             AND d.custom_timestamp::time > w.nm_end
    --             AND d.diff_ts <= INTERVAL '24 hours'  -- skip if > 24 hours
    --         )    
            -- )
),
regular AS (
    SELECT 
        device_name,
        RoomId,
        deviceId,
        Room,
        Date,
        ampere,
        TO_CHAR(custom_timestamp,'DD/MM/YYYY HH12:MI AM') AS datetime_text,
        lightstatus,
        duration AS duration_interval,
        custom_timestamp AS sort_ts,
        2 AS ord
    FROM diff_calc
)
SELECT 
    device_name,
    RoomId,
    deviceId,
    Room,
    Date,
    ampere,
    datetime_text AS datetime,
    duration_interval::text AS duration
FROM (
    SELECT * FROM nightmode
    UNION ALL
    SELECT * FROM regular
) s
ORDER BY RoomId, deviceId, sort_ts, ord;
