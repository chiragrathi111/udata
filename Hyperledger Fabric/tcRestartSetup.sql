If any reason VM/EC2 Restart then follow this steps:-

String run  then ActiveMQ Start:-

* cd /opt/activemq/bin

* ./activemq start

* ./activemq status

(If have doubt port 61613 is working or not so run this commands:-
* sudo netstat -tulnp | grep 61613
O/p - tcp6 0 0 :::61613 :::* LISTEN 2728344/java
)

* cd

String run comands then conatiner up:-

* cd fabric-samples/test-network

* ./network.sh up -ca -s couchdb

* docker ps

* export PATH=${PWD}/../bin:$PATH
export FABRIC_CFG_PATH=$PWD/../config/
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="Org1MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
export CORE_PEER_ADDRESS=localhost:7051

* peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem" -C mychannel -n basic --peerAddresses localhost:7051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt" --peerAddresses localhost:9051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt" -c '{"function":"InitLedger","Args":[]}'

* cd

* cd ~/fabric-samples/asset-transfer-basic/chaincode-typescript/src	

* nvm use 18 

* node -v

* npm run build

* cd ~/fabric-samples/asset-transfer-basic/application-gateway-typescript/src

* nvm use 18

* npm run build

* cd ~/fabric-samples/asset-transfer-basic/application-gateway-typescript/

* nvm use 18

* pm2 start dist/app.js

* pm2 list

* pm2 logs 0


If PM2 side getting any issue so run the below command then run pm2 comands:-

* nvm use 18
* node -v
* npm uninstall -g pm2
* pm2 list
* npm install -g pm2
* pm2 list
* pm2 kill
* pm2 start dist/app.js
* pm2 save
* pm2 list
