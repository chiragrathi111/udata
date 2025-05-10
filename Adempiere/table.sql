Table:-
 CREATE TABLE adempiere.p_employer (
    p_employer_id NUMERIC(10,0) NOT NULL PRIMARY KEY,
    p_employer_uu VARCHAR(36) DEFAULT NULL::bpchar,
    ad_client_id NUMERIC(10, 0) NOT NULL,
    ad_org_id NUMERIC(10, 0) NOT NULL,
    name VARCHAR(25) NOT NULL,value varchar(25) NOT NULL,
    created TIMESTAMP without time zone DEFAULT now() not null,
    createdby numeric(10,0) not null,
    updated TIMESTAMP without time zone DEFAULT now() not null,
    updatedby NUMERIC(10,0) not null,
    description VARCHAR(255),
    isactive CHAR(1) not null DEFAULT 'Y'::bpchar,
    isdefault CHAR(1) NOT NULL DEFAULT 'N'::bpchar,
	villageName VARCHAR(25),
    block VARCHAR(20),
    District VARCHAR(10),
    City VARCHAR(20),
    State VARCHAR(20),
    pinCode VARCHAR(6),
    mobileNo VARCHAR(10)
	);

ALTER TABLE adempiere.p_employer
ADD COLUMN ad_image_id NUMERIC(10,0);

ALTER TABLE adempiere.p_employer
ADD CONSTRAINT p_employer_ad_image_id_fkey
FOREIGN KEY (ad_image_id)
REFERENCES adempiere.ad_image(ad_image_id);

Alter table adempiere.p_employer
Add column Role VARCHAR(20);

CREATE OR REPLACE VIEW adempiere.pv_employerView AS
SELECT p_employer_id AS Id,name AS Name,mobileNo AS MobileNo,villageName AS VillageName,block AS Block,City AS City,District AS District,
State AS State,pincode AS PinCode,ad_client_id AS ad_client_id,ad_org_id AS ad_org_id FROM adempiere.p_employer;

select * from adempiere.pv_employerView;


Alter table adempiere.p_employer Add column docaction CHAR(2) NOT NULL DEFAULT 'CO'::bpchar,
  Add column DocStatus CHAR(2) NOT NULL DEFAULT 'DR'::bpchar,
  add column processing CHAR(1) DEFAULT 'N'::bpchar,
  Add column processed character(1) NOT NULL DEFAULT 'N'::bpchar,
  Add column c_doctype_id numeric(10,0) NOT NULL DEFAULT 0,
  Add column c_doctypetarget_id numeric(10,0) NOT NULL DEFAULT 0,
  Add column isapproved character(1) NOT NULL DEFAULT 'Y'::bpchar;

===============================================================================================================================================
  CREATE TABLE pipra.p_employee (
    p_employee_id NUMERIC(10,0) NOT NULL PRIMARY KEY,
    p_employee_uu VARCHAR(36) DEFAULT NULL::bpchar,
    ad_client_id NUMERIC(10, 0) NOT NULL,
    ad_org_id NUMERIC(10, 0) NOT NULL,
    name VARCHAR(25) NOT NULL,value varchar(25) NOT NULL,
    created TIMESTAMP without time zone DEFAULT now() not null,
    createdby numeric(10,0) not null,
    updated TIMESTAMP without time zone DEFAULT now() not null,
    updatedby NUMERIC(10,0) not null,
    description VARCHAR(255),
    isactive CHAR(1) not null DEFAULT 'Y'::bpchar,
    isdefault CHAR(1) NOT NULL DEFAULT 'N'::bpchar);

  select e.name,e.value,u.name from pipra.p_employee e
  join adempiere.ad_user u on u.ad_user_id = e.createdby

  INSERT INTO pipra.p_employee (
    p_employee_id,
    p_employee_uu,
    ad_client_id,
    ad_org_id,
    name,
    value,
    createdby,
    updatedby,
    description,
    isactive,
    isdefault
) VALUES (
    1, -- p_employee_id (Primary Key)
    gen_random_uuid(), -- p_employee_uu (UUID can be generated if PostgreSQL has the `uuid-ossp` extension enabled)
    1000000, -- ad_client_id
    1000000, -- ad_org_id
    'John Doe', -- name
    'JD123', -- value
    100, -- createdby
    100, -- updatedby
    'Sample employee description', -- description
    'Y', -- isactive
    'N' -- isdefault
);

=====================================================================================================================

CREATE TABLE WarePro.c_mom (
c_mom_id numeric(10,0) NOT NULL PRIMARY KEY,
ad_client_id numeric(10,0) NOT NULL,
ad_org_id numeric(10,0) NOT NULL,
isactive character(1) DEFAULT 'Y'::bpchar NOT NULL,
created timestamp without time zone DEFAULT now() NOT NULL,
createdby numeric(10,0) NOT NULL,
updated timestamp without time zone DEFAULT now() NOT NULL,
updatedby numeric(10,0) NOT NULL,
value character varying(30) NOT NULL,
name character varying(255) NOT NULL,
start_date date NOT NULL,
start_time timestamp without time zone NOT NULL,
end_time timestamp without time zone NOT NULL,
chairperson character varying(80),
participants character varying(4000),
agenda character varying(4000),
discussion_detail character varying(8000));

ALTER TABLE adempiere.c_mom 
DROP COLUMN participants,
DROP COLUMN discussion_detail
ADD CONSTRAINT c_mom_c_mom_id_unique UNIQUE (c_mom_id);

CREATE TABLE adempiere.c_mom_discussionline (
c_mom_discussionline_id numeric(10,0) NOT NULL PRIMARY KEY,
c_mom_id numeric(10,0) NOT NULL,
ad_client_id numeric(10,0) NOT NULL,
ad_org_id numeric(10,0) NOT NULL,
isactive character(1) DEFAULT 'Y'::bpchar NOT NULL,
created timestamp without time zone DEFAULT now() NOT NULL,
createdby numeric(10,0) NOT NULL,
updated timestamp without time zone DEFAULT now() NOT NULL,
updatedby numeric(10,0) NOT NULL,
item_nbr numeric (10,0) NOT NULL,
discussion_desc character varying(2000),
status character varying(80),
FOREIGN KEY (c_mom_id) REFERENCES adempiere.c_mom(c_mom_id)
);

CREATE TABLE adempiere.c_mom_participantsline (
c_mom_participantsline_id numeric(10,0) NOT NULL PRIMARY KEY,
c_mom_id numeric(10,0) NOT NULL,
ad_client_id numeric(10,0) NOT NULL,
ad_org_id numeric(10,0) NOT NULL,
created timestamp without time zone DEFAULT now() NOT NULL,
createdby numeric(10,0) NOT NULL,
updated timestamp without time zone DEFAULT now() NOT NULL,
updatedby numeric(10,0) NOT NULL,
participant character varying(80),
company character varying(80) NOT NULL,
FOREIGN KEY (c_mom_id) REFERENCES adempiere.c_mom(c_mom_id)
);

ALTER TABLE adempiere.c_mom_participantsline ADD COLUMN ad_user_id NUMERIC(10,0) ;
ALTER TABLE adempiere.c_mom_participantsline
ADD CONSTRAINT c_mom_participantsline_ad_user_id_fkey
FOREIGN KEY (ad_user_id)
REFERENCES adempiere.ad_user(ad_user_id);

ALTER TABLE adempiere.c_mom_participantsline DROP COLUMN participant;

CREATE TABLE adempiere.c_mom_status (
    c_mom_status_id NUMERIC(10,0) NOT NULL PRIMARY KEY,
    c_mom_status_uu VARCHAR(36) DEFAULT NULL::bpchar,
    ad_client_id NUMERIC(10, 0) NOT NULL,
    ad_org_id NUMERIC(10, 0) NOT NULL,
    name varchar(25) NOT NULL,value character varying(40) NOT NULL,
    created TIMESTAMP without time zone DEFAULT now() not null,
    createdby numeric(10,0) not null,
    updated TIMESTAMP without time zone DEFAULT now() not null,
    updatedby NUMERIC(10,0) not null,
    description VARCHAR(255),
    isactive CHAR(1) not null DEFAULT 'Y'::bpchar,
  isdefault character(1) NOT NULL DEFAULT 'N'
);

ALTER TABLE adempiere.c_mom_discussionline ADD COLUMN c_mom_status_id NUMERIC(10,0) ;
ALTER TABLE adempiere.c_mom_discussionline
ADD CONSTRAINT c_mom_discussionline_c_mom_status_id_fkey
FOREIGN KEY (c_mom_status_id)
REFERENCES adempiere.c_mom_status(c_mom_status_id);


========================================================================
Create Report View :-

CREATE VIEW adempiere.c_mom_v AS
SELECT
a.*,
b.item_nbr,b.discussion_desc,b.actionedby AS actioned_by,b.c_mom_status_id,
c.ad_user_id AS participant,c.company,
d.name AS status
FROM adempiere.c_mom a
JOIN adempiere.c_mom_discussionline b ON a.c_mom_id=b.c_mom_id
JOIN adempiere.c_mom_participantsline c ON c.c_mom_id=b.c_mom_id
JOIN adempiere.c_mom_status d ON b.c_mom_status_id=d.c_mom_status_id;



DOC ACTION SETUP:-

ALTER TABLE adempiere.c_mom 
ADD COLUMN docaction CHAR(2) NOT NULL DEFAULT 'CO'::bpchar,
ADD COLUMN DocStatus CHAR(2) NOT NULL DEFAULT 'DR'::bpchar,
ADD COLUMN processing CHAR(1) DEFAULT 'N'::bpchar,
ADD COLUMN processed character(1) NOT NULL DEFAULT 'N'::bpchar,
ADD COLUMN c_doctype_id numeric(10,0) NOT NULL DEFAULT 0,
ADD COLUMN c_doctypetarget_id numeric(10,0) NOT NULL DEFAULT 0,
ADD COLUMN isapproved character(1) NOT NULL DEFAULT 'Y'::bpchar;

=======================================================================
10:22:38.429===========> CreateWindowFromTable.process: No column is defined as Parent Link, therefore, the table cannot be a detail tab. [167]
org.adempiere.exceptions.AdempiereException: No column is defined as Parent Link, therefore, the table cannot be a detail tab.
  at org.compiere.process.CreateWindowFromTable.doIt(CreateWindowFromTable.java:157)
  at org.compiere.process.SvrProcess.process(SvrProcess.java:256)
  at org.compiere.process.SvrProcess.startProcess(SvrProcess.java:164)
  at org.adempiere.util.ProcessUtil.startJavaProcess(ProcessUtil.java:173)
  at org.compiere.apps.AbstractProcessCtl.startProcess(AbstractProcessCtl.java:367)
  at org.compiere.apps.AbstractProcessCtl.run(AbstractProcessCtl.java:208)
  at org.adempiere.webui.apps.WProcessCtl.process(WProcessCtl.java:208)
  at org.adempiere.webui.apps.AbstractProcessDialog$ProcessDialogRunnable.doRun(AbstractProcessDialog.java:1369)
  at org.adempiere.util.ContextRunnable.run(ContextRunnable.java:44)
  at org.adempiere.webui.apps.DesktopRunnable.run(DesktopRunnable.java:67)
  at java.base/java.util.concurrent.Executors$RunnableAdapter.call(Executors.java:515)
  at java.base/java.util.concurrent.FutureTask.run(FutureTask.java:264)
  at java.base/java.util.concurrent.ScheduledThreadPoolExecutor$ScheduledFutureTask.run(ScheduledThreadPoolExecutor.java:304)
  at java.base/java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1128)
  at java.base/java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:628)
  at java.base/java.lang.Thread.run(Thread.java:829)


=====================================================================
CREATE TABLE WarePro.c_mom (
c_mom_id numeric(10,0) NOT NULL PRIMARY KEY,
ad_client_id numeric(10,0) NOT NULL,
ad_org_id numeric(10,0) NOT NULL,
isactive character(1) DEFAULT 'Y'::bpchar NOT NULL,
created timestamp without time zone DEFAULT now() NOT NULL,
createdby numeric(10,0) NOT NULL,
updated timestamp without time zone DEFAULT now() NOT NULL,
updatedby numeric(10,0) NOT NULL,
value character varying(30) NOT NULL,
name character varying(255) NOT NULL,
start_date date NOT NULL,
start_time timestamp without time zone NOT NULL,
end_time timestamp without time zone NOT NULL,
agenda character varying(4000),
ad_user_id NUMERIC(10,0),
docaction CHAR(2) NOT NULL DEFAULT 'CO'::bpchar,
DocStatus CHAR(2) NOT NULL DEFAULT 'DR'::bpchar,
processing CHAR(1) DEFAULT 'N'::bpchar,
processed character(1) NOT NULL DEFAULT 'N'::bpchar,
c_doctype_id numeric(10,0) NOT NULL DEFAULT 0,
c_doctypetarget_id numeric(10,0) NOT NULL DEFAULT 0,
isapproved character(1) NOT NULL DEFAULT 'Y'::bpchar
FOREIGN KEY (ad_user_id) REFERENCES adempiere.ad_user(ad_user_id));
