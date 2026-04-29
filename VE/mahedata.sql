
demo server:
 pem file is same
ssh -i "Downloads/democ.pem" ubuntu@43.205.103.6
https://43.205.103.6:8443/

Layer100-- server:
 pem file is same
ssh -i "Downloads/democ.pem" ubuntu@13.234.12.89
https://13.234.12.89:8443/

Vinay Electricals-- server:
 pem file is same
ssh -i "Downloads/democ.pem" ubuntu@13.235.255.17
https://13.235.255.17:8443/


superuser @ idempiere.com

===================================================================================================================================
dev Warepro server ( maintained by Pipra)
===================================================================================================================================
  https://3.7.97.129:9444/webui/


To connect with Terminal:
--------------------------
ssh -i Documents/Pem_Files/democ.pem ubuntu@3.7.97.129


dev second url:
---------------
https://dev.erp.warepro.in/webui/

To connect warepro dev server db from eclipse/ postgres:
-----------------------------------------------------
host/addres: 3.7.97.129
port: 5432
user: adempiere
pwd: Welcome@1278
db: erp

get data from sever:
scp -i Documents/Pem_Files/democ.pem ubuntu@3.7.97.129:/home/ubuntu/Dumps/erp.dmp /home/mahe/Dumps/

java -cp /home/mahe/Documents/Jar_Files/xmlbeans-3.1.0.jar org.apache.xmlbeans.impl.tool.SchemaCompiler -javasource 11 -out lib/idempiere-xmlbeans.jar WEB-INF/xsd/idempiere-schema.xsd

scp -i /home/mahe/Downloads/democ.pem /home/mahe/pipra/wms/3DLayout/3DLayoutDemoInstance.zip ubuntu@3.7.97.129:/home/ubuntu/repos


===================================================================================================================================
stonex DEV ( maintained by Pipra)
===================================================================================================================================
https://51.112.195.182:8443/webui/

To connect with Terminal:
--------------------------
ssh -i Documents/Pem_Files/democ.pem ubuntu@51.112.195.182

 ip => 51.112.195.182

To connect warepro dev server db from eclipse/ postgres:
-----------------------------------------------------
host/addres: 51.112.195.182
port: 5432
user: adempiere
pwd: Welcome@1278
db: stonex_dev

send data to server
----------------------

scp -i /home/mahe/Documents/Pem_Files/democ.pem /home/mahe/Downloads/serverCode/download1.deb ubuntu@51.112.195.182:/home/ubuntu/WarePro
scp -i /home/mahe/Documents/Pem_Files/defluttermoc.pem /home/mahe/Downloads/ExpDat.dmp ubuntu@51.112.195.182:/home/ubuntu/WarePro

get data from server
----------------------
scp -i Documents/Pem_Files/democ.pem ubuntu@51.112.195.182:/home/ubuntu/Dumps/stonex_dev.dmp /home/mahe/Documents/Dumps/

make dump
----------
 pg_dump -U adempiere -W stonex_dev > stonex_dev.dmp

java -cp /home/mahe/Downloads/xmlbeans-3.1.0.jar org.apache.xmlbeans.impl.tool.SchemaCompiler -javasource 11 -out lib/stonex-xmlbeans.jar WEB-INF/xsd/stonex.xsd

Stonex dev urls
https://stonex.warepro.in/webui
https://stonex.warepro.in/dev

===================================================================================================================================
stonex  QA ( maintained by Pipra)
===================================================================================================================================

https://3.29.236.151:8443/webui/



To connect with Terminal:
--------------------------
ssh -i Documents/Pem_Files/democ.pem ubuntu@3.29.236.151


To connect warepro dev server db from eclipse/ postgres:
-----------------------------------------------------
host/addres: 3.29.236.151
port: 5432
user: adempiere
pwd: Welcome@1278
db: stonex_qa

send to server:
--------------------
scp -i /home/mahe/Documents/Pem_Files/democ.pem /home/mahe/Dumps/stonex_dev13.dmp ubuntu@3.29.236.151:/home/ubuntu/WarePro
scp -i /home/mahe/Documents/Pem_Files/democ.pem /home/mahe/Downloads/ExpDat.dmp ubuntu@3.29.236.151:/home/ubuntu/WarePro

get data from server
----------------------
scp -i /home/mahe/Documents/Pem_Files/democ.pem ubuntu@3.29.236.151:/home/ubuntu/Dumps/stonex_dev5.dmp /home/mahe/Dumps/


java -cp /home/mahe/Downloads/xmlbeans-3.1.0.jar org.apache.xmlbeans.impl.tool.SchemaCompiler -javasource 11 -out lib/stonex-xmlbeans.jar WEB-INF/xsd/stonex.xsd

===================================================================================================================================
Pipra ERP Dev server ( maintained by Pipra)
===================================================================================================================================
https://65.1.73.20:8443/webui/

To connect with Terminal:
--------------------------
ssh -i "Downloads/democ.pem" ubuntu@65.1.73.20


To connect Pipra CRM server db from eclipse/ postgres:
-----------------------------------------------------
host/addres: 65.1.73.20
port: 5432
user: adempiere
pwd: Welcome@1278
db: erp_dev

for new db or template db pipra_erp_template.dmp in Dumps folder

TO make Dump:
 pg_dump -U adempiere -W erp_dev > pipra_erp_template.dmp


get data from server
----------------------
scp -i "Downloads/democ.pem" ubuntu@65.1.73.20:/home/ubuntu/Dumps/pipraErp8.dmp /home/mahe/Dumps/

xsd:
----

java -cp /home/mahe/Downloads/xmlbeans-3.1.0.jar org.apache.xmlbeans.impl.tool.SchemaCompiler -javasource 11 -out lib/crm.jar WEB-INF/xsd/crm.xsd

===================================================================================================================================
Pipra ERP Prod  server ( maintained by Pipra)
===================================================================================================================================
https://13.233.118.16:8443/webui/

To connect with Terminal:
--------------------------
ssh -i "Downloads/democ.pem" ubuntu@13.233.118.16


To connect Pipra CRM server db from eclipse/ postgres:
-----------------------------------------------------
host/addres: 13.233.118.16
port: 5432
user: adempiere
pwd: Welcome@1278
db: pipraErp

TO make Dump:
 pg_dump -U adempiere -W erp_prod > pipra_erp_prod1.dmp


get data from server
----------------------
scp -i "Downloads/democ.pem" ubuntu@13.233.118.16:/home/ubuntu/Dumps/pipra_erp_prod1.dmp /home/mahe/Dumps/

xsd:
----

java -cp /home/mahe/Downloads/xmlbeans-3.1.0.jar org.apache.xmlbeans.impl.tool.SchemaCompiler -javasource 11 -out lib/crm.jar WEB-INF/xsd/crm.xsd

===================================================================================================================================
Vinay DEV Electricals Dev server (maintained by pipra):
===================================================================================================================================


https://188.241.187.186:8443/webui/
ssh details - 
Ip: 188.241.187.186
User : root

ssh root@188.241.187.186

Password: >9J[?PV3r[175^Iu


App Domain: https://dev.warepro.vinayelectricals.com/webui


===================================================================================================================================
RWPL Dev Server (Maintained by Pipra)
===================================================================================================================================

https://13.201.124.210:8443/webui/

To connect with Terminal:
--------------------------
ssh -i Documents/Pem_Files/rwpl-warepro.pem ubuntu@13.201.124.210


To connect in Eclipse:
----------------------
 host: 13.201.124.210

running db in dev: rwplcr26

 uName: adempiere
 pwd: Welcome@1278
 dbName:  rwplcr26

 pg_dump -U adempiere -W  rwplcr26 > rwpl_dev17.dmp

scp -i Documents/Pem_Files/rwpl-warepro.pem ubuntu@13.201.124.210:/home/ubuntu/DMP/rwpl_dev17.dmp /home/mahe/Dumps/


scomp -javasource 11 -out lib/rwpl-xmlbeans.jar WEB-INF/xsd/rwpl.xsd

java -cp /home/mahe/Documents/Jar_Files/xmlbeans-3.1.0.jar org.apache.xmlbeans.impl.tool.SchemaCompiler -javasource 11 -out lib/rwpl-xmlbeans.jar WEB-INF/xsd/rwpl.xsd

get Data from server:
---------------------
scp -i Documents/Pem_Files/rwpl-warepro.pem ubuntu@15.207.222.3:/home/ubuntu/Dumps/rwpl_dev1.dmp /home/mahe/Documents/Dumps

scp -i /home/mahe/Downloads/rwpl-warepro.pem /home/mahe/pipra/whgen-28-10-2024.zip  ubuntu@52.66.247.45:/home/ubuntu/WarePro/
 scp -i /home/mahe/Downloads/rwpl-warepro.pem /home/mahe/pipra/RWPL3DLayout.zip    ubuntu@52.66.247.45:/opt/idempiere-server/plugins

send base jar file:
scp -i /home/mahe/Downloads/rwpl-warepro.pem /home/mahe/pipra/wms/idempiere-release-10/org.adempiere.base/target/org.adempiere.base-10.0.0-SNAPSHOT.jar ubuntu@52.66.247.45:/home/ubuntu/Dumps/

===================================================================================================================================
RWPL Prod Server (Maintained by RWpl) (Created By Pipra)
===================================================================================================================================

https://15.206.25.170:8443/webui/

To connect with Terminal:
--------------------------
ssh -i Documents/Pem_Files/rwpl-warepro.pem ubuntu@15.206.25.170

To connect in Eclipse:
----------------------
 host: 15.206.25.170

running db in prod: rwpl_prod

ec2-15-206-25-170.ap-south-1.compute.amazonaws.com
 uName: adempiere
 pwd: Welcome@1278
 dbName: rwpl_prod

 pg_dump -U adempiere -W rwpl_prod > rwpl_prod.dmp


get Data from server:
---------------------
scp -i "Downloads/rwpl-warepro.pem" ubuntu@15.206.25.170:/home/ubuntu/DMP/rwpl_prod1.dmp /home/mahe/Dumps/


scp -i /home/mahe/Downloads/rwpl-warepro.pem /home/mahe/pipra/whgen-28-10-2024.zip  ubuntu@15.206.25.170:/home/ubuntu/WarePro/
 scp -i /home/mahe/Downloads/rwpl-warepro.pem /home/mahe/pipra/RWPL3DLayout.zip    ubuntu@15.206.25.170:/home/ubuntu/WarePro/


===================================================================================================================================
vinay client server (Production server maintained by Vinay Electricals Team)
===================================================================================================================================
https://ve.warepro.in/webui/index.zul

old server ip
---------------------
  https:/45.120.138.56:8443/


new server:
-----------------------
https:/45.120.138.56:8443/


To connect in Eclipse:
----------------------
 45.120.138.56
 uName: adempiere
 pwd: Welcome@1278
 dbName: vinayERP

To connect with Terminal:
--------------------------
ssh -l root 45.120.138.56
RootPassword: l__3rVXT#aX-
Main IP: 45.120.138.56

pg_dump -U adempiere -W vinayERP > vinayERP.dmp

to send vinay client server:
scp /home/mahe/Downloads/serverCode/download1.deb root@445.120.138.56:/root/WarePro/
scp /home/mahe/pipra/whgen-28-10-2024.zip root@45.120.137.143:/root/WarePro/

get Data from server:
---------------------
scp root@45.120.138.56:/root/Dumps/vinayERPNew.dmp /home/mahe/Documents/Dumps


send data to vinay dev server:
---------------------------------------
scp /home/mahe/Documents/Dumps/vinayERPNew.dmp root@188.241.187.186:/root/warepro/



vinay new server
Server IP: 45.120.138.56
Username: root
Password: l__3rVXT#aX-


scp -i /home/mahe/Downloads/democ.pem /home/mahe/Downloads/ExpDat.dmp ubuntu@43.205.103.6:/home/ubuntu/WarePro
scp /home/mahe/Documents/Dumps/vinayERP1.dmp root@188.241.187.186:/root/warepro/

scp root@45.120.138.56:/root/Dumps/vinayERP1.dmp /home/mahe/Documents/Dumps


===================================================================================================================================
tissue culture URL:
===================================================================================================================================

https://3.111.186.59:8443/webui/

ssh -i Documents/Pem_Files/democ.pem ubuntu@3.111.186.59

scp -i Documents/Pem_Files/democ.pem ubuntu@3.111.186.59:/home/ubuntu/erptc25-11.dmp /home/mahe/Documents/Dumps

===================================================================================================================================
 ssh -i "Downloads/democ.pem" ubuntu@13.233.84.2

database name = veErp

  scp -i /home/mahe/Downloads/democ.pem /home/mahe/Downloads/ExpDat.dmp ubuntu@13.235.255.17:/home/ubuntu/WarePro
  
scp -i /home/mahe/Downloads/democ.pem /home/mahe/Downloads/ExpDat.dmp ubuntu@13.234.12.89:/home/ubuntu/WarePro

psql
databse passs: Ajit@2018
\c erp

------------------------------------------------------------------------------------
universal free idempiere url

https://demo.globalqss.com/webui/
 uname: GardenAdmin
 pass: GardenAdmin

-------------------------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------------------------------------------

for jetty-hht propblems rename this file to orginal;
/home/mahe/.m2/repository/org/eclipse/jetty/tests/jetty-http-tools/10.0.9

change jetty-http-tools-10.0.9.pom.lastUpdated to jetty-http-tools-10.0.9.pom
-----------------------------------------------------------------------------------------


connect with vnc:
 ssh -i "Downloads/democ.pem" -L 5901:localhost:5901 ubuntu@3.7.97.129 -N

copy jar from server:
scp -i "Downloads/democ.pem" ubuntu@3.7.97.129:/opt/idempiere-server/plugins/org.idempiere.webservices_10.0.0.202307151203.jar /home/mahe/websevicePluginMain/
scp -i "Downloads/democ.pem" ubuntu@3.7.97.129:/home/ubuntu/WareProDemo/download1.deb /home/mahe/

scp -i "Downloads/democ.pem" ubuntu@3.7.97.129:/home/ubuntu//opt/idempiere-server/log/idempiere_20231208090143.log /home/mahe/


send jar to server
scp -i /home/mahe/Downloads/democ.pem /home/mahe/Downloads/whgen\ \(1\).zip  ubuntu@13.233.84.2:/home/ubuntu/repos/
scp -i /home/mahe/Downloads/democ.pem /home/mahe/download1.deb ubuntu@43.205.103.6:/home/ubuntu/WarePro/


org.idempiere.webservices_10.0.0.202307151203.jar
        
stop idempiere:
 sudo service idempiere stop
start idempiere: 
 sudo service idempiere start 

idempiere server url:
https://ec2-3-7-97-129.ap-south-1.compute.amazonaws.com:9444/webui/index.zul

keystore pwd:
myPassword

---------------------------------------------------------------------------------------------------------
to import whole database from server:
pg_dump -U adempiere erpVe > data.sql
pg_dump -U adempiere -W erpVe > /home/chirag/datave.dmp


postgres

pg_dump -U adempiere rwpl > DMP/rwpl5.dmp
scp -i "Downloads/rwpl-warepro.pem" ubuntu@15.206.25.170:/home/ubuntu/DMP/rwpl5.dmp /home/mahe/Dumps


scp -i "Downloads/democ.pem" ubuntu@13.235.255.17:/home/ubuntu/data.sql /home/mahe/Dumps

change data.sql to data.dmp

cp data.sql data.dmp

Welcome@1278 -> erp

create database
password of adempiere: @Mahe17191719
create db:

pg_dump -U adempiere -W Test11 > /home/mahe/Dumps/Test11.dmp
scp root@45.120.137.143:/home/root/Dumps/vinay.dmp /home/mahe/Dumps/


create database postgres

createdb  --template=template0 -E UNICODE -O adempiere -U adempiere stonex_dev17
psql -d stonex_dev17 -U adempiere -c "ALTER ROLE adempiere SET search_path TO adempiere, pg_catalog"
psql -d stonex_dev17 -U adempiere -c 'CREATE EXTENSION "uuid-ossp"' 
psql -d stonex_dev17 -U adempiere -f /home/mahe/Documents/Dumps/stonex_dev.dmp
or
rwpl_prod1

psql -d Test11 -U adempiere -f Downloads/ExpDat.dmp


 pg_dump -U adempiere -W rwpl_prod > rwpl_prod.dmp

pg_dump -U adempiere -W stonex_dev > /home/mahe/Dumps/erpNew.dmp
scp root@45.120.137.143:/home/root/Dumps/vinay.dmp /home/mahe/Dumps/


createdb  --template=template0 -E UNICODE -O adempiere -U adempiere stonex_dev3
psql -d stonex_dev3 -U adempiere -c "ALTER ROLE adempiere SET search_path TO adempiere, pg_catalog"
psql -d stonex_dev3 -U adempiere -c 'CREATE EXTENSION "uuid-ossp"'
psql -d stonex_dev3 -U adempiere -f  /home/mahe/Documents/Dumps/stonex_dev3.dmp

postgres
Welcome@1278
@Mahe17191719


use this pg_restore when we taken as backup
pg_restore -d stonex_dev1 -U adempiere -W stonex_dev1.dmp

---------------------------------------------------------------------------------------------------

getvar.sh or setVar.sh problem:
give sudo permissions-
sudo chmod +x getVar.sh

prblms after Reload Target Platform
from terminal in idempiere dir
mvn verify

java -v for idempiere:
java 11

to re download xsd in webservices:
scomp -javasource 11 -out lib/idempiere-xmlbeans.jar WEB-INF/xsd/idempiere-schema.xsd

if any prblm occurs download jar from chrome and execute
java -cp /home/mahe/Downloads/xmlbeans-3.1.0.jar org.apache.xmlbeans.impl.tool.SchemaCompiler -javasource 11 -out lib/idempiere-xmlbeans.jar WEB-INF/xsd/idempiere-schema.xsd

===================================================================================================================================
vinay electricals plugin :
===================================================================================================================================
java -cp /home/mahe/Documents/Jar_Files/xmlbeans-3.1.0.jar org.apache.xmlbeans.impl.tool.SchemaCompiler -javasource 11 -out lib/ve-xmlbeans.jar WEB-INF/xsd/ve.xsd


===================================================================================================================================
RWPL Plugin
===================================================================================================================================

java -cp /home/mahe/Documents/Jar_Files/xmlbeans-3.1.0.jar org.apache.xmlbeans.impl.tool.SchemaCompiler -javasource 11 -out lib/rwpl-xmlbeans.jar WEB-INF/xsd/rwpl.xsd
===================================================================================================================================


------------


connect ve server in eclipse or pg admin

Datebase server: ec2-13-235-255-17.ap-south-1.compute.amazonaws.com
Datebase name : erpVe
Datebase port : 5432
use: adempiere
pass: Welcome@1278


server database credentials:
 uName: adempiere
 pwd: Welcome@1278
 dbName: erp


connect to postgres:
 sudo su postgres
connect to psq:
 psql
connect to erp:
 \c erp

      flow:
   ------------
* Login.zul-> AdempiereWebUI.java -> (by onCreate() method)
                     ||
                     --
           --> WLogin.java -> (doCreatePart() method) ->>-------------------------
                     ||                                                          |
                     --                                                          |
           --> LoginWindow.java ->(by constructor)                               |
                     ||                                                          |
                     --                                                          |
           --> LoginPanel.java ->(by constrcutor ececute and validates fields)   |
                                                                                 |
                                                                                 | 
                                                                                 |
                                                   ------------------------------|
                                                   ||
                                                   --
                                      --> Creating layout by methods:

                                              a. getWest()
                                              b. getEast()
                                              c. getSouth()
                                              d. getNorth()

  Add widget:

flow of purchase order:
1. purchase order to vendor (to confirm order)
2. material reciper (to confirm material received)
3. invoice vendor(to confitm order recieved)
4. payemt AP(account payable)->(to send monehy)

for sales order:
1. sales order
2. shipment
3. invoice
4. payment


  Tasks:
1. widget --------------------> work in progress
2.forgot password
3.jasper report


report attactchment:
  org.adempiere.report.jasper.ReportStarter
  attachment:mahe.jasper
  Record_ID


 pending on widgets:
  1. transaction today:
    a. picks
    b. qa rejections
  2. basic stats
    a. stock check
    DPReturns


1. if we remove quantity directl from physical inventry, then it cause tracing problem after ages.
2. if same product available in in two loadempiere.ad_viewcolumn where ad_viewcomponent_id=200164 and columnname = 'QtyRequiered';ts in same locator,
  example: in locator-A:

           lot -1 = 50 items
           lot -2 = 50 items
        in physical inventory it shows directly 100, if we remove 20, from which lot it will remove, FIFO?

3. sales order doc action completed
   a. in customer shipment customer do qc fail, not working
   b. what if customer is not accepting order, 
     -> how many days it will be hold?
     -> can he reject order?
     -> can sales order be reverted?


1. drafted material receipt api
2. details of recipt line
3. create creat confirm

4. doc action complete





mvn verify -o :- will work in jetty prblms
mvn clean install -o : to install or  mvn Verify -U - SUCCESS


The correct syntax for faster build is "mvn verify --offline".

and for the most efficient approach (you can save that as a script):
mvn verify --offline -DskipClean=true -DmaterializeProduct=none

   
List of items noted from Iteration 2 discussion meeting for 3PL & D2C part

3PL (3rd Party Logistics) Requirements
- Different customers (multiple clients storing products in warehouse)
- Pricing for each client to use the facilities of warehouse
- Reserved locators
- Ability to have different subscription models of pricing
- Client Portal - ability to view and perform basic actions like invoices etc
- Reverse logistics (not immediate for expo)

D2C (Direct to Customer) Requirements
2 main aspects to be covered
01. Integration with external Portal 
- E commerce portal integration (Dependent on customer)
- Orders need to flow into system
- Actual users are outside system (not already added)
- User & order to be created at the point of data incoming from external portal

- Visibility -> multiple status of order


3PL (3rd Party Logistics) Requirements
- Different customers (multiple clients storing products in warehouse):
     => customers is clients, multiple clients can store in single warehouse
- Pricing for each client to use the facilities of warehouse
       
- Reserved locators
- Ability to have different subscription models of pricing
- Client Portal - ability to view and perform basic actions like invoices etc
- Reverse logistics (not immediate for expo)


o.expirydate >= CURRENT_DATE
    AND o.expirydate <= CURRENT_DATE + INTERVAL '4 months' AND o.AD_Client_ID=@#AD_Client_ID@ AND o.ExpiryQTY != 0


    by role we need to define supervisor and labour



    should pass documentNo in po data by id => fixed

get mr data by id should give m_inout_id


1. physical stock check (prepared) list : 1 day (04-/11) chirag
2. physycal stock check details:  1 day (04-/11) mahendhar
3. physical stock check(update qnty): 2 day(06-/11) chirag /mahendar
4. physical stock check doc complete api : completed


To install tunnel for https:
-------------------------------------------------------------------------------------------
Quickstart
Install Localtunnel globally (requires NodeJS) to make it accessible anywhere:

npm install -g localtunnel
Explain
Start a webserver on some local port (eg http://localhost:8000) and use the command line interface to request a tunnel to your local server:

touch /home/ubuntu/whgenLogs.txt
nohup lt --port 3000 > /home/ubuntu/whgenLogs.txt 2>&1 &

lt --port 8000
Explain
You will receive a url, for example https://flkajsfljas.loca.lt, that you can share with anyone for as long as your local instance of lt remains active. Any requests will be routed to your local service at the specified port.
--------------------

To get your tunnel password, you can either:

If running the localtunnel client on a local computer, visit this link in a web browser on that PC or any other PC on the same network: https://loca.lt/mytunnelpassword

If running the localtunnel client on a remote computer, ssh into the remote computer and run one of the following:
curl https://loca.lt/mytunnelpassword or wget -q -O - https://loca.lt/mytunnelpassword

-------------------------------------------------------


run whgen in local (3D layout widget):
--------------
npm use 14
npx serve .

--------------------------------------

for pilferage events:
nohup uvicorn main:app --reload > uvicorn_output.log 2>&1 &

nohup python test_job.py > test_job_output.log 2>&1 &


To run whgen in server:
 nohup npx serve . &

to kill:

ps aux | grep 'npx serve'
kill -9 2926439[replace with pid]

------------------------------------------------------
move labels:

UPDATE adempiere.pi_productLabel
SET m_locator_ID = 1000891
WHERE issotrx = 'Y' AND m_locator_ID IN (1000895, 10008920);

---------------------------------------------------------------------------------------------------

create maven project in idempiere:
 ------------
 https://wiki.idempiere.org/en/Developing_plug-ins_without_affecting_the_trunk#:~:text=DB%20Seed%20Manually-,The%20workflow,%3EOther...%22.&text=Give%20the%20new%20project%20a,%22Use%20default%20location%22%20checkbox.

 https://wiki.idempiere.org/en/Developing_plug-ins_without_affecting_the_trun
 
 https://codeandme.blogspot.com/2012/12/tycho-build-1-building-plug-ins.html


 jwt idempiere:

 https://developers.google.com/identity/protocols/oauth2/service-account#httprest

---------------------

 idempiere consultant:

 org.idempiere.mf2:
 https://github.com/logilite

 --------------------
 org.idempiere.mfg:
  https://github.com/pshepetko/org.idempiere.mfg


-- To run libero manufacturing plugin, these changes is required

ALTER TABLE adempiere.PP_Order_BOMLine RENAME COLUMN QtyRequiered TO QtyRequired;
UPDATE adempiere.AD_Element SET columnname = 'QtyRequired' WHERE AD_Element_id = 53288;
UPDATE adempiere.AD_Column SET columnname = 'QtyRequired' WHERE AD_Column_id = 53584;

UPDATE adempiere.ad_viewcolumn SET columnsql ='round(obl.qtyrequired, 4)' , columnname = 'QtyRequired' where ad_viewcomponent_id=200164 and columnname = 'QtyRequiered';

UPDATE adempiere.ad_viewcolumn SET columnsql = 'CASE WHEN o.qtybatchs = 0 THEN 1 ELSE round(obl.qtyrequired / o.qtybatchs, 4) END' where ad_viewcolumn_id=215723 and columnname = 'QtyBatchSize';

UPDATE adempiere.ad_viewcolumn SET columnsql ='obl.qtyrequired' , columnname = 'QtyRequired' where ad_viewcolumn_id=215693 and columnname = 'QtyRequiered';

-- for mfg libero proces
UPDATE adempiere.AD_Process 
 SET classname ='org.libero'||SUBSTRING(classname,15,70)
 WHERE SUBSTRING(classname,0,15) = 'org.eevolution';

 UPDATE adempiere.AD_Form 
 SET classname ='org.libero'||SUBSTRING(classname,15,70)
 WHERE SUBSTRING(classname,0,15) = 'org.eevolution';
 
 UPDATE adempiere.AD_Column  SET callout = null
 WHERE SUBSTRING(callout,0,21) = 'org.eevolution.model';

 DROP VIEW adempiere.RV_PP_Order_Storage CASCADE;




 mfg video:
  https://groups.google.com/g/idempiere/c/p9fC5uzvCW8/m/lAqJCzpQAAAJ

  https://groups.google.com/g/idempiere/c/FlTUzmhgHA4/m/VM06zmVQCQAJ

  https://www.youtube.com/watch?v=T9BNLoHRBo4

  https://www.facebook.com/groups/524534327582465/posts/7575633059139188/?_rdr

  https://www.youtube.com/watch?v=xrr6j1NZsig&t=188s

  https://www.adempierebr.com/index.php5?search=manufacturing&title=Special%3ASearch&fulltext=Search


idempiere plugins:
 https://wiki.idempiere.org/en/Category:Available_Plugins


 final:
  using org.idempiere.mgf (10 version jar)
   updated db column required and process names
  set ad sequence   select * from adempiere.AD_Sequence where AD_Sequence_id = 53272;


/**changed**/


/home/mahe/pipra/wms/idempiere-release-10/data/import/AccountingDefaultsOnly.csv



get productlabel without sales:

SELECT 
    pp.pi_productlabel_id,
    SUM(CASE 
            WHEN pp.issotrx = 'N' THEN pp.quantity 
            ELSE 0 
        END) AS remaining_count
FROM 
    adempiere.pi_productlabel pp
WHERE 
    pp.ad_client_id = 1000006
    AND NOT EXISTS (
        SELECT 1 
        FROM adempiere.pi_productlabel pp_sales
        WHERE pp_sales.labeluuid = pp.labeluuid
        AND pp_sales.issotrx = 'Y'
    )
GROUP BY 
    pp.pi_productlabel_id;



warepro enhancement features:

uploading sku excel and add in to system,
creating process to give role acess
generating labels from material receipt
stock update

-------------------------------------------------------------------------------------------------------------------------------
                                          Traceabilty wdiget:
-------------------------------------------------------------------------------------------------------------------------------
 1. Received
   -- who created MR is Received user
   
 2. qcaccepted
   -- who marked mr as qc completed
 
 3. stored
   -- who completed MR doc action is stored user

 4. Picked
   -- who created customer shipment is picked user
 
 5. dispatched
   -- who completed customer shipment


open source
https://demo.globalqss.com/webui/

for postres to connect with local
location: /etc/postgresql/14/main
in pg_hba.conf add this lass

#Added By Mahendhar for connecting to localhost
host    all             all             0.0.0.0/0              scram-sha-256


in postgresql.conf keep *

# CONNECTIONS AND AUTHENTICATION
#------------------------------------------------------------------------------

# - Connection Settings -

listen_addresses = '*' 


Mail Host
smtp.gmail.com
  SMTP Authentication  
SMTP Port
587
    SMTP SSL/TLS   
Request EMail
chiragrathiji111@gmail.com
Request Folder
 
Request User
Request User Password
qedi ovmc ddho rxgr
 