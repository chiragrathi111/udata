Update product label locator:-

UPDATE adempiere.pi_productlabel
SET m_locator_id = 1000512,
    Updated = now(),
    UpdatedBy = 100
WHERE pi_productlabel_id = 1055625;