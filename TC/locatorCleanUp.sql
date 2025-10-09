Deleted Locator:-

DELETE FROM adempiere.fact_acct WHERE M_Locator_ID = 1001872;
DELETE FROM adempiere.m_inventoryline WHERE M_Locator_ID = 1001872;
DELETE FROM adempiere.M_Locator WHERE M_Locator_ID = 1001872;

DELETE FROM adempiere.m_inventoryline WHERE M_Locator_ID = 1000001;
DELETE FROM adempiere.fact_acct WHERE M_Locator_ID = 1000002;
DELETE FROM adempiere.m_transaction WHERE M_Locator_ID = 1000002;
DELETE FROM adempiere.m_inoutline WHERE M_Locator_ID = 1000002;
DELETE FROM adempiere.m_movementline WHERE M_Locator_ID = 1000002;
====================================================================================
Deleted Warehouse:-

DELETE FROM adempiere.M_Locator WHERE M_Warehouse_ID = 1000043;
DELETE FROM adempiere.M_Replenish WHERE M_Warehouse_ID = 1000043;
DELETE FROM adempiere.C_BPartner_Location WHERE M_Warehouse_ID = 1000043;
DELETE FROM adempiere.M_Warehouse_Routing WHERE M_Warehouse_ID = 1000043;
DELETE FROM adempiere.M_Warehouse_Acct WHERE M_Warehouse_ID = 1000043;

DELETE FROM adempiere.M_Warehouse WHERE M_Warehouse_ID = 1000043;
====================================================================================	