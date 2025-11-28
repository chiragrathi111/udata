TH Query:-

	SELECT lt.name AS room_name,ts.tc_devicedata_id,ts.name AS device_name,tts.name AS temp_status,ts.humiditystatus AS humidity_status,
	ts.temperature,ts.humidity,ts.custom_timestamp,TO_CHAR(ts.custom_timestamp, 'DD-MM-YYYY') AS date,ts.battery_percentage As battery
	FROM (SELECT DISTINCT ON (ts.tc_devicedata_id) ts.* FROM adempiere.tc_temperaturestatus ts
	WHERE ts.m_locatortype_id = 1000013 AND ts.ad_client_id = 1000002
	ORDER BY ts.tc_devicedata_id, ts.custom_timestamp DESC) ts
	JOIN adempiere.m_locatortype lt ON lt.m_locatortype_id = ts.m_locatortype_id
	JOIN adempiere.tc_tempstatus tts  ON tts.tc_tempstatus_id = ts.tc_tempstatus_id
	ORDER BY ts.tc_devicedata_id;
------------------------------------
Room Type Query:-

SELECT name,m_locatortype_id FROM adempiere.m_locatortype
WHERE ad_client_id = 1000002 AND description = 'Room' ORDER BY m_locatortype_id;
------------------------------------
Light Query:-

SELECT lt.name AS room_name,l.tc_devicedata_id,l.name AS device_name,ls.name AS light_status,l.lighton AS time,
l.appearance AS ampere,l.custom_timestamp,TO_CHAR(l.custom_timestamp, 'DD-MM-YYYY') AS date
FROM (SELECT DISTINCT ON (l.tc_devicedata_id) l.* FROM adempiere.tc_light l
WHERE l.m_locatortype_id = 1000012 AND l.ad_client_id = 1000002 ORDER BY l.tc_devicedata_id, l.custom_timestamp DESC) l
JOIN adempiere.m_locatortype lt ON lt.m_locatortype_id = l.m_locatortype_id
JOIN adempiere.tc_lightstatus ls ON ls.tc_lightstatus_id = l.tc_lightstatus_id
ORDER BY l.tc_devicedata_id;
------------------------------------