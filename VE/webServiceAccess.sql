INSERT INTO adempiere.ws_webservicetypeaccess
(
    ws_webservicetype_id,
    ad_role_id,
    ad_client_id,
    ad_org_id,
    isactive,
    created,
    createdby,
    updated,
    updatedby
)
SELECT
    wsta.ws_webservicetype_id,
    r.ad_role_id,
    wsta.ad_client_id,
    wsta.ad_org_id,
    'Y',
    NOW(),
    wsta.createdby,
    NOW(),
    wsta.updatedby
FROM adempiere.ws_webservicetypeaccess wsta
CROSS JOIN (
    SELECT 1000000 AS ad_role_id
    -- UNION ALL
    -- SELECT 1000001
) r
WHERE wsta.ad_role_id = 1000002
AND NOT EXISTS (
    SELECT 1
    FROM adempiere.ws_webservicetypeaccess x
    WHERE x.ws_webservicetype_id = wsta.ws_webservicetype_id
      AND x.ad_role_id = r.ad_role_id
);