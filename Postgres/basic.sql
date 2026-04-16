find column list:-

SELECT column_name
FROM information_schema.columns
WHERE table_name = 'your_table_name';


select * from adempiere.pi_productlabel order by pi_productlabel_id desc
-- labeluuid = '6ced5543-16aa-492f-9d5d-7b3092501178'

INSERT INTO adempiere.pi_productlabel (
    ad_client_id,
    quantity,
    previouslocator,
    reservedfrom,
    reservedto,
    m_product_id,
    m_locator_id,
    c_orderline_id,
    restricteddate,
    actualqty,
    releasedate,
    m_inoutline_id,
    pi_productlabel_id,
    ad_org_id,
    created,
    createdby,
    updated,
    updatedby,
    release_comment,
    qcpassed,
    issotrx,
    isactive,
    labeluuid,
    pi_productlabel_uu,
    finaldispatch,
    reserved,
    remark,
    sales_return,
    description,
    isrestricted,
    restrict_comment
)
VALUES (
    1000000,           -- ad_client_id
    979,                 -- quantity (adjust if needed)
    NULL,              -- previouslocator
    NULL,              -- reservedfrom
    NULL,              -- reservedto
    1001106,           -- m_product_id
    1000512,           -- m_locator_id ✅ updated
    1019453,           -- c_orderline_id
    NULL,              -- restricteddate
    0,               -- actualqty
    NULL,              -- releasedate
    1036312,              -- m_inoutline_id
    1059198,           -- pi_productlabel_id
    1000000,           -- ad_org_id
    NOW(),             -- created
    1000013,           -- createdby
    NOW(),             -- updated
    1000001,           -- updatedby
    NULL,              -- release_comment
    'N',               -- qcpassed
    'Y',               -- issotrx ✅ updated
    'Y',               -- isactive
    'f9e8fb92-399a-4ff1-9ef8-e73b0153c844', -- labeluuid
    NULL,              -- pi_productlabel_uu
    'N',               -- finaldispatch
    'N',               -- reserved
    NULL,              -- remark
    'N',               -- sales_return
    NULL,              -- description
    'N',               -- isrestricted
    NULL               -- restrict_comment
);

UPDATE adempiere.pi_productlabel
SET m_locator_id = 1000512
WHERE pi_productlabel_id = 1046801;