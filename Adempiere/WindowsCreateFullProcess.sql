1. First Create a new table in Postgresql:-
    go to pgAdmin and open sql Editor and run the query for create table as below
    
CREATE TABLE adempiere.c_chirag (
c_chirag_id numeric(10,0) NOT NULL,
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

This query run and craete a successfully table.

2. Login to adempiere :-
	user :- Sysyem
	pass :- System
	
3. If choose you show Table and Column in Favourite list therwise
   search Table and Colume and choose	
   press new
4. Fill up details:-

DB Table Name - table same name                                                 
(only one time use table name, same name not use again time )  
Name	      - enter name
Active check box click
Data Access level - All
Records deletable check box click
Entity Type - User maintained
There is a save button in the top ,you have to press it.
There is a setting button in the top, you have to press it and 
 choose create Columns from DB
show the pop up box press enter ok button and show new pop up windows,
 this windows show Process completed successfully, enter right check box
show the all column in column screen
This process will be completed.

5. If choose you show Window, Tab & Field in Favourite list otherwise
   search Window, Tab & Field and choose 
   press new
6. Fill up details:-

Name     - enter a name for windows display
Des.     - enter if any required   
Active check box click
Window Type - Maintain
Entity Type - User maintained
There is a save button in the top ,you have to press it.
There is a tab button in the bottem, you have to press + sign
Fill up Details:-
Name :- any name (This name enter Capital letter and short word because this name show Prefix in tab name like (CHI_new windoes))
des. - 
Table - choose your table name
 (you create Table and Colume Name with merge windows name show) 
unchecked Single Row Layout
There is a save button in the top, you have to press it.
There is a Create Fields in the bottom, you have to press it. 
Show the pop up windows and press ok button
Show the pop windows Process completed successfully and enter right button
If you are any requirement to change Field Sequences otherwise not changed.
 
7. Search a menu and press + icon (create a menu)

8. Fill up details:-

Name - 
des - 
Active check box click
Entity Type - User maintained
Action - choose Window
Window - choose your windows
Unchecked sales transation
There is a save button in the top ,you have to press it.
You are pressed save button and menu name you are created,
but this menu name not show menu tree.

9. Change Role and enter ok same login and role this process will be completed
	This will show the created menu name in Menu tree
	
Windows create Completed.	





=========================================================================================================
Creating a read-only window :-

Go to Window,Tab and filed and choose your windows to gave read only permission
Window Type - Query Only

save and change role and again login go to same menu and see disable add and delete option


==========================================================================================================
Creating a read-only tab :-
Their Two type :-
1. All user gave Read only permission
   check box Read only
2. Seperate user give only read only permission
   Read only logic - @#AD_Role_Name@='GardenWorld User' (which user provide see only read only permission)


===========================================================================================================
Creating read-only fields :-
Window->Tab->Fields
If you are choose field only , Read only Both option check Table Column name not show


===========================================================================================================
Populating the combo-box list :-
Two Table is linked second table database show first table combo box some important step

Starting craete a table 

CREATE TABLE adempiere.c_mom_discussionline (
c_mom_discussionline_id numeric(10,0) NOT NULL,
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
ad_user_id numeric(10),
status character varying(80),
CONSTRAINT cmom_cdiscussionline FOREIGN KEY (c_mom_id)
REFERENCES adempiere.c_mom (c_mom_id) MATCH SIMPLE
ON UPDATE NO ACTION ON DELETE NO ACTION DEFERRABLE INITIALLY
DEFERRED,
CONSTRAINT cmomdl_aduser FOREIGN KEY (ad_user_id)
REFERENCES adempiere.ad_user (ad_user_id) MATCH SIMPLE
ON UPDATE NO ACTION ON DELETE NO ACTION DEFERRABLE INITIALLY
DEFERRED
);

after time alter the table:-
ALTER TABLE adempiere.c_mom_discussionline DROP COLUMN status;

Create Status table :-

CREATE TABLE adempiere.c_momstatus
(
c_momstatus_id numeric(10) NOT NULL,
ad_client_id numeric(10) NOT NULL,
ad_org_id numeric(10) NOT NULL,
isactive character(1) NOT NULL DEFAULT 'Y'::bpchar,
created timestamp without time zone NOT NULL DEFAULT now(),
createdby numeric(10) NOT NULL,
updated timestamp without time zone NOT NULL DEFAULT now(),
updatedby numeric(10) NOT NULL,
"name" character varying(60) NOT NULL,
description character varying(255),
isdefault character(1) NOT NULL DEFAULT 'N'::bpchar,
"value" character varying(40) NOT NULL,
CONSTRAINT c_momstatus_pkey PRIMARY KEY (c_momstatus_id),
CONSTRAINT c_momstatus_isactive_check CHECK (isactive = ANY
(ARRAY['Y'::bpchar, 'N'::bpchar]))
);

create a new colume concinact new table ;-
ALTER TABLE adempiere.c_mom_discussionline ADD COLUMN c_momstatus_id numeric(10);

This line completed after this line working

ALTER TABLE adempiere.c_mom_discussionline ADD CONSTRAINT cmomdl_c_momstatus FOREIGN KEY (c_momstatus_id) 
REFERENCES adempiere.c_momstatus (c_momstatus_id) MATCH SIMPLE ON UPDATE NO ACTION ON
DELETE NO ACTION DEFERRABLE INITIALLY DEFERRED

c_momstatus table ka Table and Colume created and Windows,Tab and Filed also created and Menu also created

 If choose you show Reference in Favourite list otherwise
   search Reference and choose 
   press new

 Reference  :- Fill up details
 
 Name -
 Entity type - User maintained
 Validation type - table Validation

 Table Validation :- Fill up details

 Table - choose valid table
 key column - same
 display column - Name
 Entity type - User maintained
 Seq order by - c_momstatus.Name (table name and . Name)
 Window - choose window name

 Go to Table and window :-
 choose c_mom_discussionline table and go to column
 choose c_momstatus_Id and go to edit option
 Reference - Table
 Reference key - choose the MOM_Status

 created Menu by MOM status and fill up this windows 
 chnage role and again login
 show menu tree MOM Status
 enter MOM Status and enter 3-4 Records (because jitna record status mai dalenge utna combo box mai show hoga)


 change role and again login
 go to Minutes Of Meeting menu and enter the c_mom_discussionline record
 you see status box mai combo box show hoga or usme sara details jo records menu ke status mai add kiye the wahi hota hai.


 ========================================================================================================================================
 Creating a new menu tree :-

 login with System 

create a menu folder :-

Name -
Please check Summery Level otherwise create menu only file not a Folder


Create menu is Bold formet another menu easily drag and drop working and working menu tree formet.

========================================================================================================================================
Alter a existing table colume give a default value:-

ALTER TABLE [table name] ADD DEFAULT [DEFAULT VALUE] FOR [NAME OF COLUMN]






	


 
