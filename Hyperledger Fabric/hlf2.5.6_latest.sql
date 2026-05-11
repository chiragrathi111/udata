🔥 Hyperledger Fabric 2.5.6 Full Setup (Correct Version)

🧱 1. Base Setup

sudo apt update
sudo apt install git curl docker.io docker-compose-plugin python3 -y

🐳 2. Docker Permission (SAFE way)

sudo usermod -aG docker $USER
newgrp docker

🟢 3. Install NVM + Node 20 (IMPORTANT CHANGE)

curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

nvm install 20
nvm use 20

🐹 4. Install Go

wget https://go.dev/dl/go1.21.0.linux-amd64.tar.gz
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf go1.21.0.linux-amd64.tar.gz

echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc
source ~/.bashrc

⛓️ 5. Install Hyperledger Fabric

curl -sSL https://bit.ly/2ysbOFE | bash -s -- 2.5.6 1.5.9
cd fabric-samples
sudo cp bin/* /usr/local/bin   '*/'not use after bin ' 

📦 6. Download ALL required images (VERY IMPORTANT)

./bootstrap.sh

Note:- If this script is not showing do not run if you got any error then run below commands:-

👉 This avoids:

No such image: hyperledger/fabric-nodeenv:2.5

🚀 7. Start Network

cd test-network
./network.sh up createChannel -ca -s couchdb

📜 8. Deploy Chaincode

./network.sh deployCC -ccn basic \
  -ccp ../asset-transfer-basic/chaincode-typescript \
  -ccl typescript

⚙️ 9. Set Environment (Org1)

export PATH=${PWD}/../bin:$PATH
export FABRIC_CFG_PATH=$PWD/../config/

export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="Org1MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
export CORE_PEER_ADDRESS=localhost:7051

▶️ 10. Invoke Chaincode

peer chaincode invoke -o localhost:7050 \
--ordererTLSHostnameOverride orderer.example.com \
--tls \
--cafile "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem" \
-C mychannel -n basic \
--peerAddresses localhost:7051 \
--tlsRootCertFiles "${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt" \
--peerAddresses localhost:9051 \
--tlsRootCertFiles "${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt" \
-c '{"function":"InitLedger","Args":[]}'

11. Chaincode Setup (FIXED)

cd ~/fabric-samples/asset-transfer-basic/chaincode-typescript/src	

npm run build

🌐 12. Application Gateway Setup (FIXED)

cd ~/fabric-samples/asset-transfer-basic/application-gateway-typescript/src

npm install     ❗ MUST
npm run build


cd ~/fabric-samples/asset-transfer-basic/application-gateway-typescript/src

npm install
npm start

🔁 13. If Using PM2

npm install -g pm2
pm2 start dist/app.js
pm2 save


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