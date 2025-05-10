Install Active MQ:-
sudo apt update && sudo apt upgrade -y
cd /opt
wget https://dlcdn.apache.org/activemq/5.18.4/apache-activemq-5.18.4-bin.tar.gz
sudo tar -xvzf apache-activemq-5.18.4-bin.tar.gz
sudo mv apache-activemq-5.18.4 activemq
cd 
sudo chown -R ubuntu:ubuntu /opt/activemq
(Currently not setup Environment:-
	sudo nano /etc/environment
ACTIVEMQ_HOME=/opt/activemq
PATH=$PATH:$ACTIVEMQ_HOME/bin
	source /etc/environment
)
cd /opt/activemq/bin
./activemq start
./activemq status

Check Active mq side:-
http://13.233.84.2:8161/admin/index.jsp

Restart Active mq
sudo systemctl stop activemq
sudo systemctl start activemq

Restart Idempiere Server
sudo service idempiere restart


Background run pm2:-
npm i -g pm2
pm2 -v
pm2 list

hyper ledger fabric path
cd /home/ubuntu/fabric-samples/asset-transfer-basic/application-gateway-typescript
pm2 start dist/app.js

this above two line using then background working start 

if you stop and restart
pm2 stop dist/app.js
pm2 restart dist/app.js 

i added upgrade script in server first every time upgrade version in chaincode then run script it is working fine:-
-------------------------------------------------------------------------------------------------------------------
#!/bin/bash

# If you are modify chaincode then every time upgrade chaincode version other wise your changes is not comming using sdk

nvm use 18
node -v

./network.sh down

./network.sh up createChannel -ca -c mychannel -s couchdb


./network.sh deployCC -ccn basic -ccp ../asset-transfer-basic/chaincode-typescript/ -ccl typescript -ccv 1.0.4

echo "Successfully chaincode install and commited"

# Invoke path command

export PATH=${PWD}/../bin:$PATH
export FABRIC_CFG_PATH=$PWD/../config/
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="Org1MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
export CORE_PEER_ADDRESS=localhost:7051

# Invoke command

peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem" -C mychannel -n basic --peerAddresses localhost:7051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt" --peerAddresses localhost:9051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt" -c '{"function":"InitLedger","Args":[]}'

echo "chaincode invoke Successfully"
-------------------------------------------------------------------------------------------------------------------
=============================================================================
Chaincode Install and Invoke in server:-
path:-
cd fabric-samples/test-network
Chaincode Install:-
./network.sh deployCC -ccn basic -ccp ../asset-transfer-basic/chaincode-typescript -ccl typescript -ccv 1.0.4

Invoke command:-
cd fabric-samples/test-network
export PATH=${PWD}/../bin:$PATH
export FABRIC_CFG_PATH=$PWD/../config/
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="Org1MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
export CORE_PEER_ADDRESS=localhost:7051

main Invoke code
peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem" -C mychannel -n basic --peerAddresses localhost:7051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt" --peerAddresses localhost:9051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt" -c '{"function":"InitLedger","Args":[]}'