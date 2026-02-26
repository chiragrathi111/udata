# Web Service access:-
INSERT INTO adempiere.WS_WebServiceTypeAccess (
    AD_Client_ID,
    AD_Org_ID,
    IsActive,
    Created,
    CreatedBy,
    Updated,
    UpdatedBy,
    AD_Role_ID,
    WS_WebServiceType_ID,
    WS_WebServiceTypeAccess_UU
)
SELECT
    a.AD_Client_ID,
    a.AD_Org_ID,
    'Y',
    now(),
    1000000,
    now(),
    1000000,
    1000006,
    a.WS_WebServiceType_ID,
    uuid_generate_v4()
FROM adempiere.WS_WebServiceTypeAccess a
WHERE a.AD_Role_ID = 1000000
AND NOT EXISTS (
    SELECT 1
    FROM adempiere.WS_WebServiceTypeAccess b
    WHERE b.AD_Role_ID = 1000006  # mofify role id
    AND b.WS_WebServiceType_ID = a.WS_WebServiceType_ID
);
