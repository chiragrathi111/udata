Insert message Records:-

INSERT INTO AD_Message (
AD_Message_ID,AD_Client_ID,AD_Org_ID,IsActive,Created,CreatedBy,Updated,UpdatedBy,Value,MsgText,MsgTip,EntityType,MsgType)
VALUES (
523855,0,0,'Y',now(),100,now(),100,'SalesPlanList','Sales plan completed & pending list',
'This message appears after report generation.','U','I');

select * from adempiere.AD_Message order by AD_Message_id desc;