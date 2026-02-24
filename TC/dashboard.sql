WITH grouped_data AS (
    SELECT 
        lt.m_locatortype_id,
        lt.name AS room,
        date_trunc('hour', t.custom_timestamp) AS hour_time,
        TO_CHAR(
            date_trunc('hour', t.custom_timestamp),
            'DD/MM/YYYY HH12:00 AM'
        ) AS createtime,
        ROUND(AVG(t.temperature::numeric), 2) AS avg_temperature,
        ROUND(AVG(t.humidity::numeric), 2) AS avg_humidity,
        array_agg(t.tc_temperaturestatus_id) AS ids
    FROM adempiere.tc_temperaturestatus t
    JOIN adempiere.m_locatortype lt 
        ON lt.m_locatortype_id = t.m_locatortype_id
    WHERE t.ad_client_id = 1000002
      AND t.isacknowledge = 'N'
      AND (
            ('MONTH' = 'DAY' 
                AND t.custom_timestamp::date = CURRENT_DATE)
         OR ('MONTH' = 'WEEK' 
                AND t.custom_timestamp >= date_trunc('week', CURRENT_DATE)
                AND t.custom_timestamp < date_trunc('week', CURRENT_DATE) + INTERVAL '1 week')
         OR ('MONTH' = 'MONTH' 
                AND t.custom_timestamp >= date_trunc('month', CURRENT_DATE)
                AND t.custom_timestamp < date_trunc('month', CURRENT_DATE) + INTERVAL '1 month')
          )
    GROUP BY 
        lt.m_locatortype_id,
        lt.name,
        date_trunc('hour', t.custom_timestamp)
),
status_data AS (
    SELECT
        m_locatortype_id,
        room,
        hour_time,
        createtime,
        avg_temperature,
        avg_humidity,
        ids,
        CASE 
            WHEN avg_temperature < 20 THEN 'OverCool'
            WHEN avg_temperature BETWEEN 20 AND 26 THEN 'Normal'
            WHEN avg_temperature > 26 THEN 'OverHeat'
        END AS avg_temp_status,
        CASE 
            WHEN avg_humidity < 40 THEN 'LessHumidity'
            WHEN avg_humidity BETWEEN 40 AND 70 THEN 'Normal'
            WHEN avg_humidity > 70 THEN 'HighHumidity'
        END AS avg_humidity_status
    FROM grouped_data
)
SELECT
    m_locatortype_id,
    room,
    hour_time,
    createtime,
    avg_temperature,
    avg_humidity,
    avg_temp_status,
    avg_humidity_status,
    CASE
        WHEN avg_temp_status = 'Normal'
             AND avg_humidity_status = 'Normal'
            THEN NULL
        WHEN avg_temp_status = 'Normal'
            THEN 
                CASE 
                    WHEN avg_humidity_status = 'LessHumidity' THEN 'LessHumidity'
                    WHEN avg_humidity_status = 'HighHumidity' THEN 'HighHumidity'
                END
        WHEN avg_humidity_status = 'Normal'
            THEN 
                CASE 
                    WHEN avg_temp_status = 'OverCool' THEN 'OverCool'
                    WHEN avg_temp_status = 'OverHeat' THEN 'OverHeat'
                END
        WHEN avg_temp_status = 'OverCool'
             AND avg_humidity_status = 'LessHumidity'
            THEN 'OverCool,LessHumidity'
        WHEN avg_temp_status = 'OverCool'
             AND avg_humidity_status = 'HighHumidity'
            THEN 'OverCool,HighHumidity'
        WHEN avg_temp_status = 'OverHeat'
             AND avg_humidity_status = 'LessHumidity'
            THEN 'OverHeat,LessHumidity'
        WHEN avg_temp_status = 'OverHeat'
             AND avg_humidity_status = 'HighHumidity'
            THEN 'OverHeat,HighHumidity'
    END AS final_status,
    ids
FROM status_data
WHERE NOT (
    avg_temp_status = 'Normal'
    AND avg_humidity_status = 'Normal'
)
ORDER BY hour_time DESC;