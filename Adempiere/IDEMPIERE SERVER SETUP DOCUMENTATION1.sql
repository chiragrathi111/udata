   IDEMPIERE SERVER SETUP DOCUMENTATION

Prerequisites
netstat is required
sudo apt-get install net-tools

Java >= 11
sudo apt-get update
sudo apt install openjdk-11-jdk
Edit .bashrc file to add env varibales
nano ~/.bashrc
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
export PATH=$PATH:$JAVA_HOME/bin
source ~/.bashrc

Postgresql >= 14 
sudo apt install postgresql-14
sudo systemctl status postgresql
sudo -u postgres psql
Change postgres default password
ALTER USER postgres PASSWORD 'Welcome@1278';
Configure pg_hba.conf
After installing postgres you must check the correct configuration of /etc/postgresql/14/main/pg_hba.conf
The following line requires change of the authentication method:
local   all      all                       peer


Change to:
local   all       all                  scram-sha-256
—---------
Restart postgres
sudo systemctl restart postgresql




Create adempiere user:
sudo su - postgres
psql -U postgres -c "CREATE ROLE adempiere SUPERUSER LOGIN PASSWORD  'Welcome@1278'"
Exit

Create adempiere database:
createdb  --template=template0 -E UNICODE -O adempiere -U adempiere idempiere
psql -d idempiere -U adempiere -c "ALTER ROLE adempiere SET search_path TO adempiere, pg_catalog"

Installing UUID (required for some scripts)
psql -d idempiere -U adempiere -c 'CREATE EXTENSION "uuid-ossp"'

Both ExpDat.dmp and download1.deb to idempiere drive

Import Seed: copy dmp file from local
mkdir WarePro
scp -i /home/mahe/Downloads/democ.pem /home/mahe/Downloads/ExpDat.dmp ubuntu@43.205.103.6:/home/ubuntu/WarePro
OR we can use customer database file
Dump the data from file
        psql -d idempiere -U adempiere -f ExpDat.dmp


As we have modified base code, we need to use existing code, which is uploaded in drive
Download the Debian Installer:
For version 10, choose file download1.deb from local
scp -i /home/mahe/Downloads/democ.pem /home/mahe/download1.deb ubuntu@43.205.103.6:/home/ubuntu/WarePro/
Execute the installer (example for 11):
                     sudo chmod +x download1.deb 
  sudo dpkg -i download1.deb 
this step checks the prerequisites, copies the needed files into /opt/idempiere-server and /etc, creates iDempiere user and group and assign proper permissions to the files. At the end, it displays a message to the user "You must run '/etc/init.d/idempiere configure' as the root user to configure the application."
Configure iDempiere as root
sudo /etc/init.d/idempiere configure
this step asks the minimum required user variables, fill them properly or just push enter to get the default in square brackets:
Specify the HTTP port that will be used for iDempiere server [8080]:
Specify the HTTPS port that will be used for iDempiere server [8443]:
Specify a password to be used for adempiere database account: (this is mandatory - special characters with meaning for linux shell must not be used in password)
Confirm the password: confirm the password given above
Specify the password of the user postgres on postgres database (if empty then local connection will be tried): - you can leave the password empty to use the direct connection from postgres user
Do you want iDempiere ERP Server to be started on boot (y/n) [y]:
After this the deployment is executed (console-setup.sh), the import of the database is done (RUN_ImportIdempiere) and the service is installed to start on boot.
First execution:
sudo SYSTEMCTL_SKIP_REDIRECT=1 /etc/init.d/idempiere start
To start the server you can reboot the machine or run:

change your uwn database :-
cd /opt/idempiere-server

sudo nano idempiere.properties  (change one pleace)

sudo nano idempiereEnv.properties  (change two pleaces)

sudo service idempiere stop
sudo service idempiere start





Add our customixed plugins:
scm customization
Org.idempiere.webservices
Org.adempiere.ui.zk

Uninstall idempiere:
1.sudo service idempiere stop

2.sudo dpkg -r idempiereServer10Daily

3.sudo apt remove idempiere
4.sudo rm -rf /opt/idempiere-server
   sudo rm -rf /etc/idempiere
5.sudo -u postgres psql -c "DROP DATABASE adempiere;"
   sudo -u postgres psql -c "DROP USER adempiere;"
6.sudo deluser idempiere
sudo delgroup idempiere
