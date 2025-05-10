sudo apt update
sudo apt install awscli -y
which aws
aws s3 ls
aws s3 ls s3://chirat0606/
mkdir restore 
aws s3 cp s3://chirat0606/backup2.tar /home/ubuntu/restore/
aws s3 cp s3://chirat0606/postgresql_realmeds_2023-05-11_04_44.sql /home/ubuntu/restore/
ls restore/
git clone https://github.com/pipra-solution/realmeds.git
git clone https://github.com/pipra-solution/realmeds-selfcare.git
sudo apt-add-repository -y ppa:git-core/ppa
sudo apt-get update
sudo apt-get install -y git
sudo apt-get -y install build-essential libssl-dev
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.2/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
nvm install 10
nvm use 10
sudo apt install docker.io -y
sudo usermod -a -G docker $USER
sudo apt install docker-compose
set +e
COUNT="$(python -V 2>&1 | grep -c 2.)"
sudo apt install python2-minimal -y
python2 -V
sudo apt-get -y install unzip
sudo apt install golang-go
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
sudo chmod 666 /var/run/docker.sock
sudo curl -sSL http://bit.ly/2ysbOFE | bash -s -- 1.4.6 1.4.6 0.4.18
ls
cd fabric-samples
sudo cp bin/* /usr/local/bin
cd
sudo apt update -y
sudo apt install postgresql postgresql-contrib -y
sudo systemctl start postgresql.service
sudo systemctl status postgresql
sudo -i -u postgres
psql
CREATE DATABASE realmeds;
ALTER USER postgres WITH PASSWORD 'VndDhmNTum';
cd realmeds/network/api/server/
vi datasources.json 
cd ~/realmeds-selfcare/apiserver/server/
vi datasources.json 
cd ~/realmeds/network/api/
ls
vi package.json 
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
ls
cd restore/
ls
sudo tar -xvf backup2.tar 
cd folder2/
ls
sudo mv orderer_2023-05-11 orderer
sudo mv peer0.org1_2023-05-11 peer0.org1
cd
sudo cp -r /home/ubuntu/restore/folder2/* /home/ubuntu/realmeds/network/setup/
cd realmeds/network/setup/
ls -lh
vi docker-compose.yml 
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
vi environment.js
cd
npm install forever -g
cd realmeds/network/api
forever logs
forever start server/server.js
forever logs
forever logs 0 (show error)
cd ~/realmeds-selfcare/apiserver/environment/
vi environment.js
vi environment-demo.js 
cd ~/realmeds-selfcare/selfcare_allinone/src/environments/
vi environment.ts 
vi environment.demo.ts (comma ka bhi sahi use karna hai and firebase ko add karna hai)
cd ../../
nvm install 14
nvm use 14
node -v
npm i
npm install -g @angular/cli
ng build --prod --configuration=demo
cd ../apiserver/
ls
npm i
cd environment/
vi environment.js 
cd ../server/
ls
vi config.json 
vi datasources.json 
cd
ls
mkdir script
cd script/
sudo vi backupRestore.sh
{
#!/bin/bash

# Set the database name and the backup file name
DB_NAME="realmeds"

BACKUP_FILE="/home/ubuntu/restoreData/restore_backup.sql"

# Set the username and password for the database
DB_USERNAME="postgres"

DB_PASSWORD="VndDhmNTum"

psql --dbname=postgresql://$DB_USERNAME:$DB_PASSWORD@localhost:5432/$DB_NAME -f $BACKUP_FILE
}
ls ../restore/
sudo vi backupRestore.sh
sudo chmod +x backupRestore.sh 
sudo ./backupRestore.sh 
sudo -i -u postgres
psql
\c realmeds
\dt
\q
exit
cd realmeds-selfcare/apiserver/
node -v
nvm use 10
forever start server/server.js 
forever logs 
forever logs 1 (show error)
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
mkdir uploads
cd ..
forever stop server/server.js 
forever logs 
forever start server/server.js 
forever logs 1


  175  cd server/
  176  node create-couchDb-views.js 
  177  vi create-couchDb-views.js 
  178  node create-tables.js 
  179  forever logs 
  180  forever logs 0
  181  forever logs 1
  182  cd ..
  183  forever stop server/server.js 
  184  forever start server/server.js 
  185  forever logs 1
  186  ls
  187  cd environment/
  188  ls
  189  vi environment.js 
  190  cd ../server/lib/
  191  ls
  192  vi awsiot-shadow.js 
  193  cd ..
  194  ls
  195  cd ..
  196  forever stop server/server.js 
  197  forever start server/server.js 
  198  forever logs 1

  205  history | sudo tee ec2_complete.sql
