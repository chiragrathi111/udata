SELECT
    w.m_warehouse_id      AS warehouseId,
    w.name                AS warehouseName,
    ml.m_locatortype_id,
    ml.isdefault,
    lt.name               AS locatorType,
    ml.value              AS locatorName,
    ml.m_locator_id       AS locatorId,

    (
        COALESCE((
            SELECT SUM(QtyOnHand)
            FROM adempiere.M_StorageOnHand
            WHERE M_Locator_ID = ml.m_locator_id
        ), 0)

        -

        -- COALESCE((
        --     SELECT sum(quantity) 
        --     FROM adempiere.pi_productlabel pl2
        --     WHERE pl2.m_locator_id = ml.m_locator_id
        --       AND pl2.issotrx = 'Y'
        -- ), 0)

		COALESCE((
    SELECT SUM(qty)
    FROM (
        SELECT pl2.labeluuid, MAX(pl2.quantity) AS qty
        FROM adempiere.pi_productlabel pl2
        WHERE pl2.m_locator_id = ml.m_locator_id
          AND pl2.issotrx = 'Y' AND pl2.isactive = 'Y'
        GROUP BY pl2.labeluuid
    ) x
), 0)

    ) AS totalQty

FROM adempiere.m_warehouse w

JOIN adempiere.m_locator ml
    ON ml.m_warehouse_id = w.m_warehouse_id

JOIN adempiere.m_locatortype lt
    ON lt.m_locatortype_id = ml.m_locatortype_id

LEFT JOIN adempiere.pi_productlabel pl 
    ON pl.m_locator_id = ml.m_locator_id

WHERE
    ml.ad_client_id = 1000002
    AND w.name = 'Head Warehouse'

GROUP BY
    w.m_warehouse_id,
    w.name,
    ml.m_locatortype_id,
    ml.isdefault,
    lt.name,
    ml.value,
    ml.m_locator_id;