free -h

forever logs

cd realmeds

cd network/setup/

docker-compose -f docker-compose.yml up -d ca.realmeds.io orderer.realmeds.io peer0.org1.realmeds.io couchdb cli

cd ../../scripts/network/

vim upgrade.sh

./upgrade.sh

docker container prune

y

docker ps -a

cd ../../network/api/

forever start server/server.js

cd ~/realmeds-selfcare/apiserver/

forever start server/server.js

cd ../microsite/

forever start dist/microsite/server/main.js

forever logs

exit



ng build --prod --configuration=demo

cp -R dist/web/* ../apiserver/client/.




for microsite build
nvm use 14

npm run build:ssr