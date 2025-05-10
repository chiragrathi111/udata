Already setup mai docker ko remove karke docker ko startfabric karna hai jab bhi startfabric ka use karte hai to hame table,state,csc,user sab create karna hota hai and couchdb wale mai 5 time mai one by one run karna hota hai

docker ps
./stopFabric.sh 
docker volume ls
docker volume prune
docker volume ls
cd ~/realmeds/network/setup/
vi docker-compose.yml 
cd ../../scripts/network/
./startFabric.sh 
docker ps
docker volume ls
cd ~/script/
sudo ./couchdb.sh 
sudo ./couchdb_current.sh 
cd ../realmeds-selfcare/apiserver/server/
vi create-tables.js 
node create-tables.js 
node create-states.js 
node create-csc.js 
node create-users.js 
vi create-couchDb-views.js 
node create-couchDb-views.js 
vi create-couchDb-views.js 
node create-couchDb-views.js 
vi create-couchDb-views.js 
node create-couchDb-views.js 
vi create-couchDb-views.js 
node create-couchDb-views.js 
vi create-couchDb-views.js 
node create-couchDb-views.js 
history



ng serve (local)
