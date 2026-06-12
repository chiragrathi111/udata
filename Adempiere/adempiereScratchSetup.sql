
New adempiere setup :-

1. First git clone
#	git clone https://github.com/idempiere/idempiere.git

2. cd idempiere
#   git checkout release-10  //this command is using release 10 version

3. mvn verify

4. open an Eclipse project and import idempiere project

5. go to window -> preference -> search enter Tycho Configurator and jre and check two configure java-11 choose or not if not choose please select java-11 and apply and close
   set java 11 path
   /usr/lib/jvm/java-11-amazon-corretto
   window->preference->maven->Discovery->open catalog->Tycho Configurator and complete to system restart

6. org.idempiere.p2.targetplatform (this folder is base folder of all project )

	org.idempiere.p2.targetplatform.target click and reload target plateform  and select all folder and dependency install

7. all error is remove 

8. go to run configuration and install app 
	fill up all details 

9. go to server.product and show runing

10. idempiere new version mai all plugin ko add karna important hai is liye wms ko git karke use plugin ko old file mai send karte hai

11. com.idempiere.customization this file copy to idempiere folder

12. this customization file ko import karna hai

13. file -> import -> general -> existing project into workspace -> next -> select root directory and enter idempier actual path all checkbox deslected 
	and choose customization file and press finish.	

14. run configuration -> server.product -> select plug-ins and choose customization file and increse file lavel like 1 and auto start select true and press run


15. If your system not show server.product then go to this process :-
	server.product
     download file and add file in folder (folder only show in lauch configuration)
     File->import->Run/Debug->launch configuration->choose folder and click check and finish 
     then show server.product

Postgresql Data Setup:-

Install Postgresql database:-

sudo apt update 
sudo apt install postgresql postgresql-contrib -y 
sudo systemctl start postgresql.service
sudo systemctl status postgresql
sudo -i -u postgres  
psql
ALTER USER postgres WITH PASSWORD 'Welcome@1278';

ALTER USER postgres WITH PASSWORD 'postgres';

Adempiere Setep:-

1. Create adempiere user :-
	psql -U postgres -c "CREATE ROLE adempiere SUPERUSER LOGIN PASSWORD 'Welcome@1278'"

2. Create adempiere database setup:-
	createdb --template=template0 -E UNICODE -O adempiere -U adempiere idempiere
	psql -d idempiere -U adempiere -c "ALTER ROLE adempiere SET search_path TO adempiere, pg_catalog"
	enter password :- adempiere

3. Restore database :-
	cd 
	psql -U adempiere -d idempiere < /home/chirag/ExpDat.dmp (requirement according change file path)
	(if any requirement give file executing permission)

	psql -U adempiere -d idempiere6 < /home/chirag/austrak_C.dmp (This code is also setup in Austrak) datave.dmp
==============================================================================================================================================================
Fro Vinay Electricals:-
	createdb  --template=template0 -E UNICODE -O adempiere -U adempiere erpVe (password of adempiere)
	psql -d erpVe -U adempiere -c "ALTER ROLE adempiere SET search_path TO adempiere, pg_catalog"

	Restore:-
	psql -U adempiere -d erpVe < /home/chirag/datave.dmp   //every time change db name name your back up file name

	Backup:-
	pg_dump -U adempiere -W erpVe > /home/chirag/datave.dmp

	pg_dump -U adempiere -W stonex_template > /home/ubuntu/stonexNew.dmp

	scp -i "pemFile/democ.pem" ubuntu@3.28.239.34:/home/ubuntu/stonex_template.dmp /home/chirag/

	================================================================================================
	Install Postgresql 14 :-

	# Step 1: Install required packages
sudo apt install -y curl ca-certificates

# Step 2: Add PostgreSQL official repository
sudo install -d /usr/share/postgresql-common/pgdg
sudo curl -o /usr/share/postgresql-common/pgdg/apt.postgresql.org.asc \
    --fail https://www.postgresql.org/media/keys/ACCC4CF8.asc

# Step 3: Add the repository to sources
sudo sh -c 'echo "deb [signed-by=/usr/share/postgresql-common/pgdg/apt.postgresql.org.asc] \
    https://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" \
    > /etc/apt/sources.list.d/pgdg.list'

# Step 4: Update package list
sudo apt update

# Step 5: Install PostgreSQL 14 specifically
sudo apt install -y postgresql-14

# Step 6: Verify installation
psql --version
# Should show: psql (PostgreSQL) 14.x

	===================================
	Delete DB:-
	DROP DATABASE idempiere2;


	if getting error run below command:-
	SELECT pg_terminate_backend(pid)
FROM pg_stat_activity
WHERE datname = 'rwpl_prod'
  AND pid <> pg_backend_pid();

	====================================	

Server to Local copy:-
scp -i "pemFile/democ.pem" ubuntu@13.235.255.17:/home/ubuntu/dataveN.dmp /home/chirag/
==============================================================================================================================================================
If you are another database your system:-
#cd (home directory to create all functionality)
#createdb  --template=template0 -E UNICODE -O adempiere -U adempiere idempiere2 (password of adempiere)(modify your database name)
#psql -d idempiere2 -U adempiere -c "ALTER ROLE adempiere SET search_path TO adempiere, pg_catalog" (enter adempiere Password)
#psql -U adempiere -d idempiere < /home/chirag/ExpDat.dmp (this folder path actual other wise not add data for yoyr database)

==============================================================================================================================================================
This code is use your Database complete backup
pg_dump -U adempiere -W idempiere5 > /home/chirag/datas.dmp(-w Without password and -W With Password)
==============================================================================================================================================================
new ui Adempiere Setup our system:-

git clone wms/folder
git checkout ui_dev
import project in Eclipse and go to targetplatform
if you not remove error then go to terminal and press mvn verify
afetr verify Eclipse maven update project and remove all error

==============================================================================================================================================================
After done change your database file and restart server:-
cd /opt/idempiere-server
sudo nano idempiere.properties
change db name
sudo nano idempiereEnv.properties
change db name
sudo service idempiere restart

The table stores the Minutes of Meeting detail, For every meeting, a MOM detail is capture here.
The table stores the Minutes of Meeting detail
Minutes of Meeting detail
=============================================================================================================
*Stonex

createdb --template=template0 -E UNICODE -O adempiere -U adempiere erp

psql -d erp -U adempiere -c "ALTER ROLE adempiere SET search_path TO adempiere, pg_catalog"

psql -U adempiere -d erp < /home/ubuntu/WarePro/vk12.dmp


Welcome@1278
==============================================================================================================

how can take dumb using command :-

pg_dump -U adempiere -W ware03 > /home/chirag/dumb/ware03.dmp

createdb --template=template0 -E UNICODE -O adempiere -U adempiere warepro
psql -d warepro -U adempiere -c "ALTER ROLE adempiere SET search_path TO adempiere, pg_catalog"
psql -U adempiere -d warepro < /home/chirag/warepro.dmp

createdb --template=template0 -E UNICODE -O adempiere -U adempiere erp
psql -d erp -U adempiere -c "ALTER ROLE adempiere SET search_path TO adempiere, pg_catalog"
psql -U adempiere -d erp < /home/ubuntu/rwpl05.dmp

======================================================================================================
Find idempiere jar file :-

/opt/idempiere-server/jettyhome/work/jetty-0_0_0_0-8443-bundleFile-_rwplrest-any-/webapp/META-INF$

