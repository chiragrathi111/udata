SELECT l.value, l.m_locator_id
FROM adempiere.m_locator l
JOIN adempiere.m_locatortype lt 
       ON lt.m_locatortype_id = l.m_locatortype_id
WHERE l.ad_client_id =  $P{AD_CLIENT_ID} 
  AND l.m_locatortype_id =  $P{RECORD_ID} 
  ORDER BY CAST(regexp_replace(l.value, '[^0-9]', '', 'g') AS INTEGER),
    -- Secondary order for alphabetical characters (e.g. A, B)
    l.value;

---------------------------------------------------------------------
UPDATE height,depth and width on loactor:-

UPDATE adempiere.m_locator
SET height = NULL,width = NULL,depth = NULL
WHERE m_locator_id BETWEEN 1000595 AND 1001014
  AND (height = 0 OR width = 0 OR depth = 0);  