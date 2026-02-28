INSERT INTO adempiere.AD_Process_Access (
    AD_Client_ID,
    AD_Org_ID,
    IsActive,
    Created,
    CreatedBy,
    Updated,
    UpdatedBy,
    AD_Role_ID,
    AD_Process_ID
)
SELECT
    1000000,          -- Client ID (change if needed)
    0,
    'Y',
    now(),
    100,
    now(),
    100,
    1000006,          -- Your Role ID
    p.AD_Process_ID
FROM (
    VALUES
        (1000025),
        (1000006),
        (1000007),
		(1000005),
        (1000026),
        (1000023),
		(1000024),
        (1000012),
        (1000013),
		(1000010),
        (1000017),
		(1000015),
		(1000014)
        -- add more AD_Process_ID here
) AS p(AD_Process_ID)
WHERE NOT EXISTS (
    SELECT 1
    FROM adempiere.AD_Process_Access a
    WHERE a.AD_Role_ID = 1000006
    AND a.AD_Process_ID = p.AD_Process_ID
);