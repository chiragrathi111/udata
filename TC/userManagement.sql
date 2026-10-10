SELECT 
    users,
    userId,
    personalCode,
    date,
    orderId,
    type,
    id,
    labelName,
    discarded,
    countValue,
    countValueN,
    counts,
    countsN
FROM (

    -- =========================================================
    -- Tissue Culture Technician - Approved (discarded = N)
    -- quantity -> countValue / counts
    -- =========================================================
    SELECT 
        u.name AS users,
        u.ad_user_id AS userId,
        u.personalcode AS personalCode,
        DATE(cl.created) AS date,
        o.tc_order_id AS orderID,
        cs.name AS type,
        cl.tc_culturelabel_id AS id,
        'Tissue Culture Technician' AS labelName,
        cl.isdiscarded AS discarded,

        CAST(
            COUNT(*) OVER (
                PARTITION BY DATE(cl.created), o.tc_order_id, u.name
            ) AS NUMERIC
        ) AS countValue,

        0::NUMERIC AS countValueN,

        CASE WHEN ROW_NUMBER() OVER (
                    PARTITION BY DATE(cl.created), o.tc_order_id, u.name
                    ORDER BY cl.tc_culturelabel_id
                 ) = 1
             THEN CAST(
                    COUNT(*) OVER (
                        PARTITION BY DATE(cl.created), o.tc_order_id, u.name
                    ) AS NUMERIC
                  )
             ELSE 0::NUMERIC
        END AS counts,

        0::NUMERIC AS countsN

    FROM adempiere.tc_culturelabel cl

    JOIN adempiere.ad_user u 
        ON u.ad_user_id = cl.createdby 
        AND u.ad_client_id = cl.ad_client_id
    JOIN adempiere.AD_User_Roles ur ON ur.ad_user_id = u.ad_user_id
    JOIN adempiere.AD_Role r ON ur.AD_Role_id = r.AD_Role_id

    JOIN adempiere.tc_out o 
        ON o.tc_out_id = cl.tc_out_id

    JOIN adempiere.tc_culturestage cs 
        ON cs.tc_culturestage_id = cl.tc_culturestage_id

    WHERE cl.AD_CLIENT_ID = 1000000
      AND cl.isdiscarded = 'N'
      AND u.personalcode IS NOT NULL
      AND r.name = 'TCT'

    UNION ALL


    -- =========================================================
    -- Tissue Culture Technician - Discarded (discarded = Y)   [NEW]
    -- quantity -> countValueN / countsN
    -- (same as QA second section: N-columns carry the quantity)
    -- =========================================================
    SELECT 
        u.name AS users,
        u.ad_user_id AS userId,
        u.personalcode AS personalCode,
        DATE(cl.updated) AS date,
        o.tc_order_id AS orderID,
        cs.name AS type,
        cl.tc_culturelabel_id AS id,
        'Tissue Culture Technician' AS labelName,
        cl.isdiscarded AS discarded,

        0::NUMERIC AS countValue,

        CAST(
            COUNT(*) OVER (
                PARTITION BY DATE(cl.updated), o.tc_order_id, u.name
            ) AS NUMERIC
        ) AS countValueN,

        0::NUMERIC AS counts,

        CASE WHEN ROW_NUMBER() OVER (
                    PARTITION BY DATE(cl.updated), o.tc_order_id, u.name
                    ORDER BY cl.tc_culturelabel_id
                 ) = 1
             THEN CAST(
                    COUNT(*) OVER (
                        PARTITION BY DATE(cl.updated), o.tc_order_id, u.name
                    ) AS NUMERIC
                  )
             ELSE 0::NUMERIC
        END AS countsN

    FROM adempiere.tc_culturelabel cl

    JOIN adempiere.ad_user u 
        ON u.ad_user_id = cl.updatedby 
        AND u.ad_client_id = cl.ad_client_id
    JOIN adempiere.AD_User_Roles ur ON ur.ad_user_id = u.ad_user_id
    JOIN adempiere.AD_Role r ON ur.AD_Role_id = r.AD_Role_id

    JOIN adempiere.tc_out o 
        ON o.tc_out_id = cl.tc_out_id

    JOIN adempiere.tc_culturestage cs 
        ON cs.tc_culturestage_id = cl.tc_culturestage_id

    WHERE cl.AD_CLIENT_ID = 1000000
      AND cl.isdiscarded = 'Y'
      AND u.personalcode IS NOT NULL
      AND r.name = 'TCT'

    UNION ALL


    -- =========================================================
    -- Medium Technician
    -- =========================================================
    SELECT 
        u.name AS users,
        u.ad_user_id AS userId,
        u.personalcode AS personalCode,
        DATE(cl.created) AS date,
        o.tc_mediaorder_id AS orderID,
        pr.description AS type,
        cl.tc_medialabelQr_id AS id,
        'Medium Technician' AS labelName,
        cl.isdiscarded AS discarded,

        CAST(
            COUNT(*) OVER (
                PARTITION BY DATE(cl.created), o.tc_mediaorder_id, u.name
            ) AS NUMERIC
        ) AS countValue,

        0::NUMERIC AS countValueN,

        CASE WHEN ROW_NUMBER() OVER (
                    PARTITION BY DATE(cl.created), o.tc_mediaorder_id, u.name
                    ORDER BY cl.tc_medialabelQr_id
                 ) = 1
             THEN CAST(
                    COUNT(*) OVER (
                        PARTITION BY DATE(cl.created), o.tc_mediaorder_id, u.name
                    ) AS NUMERIC
                  )
             ELSE 0::NUMERIC
        END AS counts,

        0::NUMERIC AS countsN

    FROM adempiere.tc_medialabelQr cl

    JOIN adempiere.ad_user u 
        ON u.ad_user_id = cl.createdby 
        AND u.ad_client_id = cl.ad_client_id

    JOIN adempiere.tc_medialine o 
        ON o.tc_medialine_id = cl.tc_medialine_id

    JOIN adempiere.tc_mediaorder mo 
        ON mo.tc_mediaorder_id = o.tc_mediaorder_id

    JOIN adempiere.m_product pr 
        ON pr.m_product_id = mo.m_product_id

    WHERE cl.AD_CLIENT_ID = 1000000
      AND u.personalcode IS NOT NULL


    UNION ALL


    -- =========================================================
    -- Quality Checker - Discarded = Y  (countValue / counts)
    -- =========================================================
    SELECT 
        u.name AS users,
        u.ad_user_id AS userId,
        u.personalcode AS personalCode,
        DATE(cl.updated) AS date,
        o.tc_order_id AS orderID,
        cs.name AS type,
        cl.tc_culturelabel_id AS id,
        'Quality Checker' AS labelName,
        cl.isdiscarded AS discarded,

        CAST(
            COUNT(*) OVER (
                PARTITION BY DATE(cl.updated), o.tc_order_id, u.name
            ) AS NUMERIC
        ) AS countValue,

        0::NUMERIC AS countValueN,

        CASE WHEN ROW_NUMBER() OVER (
                    PARTITION BY DATE(cl.updated), o.tc_order_id, u.name
                    ORDER BY cl.tc_culturelabel_id
                 ) = 1
             THEN CAST(
                    COUNT(*) OVER (
                        PARTITION BY DATE(cl.updated), o.tc_order_id, u.name
                    ) AS NUMERIC
                  )
             ELSE 0::NUMERIC
        END AS counts,

        0::NUMERIC AS countsN

    FROM adempiere.tc_culturelabel cl

    JOIN adempiere.ad_user u 
        ON u.ad_user_id = cl.updatedby 
        AND u.ad_client_id = cl.ad_client_id
    JOIN adempiere.AD_User_Roles ur ON u.ad_user_id = ur.ad_user_id
    JOIN adempiere.AD_Role r ON r.AD_Role_id = ur.AD_Role_id

    JOIN adempiere.tc_out o 
        ON o.tc_out_id = cl.tc_out_id

    JOIN adempiere.tc_culturestage cs 
        ON cs.tc_culturestage_id = cl.tc_culturestage_id

    WHERE cl.AD_CLIENT_ID = 1000000
      AND cl.isdiscarded = 'Y'
      AND u.personalcode IS NOT NULL
      AND r.name = 'QA'

    UNION ALL


    -- =========================================================
    -- Quality Checker - Discarded = N  (countValueN / countsN)
    -- =========================================================
    SELECT 
        u.name AS users,
        u.ad_user_id AS userId,
        u.personalcode AS personalCode,
        DATE(cl.updated) AS date,
        o.tc_order_id AS orderID,
        cs.name AS type,
        cl.tc_culturelabel_id AS id,
        'Quality Checker' AS labelName,
        cl.isdiscarded AS discarded,

        0::NUMERIC AS countValue,

        CAST(
            COUNT(*) OVER (
                PARTITION BY DATE(cl.updated), o.tc_order_id, u.name
            ) AS NUMERIC
        ) AS countValueN,

        0::NUMERIC AS counts,

        CASE WHEN ROW_NUMBER() OVER (
                    PARTITION BY DATE(cl.updated), o.tc_order_id, u.name
                    ORDER BY cl.tc_culturelabel_id
                 ) = 1
             THEN CAST(
                    COUNT(*) OVER (
                        PARTITION BY DATE(cl.updated), o.tc_order_id, u.name
                    ) AS NUMERIC
                  )
             ELSE 0::NUMERIC
        END AS countsN

    FROM adempiere.tc_culturelabel cl

    JOIN adempiere.ad_user u 
        ON u.ad_user_id = cl.updatedby 
        AND u.ad_client_id = cl.ad_client_id
    JOIN adempiere.AD_User_Roles ur ON ur.ad_user_id = u.ad_user_id
    JOIN adempiere.AD_Role r ON ur.AD_Role_id = r.AD_Role_id

    JOIN adempiere.tc_out o 
        ON o.tc_out_id = cl.tc_out_id

    JOIN adempiere.tc_culturestage cs 
        ON cs.tc_culturestage_id = cl.tc_culturestage_id

    WHERE cl.AD_CLIENT_ID = 1000000
      AND cl.isdiscarded = 'N'
      AND u.personalcode IS NOT NULL
      AND r.name = 'QA'

) AS combined
WHERE 
-- combined.date >= $P{FromDate} AND combined.date < ($P{ToDate} ::timestamp + INTERVAL '1 day') 
-- AND 
-- ($P{Label} IS NULL OR combined.labelName = $P{Label}) 
('Tissue Culture Technician' IS NULL OR combined.labelName = 'Tissue Culture Technician') 
ORDER BY users, date, orderId;