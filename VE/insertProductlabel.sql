insert product label records:- 
INSERT INTO adempiere.pi_productlabel (
	 pi_productlabel_id,
    ad_client_id,
    ad_org_id,
    created,
    createdby,
    updated,
    updatedby,
    isactive,
    quantity,
    m_product_id,
    m_locator_id,
    c_orderline_id,
    m_inoutline_id,
    issotrx,
    qcpassed,
    labeluuid
) VALUES (
	1055172,
    1000000,                 -- AD_Client_ID
    1000000,                 -- AD_Org_ID
    NOW(),                   -- Created
    1000003,                 -- CreatedBy
    NOW(),                   -- Updated
    1000003,                 -- UpdatedBy
    'Y',                     -- IsActive
    11,                      -- Quantity
    1000003,                 -- M_Product_ID
    1000512,                 -- M_Locator_ID
    1018557,                 -- C_OrderLine_ID
    1033976,                 -- M_InOutLine_ID
    'Y',                     -- IsSOTrx
    'Y',                     -- QC Passed
    'e08901a2-33ad-4fe5-a15e-409963e81c7a'  -- LabelUUID
);