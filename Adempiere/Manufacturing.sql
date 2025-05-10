Manufacturing Order some modification:-

first go to git web:-
https://github.com/pshepetko/org.idempiere.mfg

download code and extract code 

go to web console OSGI and added idempiere 10 extract (extract-downloads-10)


last update database and first table added in system login and add table column

ALTER TABLE adempiere.PP_Order_BOMLine
ADD COLUMN QtyRequired NUMERIC;

    UPDATE adempiere.AD_Process 
 SET classname ='org.libero'||SUBSTRING(classname,15,70)
 WHERE SUBSTRING(classname,0,15) = 'org.eevolution';

 UPDATE adempiere.AD_Form 
 SET classname ='org.libero'||SUBSTRING(classname,15,70)
 WHERE SUBSTRING(classname,0,15) = 'org.eevolution';
 
 UPDATE adempiere.AD_Column  SET callout = null
 WHERE SUBSTRING(callout,0,21) = 'org.eevolution.model';
