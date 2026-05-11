# Hyper Ledger Fabric 2.5.6 Install full setup :-
* sudo apt update
* sudo apt-add-repository -y ppa:git-core/ppa
	
# Install git
* sudo apt update
* sudo apt install git -y
	
# Install Docker
* sudo apt install docker.io -y
	
# Install Python
* sudo apt install python3 -y
	
# Node, Nvm install

* curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash

# Load nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Install Node 18
* nvm install 18
* nvm use 18

# Install docker compose
* sudo apt install docker-compose-plugin -y
	
# Install go.
* wget https://go.dev/dl/go1.21.0.linux-amd64.tar.gz
* sudo rm -rf /usr/local/go
* sudo tar -C /usr/local -xzf go1.21.0.linux-amd64.tar.gz

echo 'export GOPATH=$HOME/go' >> ~/.bashrc
echo 'export PATH=$PATH:$GOPATH/bin' >> ~/.bashrc
* source ~/.bashrc

# Check the version

node -v
npm -v
docker --version
docker-compose --version
docker compose version
python -V
python3 -V

# Docker access not need root

* sudo usermod -aG docker ${USER}
* sudo chmod 666 /var/run/docker.sock  (Do not use, If you can not install hlf then time use)
* newgrp docker

# Install latest version Hyper ledger fabric	
	
* curl -sSL http://bit.ly/2ysbOFE | bash -s -- 2.5.6 1.5.9 
 (2.5.6 = Hyper Ledger version,1.5.9 = CA_VERSION)

* ls
* cd fabric-samples
* sudo cp bin/* /usr/local/bin    '*/'not use after bin ' 

# Install Postgresql

* sudo apt update
* sudo apt install postgresql postgresql-contrib -y
* sudo systemctl status postgresql (if not active then use start)
* sudo -i -u postgres
* psql
* CREATE DATABASE realmeds;
* ALTER USER postgres WITH PASSWORD 'postgres';
	

# Up Container and create a channel:-

* ./network.sh up createChannel -ca -s couchdb

* nvm use 18

* ./network.sh deployCC -ccn basic -ccp ../asset-transfer-basic/chaincode-typescript -ccl typescript

* environment setup :- 

export PATH=${PWD}/../bin:$PATH
export FABRIC_CFG_PATH=$PWD/../config/
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="Org1MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
export CORE_PEER_ADDRESS=localhost:7051


* peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem" -C mychannel -n basic --peerAddresses localhost:7051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt" --peerAddresses localhost:9051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt" -c '{"function":"InitLedger","Args":[]}'

# Setup chaincode and application gateway :-

cd ~/fabric-samples/asset-transfer-basic/chaincode-typescript/src	

* nvm use 20

* node -v

* npm run build

* cd ~/fabric-samples/asset-transfer-basic/application-gateway-typescript/src

* nvm use 20

* npm install

* npm run build

* cd ~/fabric-samples/asset-transfer-basic/application-gateway-typescript/

* nvm use 20

* npm install

* pm2 start dist/app.js

---------------------------------------------------------
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

-----------------------------------------------------------------------------------------
If got error run below commands:-

# No such image: hyperledger/fabric-nodeenv:2.5

* docker pull hyperledger/fabric-nodeenv:2.5

----------------------------------------------------------------------------------------------
If got that peer 2 error :-

# After 5 attempts, peer0.org2 has failed to join channel 'mychannel'

run below commads:-

export CORE_PEER_LOCALMSPID="Org2MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=$PWD/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=$PWD/organizations/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
export CORE_PEER_ADDRESS=localhost:9051

* peer channel join -b ./channel-artifacts/mychannel.block

manually join

--------------------------------------------------------------------------------------------------------------------
