Ec2 Instances create from scratch and setup the all componant and start backup and restore data
===============================================================================================
sudo apt update  
sudo apt install awscli -y (install awscli tool)
which aws
aws s3 ls
aws s3 ls s3://demobackup121/
mkdir restore 
aws s3 cp s3://demobackup121/current_couchdb_realmeds_2023-05-15.tar.gz /home/ubuntu/restore/
aws s3 cp s3://demobackup121/postgresql_realmeds_2023-05-15_00:00.sql /home/ubuntu/restore/

git clone https://github.com/pipra-solution/realmeds.git
git clone https://github.com/pipra-solution/realmeds-selfcare.git

sudo apt-add-repository -y ppa:git-core/ppa
sudo apt-get update
sudo apt-get install git -y
sudo apt-get -y install build-essential libssl-dev
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.2/install.sh | bash (install fabric-sample dir.)
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
nvm install 10
nvm use 10
sudo apt install docker.io -y  (install docker in latest)
sudo apt install docker-compose -y  (install docker-compose in latest)
set +e
COUNT="$(python -V 2>&1 | grep -c 2.)"
sudo apt install python2-minimal -y  (insatll python2)
python2 -V
sudo apt-get -y install unzip
sudo apt install golang-go  (install go language)
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin
echo ''
echo 'Installation completed, versions installed are:'
echo ''
echo -n 'Node:           '
node --version
echo -n 'npm:            '
npm --version
echo -n 'Docker:         '
docker --version
echo -n 'Docker Compose: '
docker-compose --version
echo -n 'Python:         '
python2 -V
sudo usermod -aG docker ${USER}
sudo chmod 666 /var/run/docker.sock  (This line not use throw the error)
sudo curl -sSL http://bit.ly/2ysbOFE | bash -s -- 1.4.6 1.4.6 0.4.18  (multiple images pull and downloaded in syatem)
ls
cd fabric-samples
sudo cp bin/* /usr/local/bin    '*/'not use after bin '

cd
sudo apt update -y
sudo apt install postgresql postgresql-contrib -y (install postgresql database)
sudo systemctl start postgresql.service
sudo systemctl status postgresql
sudo -i -u postgres  (login postgres)
psql
CREATE DATABASE realmeds;
ALTER USER postgres WITH PASSWORD 'VndDhmNTum';
cd realmeds/network/api/server/
vi datasources.json   (change postgresql pass and update ip and accesskey if required)
cd ~/realmeds-selfcare/apiserver/server/
vi datasources.json   (change postgresql pass and update ip and accesskey if required)

cd ~/realmeds/network/api/
ls
vi package.json  (remove 27,28 line)
npm i
cd ../chaincode/
npm i
cd ../../scripts/network/
./startFabric.sh ( only testing)
docker ps
./stopFabric.sh 
docker volume prune
docker volume ls
cd 
df -h
cd restore/
sudo tar -xvf current_couchdb_realmeds_2023-05-15.tar
cd
sudo cp -r /home/ubuntu/restore/current_couchdb_realmeds_2023-05-15/* /home/ubuntu/realmeds/network/setup/    */'after setup not using'
cd realmeds/network/setup/
ls -lh
vi docker-compose.yml (if you are working in restore then you commentout volume and change orderer and peer0.org1 last line volume path and check hifen'-' sequence mai hai ki nahi)
set -ev
export MSYS_NO_PATHCONV=1
docker-compose -f docker-compose.yml down
docker-compose -f docker-compose.yml up -d ca.realmeds.io orderer.realmeds.io peer0.org1.realmeds.io couchdb cli
docker ps
cd ../../
cd realmeds/scripts/network/
vi upgrade.sh
./upgrade.sh 

cd ../../network/api/environment/
vi environment.js (change access key and secret key if required and ip address also change)
cd
nvm use 10
npm install forever -g
cd realmeds/network/api
#forever logs
#forever start server/server.js
#forever logs
#forever logs 0 (show error) (don't use 4 line bacause show error)

cd ~/realmeds-selfcare/apiserver/environment/
vi environment.js	(ip add and access key update)
vi environment-demo.js (ip add and access key update)
cd ~/realmeds-selfcare/selfcare_allinone/src/environments/
vi environment.ts   (comma ka bhi sahi use karna hai and firebase ko add karna hai)
vi environment.demo.ts (comma ka bhi sahi use karna hai and firebase ko add karna hai)
{
profilePicsContainer: 'dev.profilepics',
productPicsContainer: 'dev.productpics',
labelsContainer: 'dev.labels',
epcisfilesContainer: 'dev.epcisfiles',
}(curly brass only represent not using in code)
{



}(outside curly brass only represent not using in code)

cd ../../
nvm install 14
nvm use 14
node -v
npm i
npm install -g @angular/cli
ng build --prod --configuration=demo (if you are not changes node version then throw the error)
cp -R dist/web/* ../apiserver/client 
//(most important otherwise browser mai 401 server error show)*/

cd ../apiserver/
npm i
cd ../server/
vi config.json  (update ip and access key if any required)
cd
mkdir script
cd script/
sudo vi backupRestore.sh
{
#!/bin/bash

# Set the database name and the backup file name
DB_NAME="realmeds"

BACKUP_FILE="/home/ubuntu/restore/restore_backup.sql"

# Set the username and password for the database
DB_USERNAME="postgres"

DB_PASSWORD="VndDhmNTum"

psql --dbname=postgresql://$DB_USERNAME:$DB_PASSWORD@localhost:5432/$DB_NAME -f $BACKUP_FILE
}
sudo chmod +x backupRestore.sh 
sudo ./backupRestore.sh 

sudo -i -u postgres
psql
\c realmeds
\dt
\q
exit

cd ~/realmeds/network/api/wallet/
ls
sudo rm -r *
io:3000 (browse kiya)
//network mai jakar admin and user3 create karte hai

cd ../common/models/
vi network.js (module.export = function(network) ke below line ko commentout karte hai Network.registerAdmin ke above tak)
cd ../../
forever stop server/server.js 
forever logs
forever start server/server.js 
forever logs 1 (realmeds forever error gone)

cd ~/realmeds-selfcare/apiserver/client/
ls
mkdir uploads (using table)
mkdir output  (store bulk label datas)
cd ..
forever stop server/server.js
forever start server/server.js 
forever logs 1
cd server/
node create-couchDb-views.js 
forever logs 
forever logs 0
forever logs 1
//if error forever logs again stop and start and solve the problem

history | sudo tee ec2_complete.sql


Error:-
1. show ui 401 error :- solution (forever stop and start realmeds/network/api and realmeds-selfcare/apiserver both places and solve the error)
2. show ui 500 error :- solution (setup realmeds-selfcare/apiserver/server/ create-tabel.sh,create-state.sh,create-csc.sh,create-users & 
                                    five different way mai create-couch.db ko node se run karte hai or problem solve ho jata hai)
3.