1. ssh login in terminal
2. sudo apt-get install net-tools
3. sudo apt-get update
4. sudo apt-get install openjdk-11-jdk-headless
5. java -version (check java version)
6. sudo apt-get install postgresql-14
7. sudo systemctl status postgresql (check postgresql avtive or not active)
8. sudo systemctl start postgresql (If not active then use this code)
9. cd /etc/postgresql/14/main/
10. sudo nano pg_hba.conf (and change md5 name in 6-7 place)
11. sudo nano postgresql.conf (remove # and change localhost to *)
	(listen_addresses = '*') and restart postgresql
12. update postgresql password
	ALTER USER postgres WITH PASSWORD 'postgres';
13. If our postgresql two file complete setup changes then added user role and database
	
	* psql -U postgres -c "CREATE ROLE adempiere SUPERUSER LOGIN PASSWORD 'Ajit@2018'" 
	* createdb  --template=template0 -E UNICODE -O adempiere -U adempiere erp
	* psql -d erp -U adempiere -c "ALTER ROLE adempiere SET search_path TO adempiere, pg_catalog"	
14. Added dmp file in your local
    local commands:-
    	* scp -i /home/chirag/pemFile/democ.pem /home/chirag/austrak_C.dmp ubuntu@3.110.80.36:/home/ubuntu/
15 ls and see the file location and use this file added requirement database
		*  psql -U adempiere -d erp < /home/chirag/austrak_C.dmp (see file location)
		this command use whole data is came our database
16 Allow port no and if utf not active press commands and get active:-
		* sudo ufw status
        * sudo ufw enable
   		* sudo ufw status
   		* sudo ufw allow 22
   		* sudo ufw allow 8080
   		* sudo ufw allow 8443
   		* sudo ufw allow 80
   		* sudo ufw allow 5432
   		* sudo ufw status
17 	Install debian file in server:-
		* wget https://sourceforge.net/projects/idempiere/files/v10/daily-server/idempiereServer10Daily.gtk.linux.x86_64.deb
		* sudo chmod +x idempiereServer10Daily.gtk.linux.x86_64.deb
		* First configure port database name and other click below code
		* sudo /etc/init.d/idempiere configure 	

		  if you save but your need any change then go to file and changes manually:-
		   * cd /etc/init.d/
		   * ls (changes two file,if your requirement db name)
		   * nano idempiereEnv.properties {change db name if required}
		   * nano idempiere.properties {change db name if required}
		* sudo dpkg -i idempiereServer10Daily.gtk.linux.x86_64.deb

		cd /opt/idempiere-server/
		* restart the Server :-
			* sudo service idempiere stop
   			* sudo service idempiere start

   	and initial setup done go to your local and mvn verify then jar file updated and customazion and ui.zk file only export
   	
   	https://ip:portNo and go to OSGI login
   	first you remove webservices and ui.zk jar file and added webservices,ui.zk and customization jar file 

   	Restart Server and login you find every thing




==============================================================================
If postgresql not install follow below command:-

* sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'

* curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/pgdg.gpg > /dev/null

* sudo apt-get update

* sudo apt-get install postgresql-14

* psql --version
