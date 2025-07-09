  *  docker ps
  *  docker logs -f e342db19b3be
  *  cd fabric-samples/test-network/organizations/fabric-ca/
  *  ls
  *  cd org1
  *  ls
  *  sudo nano fabric-ca-server-config.yaml 
  *  sudo cat fabric-ca-server-config.yaml 
  *  cd ../org2/
  *  ls
  *  sudo nano fabric-ca-server-config.yaml 
  *  cd ../ordererOrg/
  *  ls
  *  sudo nano fabric-ca-server-config.yaml 
  *  cd ~/fabric-sample/test-network
  *  cd ../../..
  *  ./network.sh down
  *  ./network.sh up createChannel -ca -s couchdb
  *  nvm use 18
  *  ./network.sh deployCC -ccn basic -ccp ../asset-transfer-basic/chaincode-typescript -ccl typescript -ccv 1.0.0
  * export PATH=${PWD}/../bin:$PATH
  export FABRIC_CFG_PATH=$PWD/../config/
  export CORE_PEER_TLS_ENABLED=true
  export CORE_PEER_LOCALMSPID="Org1MSP"
  export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
  export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
  export CORE_PEER_ADDRESS=localhost:7051
  *  peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem" -C mychannel -n basic --peerAddresses localhost:7051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt" --peerAddresses localhost:9051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt" -c '{"function":"InitLedger","Args":[]}'
  *  cd ~/fabric-samples/asset-transfer-basic/chaincode-typescript/src/
  *  nvm use 18
  *  npm run build
  *  cd ~/fabric-samples/asset-transfer-basic/application-gateway-typescript/src
  *  nvm use 18
  *  npm run build
  *  cd ~/fabric-samples/asset-transfer-basic/application-gateway-typescript/
  *  nvm use 18
  *  pm2 list
  *  pm2 stop dist/app.js
  *  pm2 list
  *  pm2 start dist/app.js
  *  pm2 list
  *  cd
  *  docker ps
  *  docker logs -f 9e5059644e34
  *  docker logs -f 049cb793c63e
  *  sudo service idempiere restart 
  *  cd /opt/idempiere-server/log/
  *  ls
  *  cat idempiere_20250625104121.log
  *  cd ~/fabric-samples/test-network/script/
  *  ls
  *  sudo nano upgrade.sh (This command need if any chaincode update)