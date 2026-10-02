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
    -- Tissue Culture Technician
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

        -- =========================================================
        -- FIX 2 (footer total mismatch): previously this was
        --   COUNT(*) OVER (PARTITION BY cl.created, o.tc_order_id, u.name)
        -- which partitions by the RAW timestamp instead of the date.
        -- If two or more labels in the same order share the exact
        -- same "created" timestamp (common with bulk inserts / fast
        -- scanning in production), that window returns k for each of
        -- the k matching rows, and Jasper's group-footer SUM() then
        -- adds k copies of k = k^2 instead of k, inflating the
        -- "User Wise Total" / "Date Wise Total" beyond what the
        -- printed per-order lines actually add up to.
        --
        -- Fix: attribute the order's full countValue to exactly ONE
        -- row per (date, order, user) via ROW_NUMBER(), and 0 to
        -- every other row in that same group. SUM() over this field
        -- is then mathematically guaranteed to equal the sum of the
        -- values printed on the order lines, regardless of how many
        -- physical label rows exist or whether timestamps collide.
        -- =========================================================
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

    JOIN adempiere.tc_out o 
        ON o.tc_out_id = cl.tc_out_id

    JOIN adempiere.tc_culturestage cs 
        ON cs.tc_culturestage_id = cl.tc_culturestage_id

    WHERE cl.AD_CLIENT_ID = $P{AD_CLIENT_ID}
      AND cl.isdiscarded = 'N'
      AND u.personalcode IS NOT NULL


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

        -- FIX 2, same reasoning as above, applied to the media branch.
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

    WHERE cl.AD_CLIENT_ID = $P{AD_CLIENT_ID}
      AND u.personalcode IS NOT NULL


    UNION ALL


    -- =========================================================
    -- Quality Checker - Discarded = Y
    -- (Fix 1 preserved: displayed date and window partition both
    -- use DATE(cl.updated), so the Discarded Count shown for a
    -- given printed date matches what actually happened that day.)
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

        -- FIX 2, same reasoning, applied to the QC-discarded branch.
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

    JOIN adempiere.tc_out o 
        ON o.tc_out_id = cl.tc_out_id

    JOIN adempiere.tc_culturestage cs 
        ON cs.tc_culturestage_id = cl.tc_culturestage_id

    WHERE cl.AD_CLIENT_ID = $P{AD_CLIENT_ID}
      AND cl.isdiscarded = 'Y'
      AND u.personalcode IS NOT NULL


    UNION ALL


    -- =========================================================
    -- Quality Checker - Discarded = N
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

        -- FIX 2, mirrored for the countValueN / countsN pair.
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

    JOIN adempiere.tc_out o 
        ON o.tc_out_id = cl.tc_out_id

    JOIN adempiere.tc_culturestage cs 
        ON cs.tc_culturestage_id = cl.tc_culturestage_id

    WHERE cl.AD_CLIENT_ID = $P{AD_CLIENT_ID}
      AND cl.isdiscarded = 'N'
      AND u.personalcode IS NOT NULL

) AS combined
WHERE 
combined.date >= $P{FromDate} AND combined.date < ($P{ToDate} ::timestamp + INTERVAL '1 day') 
AND ($P{Label} IS NULL OR combined.labelName = $P{Label}) 
ORDER BY users,date,orderId;