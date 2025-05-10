Latest Hyper ledger Fabric:-

Hyper ledger curl latest version

#
	sudo apt update
	sudo apt-add-repository -y ppa:git-core/ppa
	
# Install git
	sudo apt update
	sudo apt install git -y
	git --version
	
# Install Docker
	sudo apt install docker.io -y
	
# Install Python
	sudo apt install python3 -y
	
# Node, Nvm install

curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.35.3/install.sh | bash

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

nvm install 10	
nvm use 10

# Install docker compose
	sudo apt install docker-compose	-y
	
# Install go.
	sudo apt install golang-go -y

# Setting the path to set the environment variables 

export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin	

# Print installation details for user
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
python -V

docker ps (not permission)

# create a user group
	sudo usermod -a -G docker ${USER}
	
	sudo reboot
	and login working (docker ps)
	
	sudo chmod 666 /var/run/docker.sock  (This line not use throw the error)
	
# Install latest version Hyper ledger fabric	
	
	curl -sSL http://bit.ly/2ysbOFE | bash -s -- 2.5.6 1.5.9 
 	(2.5.6 = Hyper Ledger version,1.5.9 = CA_VERSION)
 	
#
	ls
	cd fabric-samples
	sudo cp bin/* /usr/local/bin    '*/'not use after bin ' 
	cd
	
# Install Postgresql

	sudo apt update
	sudo apt install postgresql postgresql-contrib -y
	sudo systemctl status postgresql (if not active then use start)
	sudo -i -u postgres
	psql
	CREATE DATABASE realmeds;
	ALTER USER postgres WITH PASSWORD 'postgres';
	
	
# Up Container and create a channel:-
	
	cd fabric-sample/test-network
	sudo ./network.sh up (show all container)
	sudo ./network.sh down(all container down)
	
	sudo ./network.sh createChannel (all container and channel both created)
	
	
# chaincode deploy:-

	./network.sh deployCC -ccn basic -ccp ../asset-transfer-basic/chaincode-java -ccl java	
		throw error 
		jq command not found...
		
	sudo apt-get install jq
	sudo apt install openjdk-11-jre-headless
	java --version (see the java 11 path)
	set java path
	export JAVA_HOME=/path/to/java

this three work done then again run your command and you see your code is working properly

sudo ./network.sh deployCC -ccn basic -ccp ../asset-transfer-basic/chaincode-java -ccl java

after running execute anther command:-

peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem" -C mychannel -n basic --peerAddresses localhost:7051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt" --peerAddresses localhost:9051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt" -c '{"function":"InitLedger","Args":[]}'

this command throw error

2024-03-12 09:47:17.482 UTC 0001 ERRO [main] InitCmd -> Cannot run peer because error when setting up MSP of type bccsp from directory /home/ubuntu/fabric-samples/test-network/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp: KeyMaterial not found in SigningIdentityInfo


first i changed org1 and org2 path


cd 
peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile "/home/ubuntu/fabric-samples/test-network/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem" -C mychannel -n basic --peerAddresses localhost:7051 --tlsRootCertFiles "/home/ubuntu/fabric-samples/test-network//organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/tlsca.crt" --peerAddresses localhost:9051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/org2.example.com/users/Admin@org2.example.com/tls/ca.crt" -c '{"function":"InitLedger","Args":[]}'	


sudo ./network.sh down
docker ps
docker system prune
sudo ./network.sh up -ca -s couchdb
sudo ./network.sh createChannel
sudo ./network.sh up createChannel -ca -s couchdb  //both two line join also possible if you are intrested change channel name then used -c channelName
sudo chmod 666 /var/run/docker.sock
docker exec peer0.org1.example.com peer channel list
show output :- 
Channels peers has joined: 
mychannel

sudo ./network.sh deployCC -ccn basic -ccp ../asset-transfer-basic/chaincode-java -ccl java   //If your requirement you also use version like -ccv 1


#!/bin/bash
export PATH=${PWD}/../bin:$PATH
export FABRIC_CFG_PATH=$PWD/../config/
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="Org1MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
export CORE_PEER_ADDRESS=localhost:7051
export ORDERER_CA=${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem


sudo nano basicChirag.sh

sudo chmod +x basicChirag.sh
source ./basicChirag.sh (run this script added all empty path in folder)

chaincode package and install both done using single command:-

sudo ./network.sh deployCC -ccn basic -ccp ../asset-transfer-basic/chaincode-java -ccl java

#####peer chaincode install --peerAddresses localhost:7051 --tlsRootCertFiles $CORE_PEER_TLS_ROOTCERT_FILE (not using this commands)


add below content in new file basicorg2.sh

#!/bin/bash
export PATH=${PWD}/../bin:$PATH
export FABRIC_CFG_PATH=$PWD/../config/
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="Org2MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
export CORE_PEER_ADDRESS=localhost:9051
export ORDERER_CA=${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

sudo chmod +x basicorg2.sh
source ./basicorg2.sh
sudo ./network.sh deployCC -ccn basic -ccp ../asset-transfer-basic/chaincode-java -ccl java

#!/bin/bash
export PATH=${PWD}/../bin:$PATH
export FABRIC_CFG_PATH=$PWD/../config/
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="Org1MSP"
export CORE_PEER_TLS_ROOTCERT_FILE_ORG1=${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
export CORE_PEER_TLS_ROOTCERT_FILE_ORG2=${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
export CORE_PEER_ADDRESS=localhost:7051
export ORDERER_CA=${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

sudo chmod +x basicbothorg.sh
source ./basicbothorg.sh

sudo peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA -C mychannel -n basic --peerAddresses localhost:7051 --tlsRootCertFiles $CORE_PEER_TLS_ROOTCERT_FILE_ORG1 --peerAddresses localhost:9051 --tlsRootCertFiles CORE_PEER_TLS_ROOTCERT_FILE_ORG2 -c '{"function":"InitLedger","Args":[]}'



Rough Working:-
Package
peer lifecycle chaincode package basic.tar.gz --path ../asset-transfer-basic/chaincode-java/build/install/basic --lang java --label basic_1.0.1





======================================================================================================================================================
sudo ./network.sh deployCC -ccn basic -ccp ../asset-transfer-basic/chaincode-java -ccl java
Using docker and docker-compose
deploying chaincode on channel 'mychannel'
executing with the following
- CHANNEL_NAME: mychannel
- CC_NAME: basic
- CC_SRC_PATH: ../asset-transfer-basic/chaincode-java
- CC_SRC_LANGUAGE: java
- CC_VERSION: 1.0.1
- CC_SEQUENCE: auto
- CC_END_POLICY: NA
- CC_COLL_CONFIG: NA
- CC_INIT_FCN: NA
- DELAY: 3
- MAX_RETRY: 5
- VERBOSE: false
executing with the following
- CC_NAME: basic
- CC_SRC_PATH: ../asset-transfer-basic/chaincode-java
- CC_SRC_LANGUAGE: java
- CC_VERSION: 1.0.1
Compiling Java code...
/home/ubuntu/fabric-samples/asset-transfer-basic/chaincode-java /home/ubuntu/fabric-samples/test-network
Starting a Gradle Daemon (subsequent builds will be faster)

Deprecated Gradle features were used in this build, making it incompatible with Gradle 9.0.

You can use '--warning-mode all' to show the individual deprecation warnings and determine if they come from your own scripts or plugins.

For more on this, please refer to https://docs.gradle.org/8.6/userguide/command_line_interface.html#sec:command_line_warnings in the Gradle documentation.

BUILD SUCCESSFUL in 17s
10 actionable tasks: 10 up-to-date
/home/ubuntu/fabric-samples/test-network
Finished compiling Java code
+ '[' false = true ']'
+ peer lifecycle chaincode package basic.tar.gz --path ../asset-transfer-basic/chaincode-java/build/install/basic --lang java --label basic_1.0.1
+ res=0
Chaincode is packaged
Installing chaincode on peer0.org1...
Using organization 1
+ peer lifecycle chaincode queryinstalled --output json
+ grep '^basic_1.0.1:245a00c5a8183f30c2b2455eed0ca2650793fdc76f65442e9f2597789f54336c$'
+ jq -r 'try (.installed_chaincodes[].package_id)'
+ test 0 -ne 0
basic_1.0.1:245a00c5a8183f30c2b2455eed0ca2650793fdc76f65442e9f2597789f54336c
scripts/envVar.sh: line 100: [: too many arguments
Chaincode is installed on peer0.org1
Install chaincode on peer0.org2...
Using organization 2
+ peer lifecycle chaincode queryinstalled --output json
+ grep '^basic_1.0.1:245a00c5a8183f30c2b2455eed0ca2650793fdc76f65442e9f2597789f54336c$'
+ jq -r 'try (.installed_chaincodes[].package_id)'
+ test 0 -ne 0
basic_1.0.1:245a00c5a8183f30c2b2455eed0ca2650793fdc76f65442e9f2597789f54336c
scripts/envVar.sh: line 100: [: too many arguments
Chaincode is installed on peer0.org2
++ peer lifecycle chaincode querycommitted --channelID mychannel --name basic
++ sed -n '/Version:/{s/.*Sequence: //; s/, Endorsement Plugin:.*$//; p;}'
+ COMMITTED_CC_SEQUENCE=1
+ res=0
++ peer lifecycle chaincode queryapproved --channelID mychannel --name basic
++ sed -n '/sequence:/{s/^sequence: //; s/, version:.*$//; p;}'
+ APPROVED_CC_SEQUENCE=1
+ res=0
Using organization 1
+ peer lifecycle chaincode queryinstalled --output json
+ jq -r 'try (.installed_chaincodes[].package_id)'
+ grep '^basic_1.0.1:245a00c5a8183f30c2b2455eed0ca2650793fdc76f65442e9f2597789f54336c$'
+ res=0
basic_1.0.1:245a00c5a8183f30c2b2455eed0ca2650793fdc76f65442e9f2597789f54336c
Query installed successful on peer0.org1 on channel
Using organization 1
+ peer lifecycle chaincode approveformyorg -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile /home/ubuntu/fabric-samples/test-network/organizations/ordererOrganizations/example.com/tlsca/tlsca.example.com-cert.pem --channelID mychannel --name basic --version 1.0.1 --package-id basic_1.0.1:245a00c5a8183f30c2b2455eed0ca2650793fdc76f65442e9f2597789f54336c --sequence 2
+ res=0
2024-03-13 02:41:04.591 UTC 0001 INFO [chaincodeCmd] ClientWait -> txid [fd5632166d99b8edda22bf991a75f5102c866ec835c7290fb58775c876545ccd] committed with status (VALID) at localhost:7051
Chaincode definition approved on peer0.org1 on channel 'mychannel'
Using organization 1
Checking the commit readiness of the chaincode definition on peer0.org1 on channel 'mychannel'...
Attempting to check the commit readiness of the chaincode definition on peer0.org1, Retry after 3 seconds.
+ peer lifecycle chaincode checkcommitreadiness --channelID mychannel --name basic --version 1.0.1 --sequence 2 --output json
+ res=0
{
	"approvals": {
		"Org1MSP": true,
		"Org2MSP": false
	}
}
Checking the commit readiness of the chaincode definition successful on peer0.org1 on channel 'mychannel'
Using organization 2
Checking the commit readiness of the chaincode definition on peer0.org2 on channel 'mychannel'...
Attempting to check the commit readiness of the chaincode definition on peer0.org2, Retry after 3 seconds.
+ peer lifecycle chaincode checkcommitreadiness --channelID mychannel --name basic --version 1.0.1 --sequence 2 --output json
+ res=0
{
	"approvals": {
		"Org1MSP": true,
		"Org2MSP": false
	}
}
Checking the commit readiness of the chaincode definition successful on peer0.org2 on channel 'mychannel'
Using organization 2
+ peer lifecycle chaincode approveformyorg -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile /home/ubuntu/fabric-samples/test-network/organizations/ordererOrganizations/example.com/tlsca/tlsca.example.com-cert.pem --channelID mychannel --name basic --version 1.0.1 --package-id basic_1.0.1:245a00c5a8183f30c2b2455eed0ca2650793fdc76f65442e9f2597789f54336c --sequence 2
+ res=0
2024-03-13 02:41:13.148 UTC 0001 INFO [chaincodeCmd] ClientWait -> txid [1728af7a6204595fa7e5a33bd6ad9551e507628e682e17211609cc12b0a85d58] committed with status (VALID) at localhost:9051
Chaincode definition approved on peer0.org2 on channel 'mychannel'
Using organization 1
Checking the commit readiness of the chaincode definition on peer0.org1 on channel 'mychannel'...
Attempting to check the commit readiness of the chaincode definition on peer0.org1, Retry after 3 seconds.
+ peer lifecycle chaincode checkcommitreadiness --channelID mychannel --name basic --version 1.0.1 --sequence 2 --output json
+ res=0
{
	"approvals": {
		"Org1MSP": true,
		"Org2MSP": true
	}
}
Checking the commit readiness of the chaincode definition successful on peer0.org1 on channel 'mychannel'
Using organization 2
Checking the commit readiness of the chaincode definition on peer0.org2 on channel 'mychannel'...
Attempting to check the commit readiness of the chaincode definition on peer0.org2, Retry after 3 seconds.
+ peer lifecycle chaincode checkcommitreadiness --channelID mychannel --name basic --version 1.0.1 --sequence 2 --output json
+ res=0
{
	"approvals": {
		"Org1MSP": true,
		"Org2MSP": true
	}
}
Checking the commit readiness of the chaincode definition successful on peer0.org2 on channel 'mychannel'
Using organization 1
Using organization 2
+ peer lifecycle chaincode commit -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile /home/ubuntu/fabric-samples/test-network/organizations/ordererOrganizations/example.com/tlsca/tlsca.example.com-cert.pem --channelID mychannel --name basic --peerAddresses localhost:7051 --tlsRootCertFiles /home/ubuntu/fabric-samples/test-network/organizations/peerOrganizations/org1.example.com/tlsca/tlsca.org1.example.com-cert.pem --peerAddresses localhost:9051 --tlsRootCertFiles /home/ubuntu/fabric-samples/test-network/organizations/peerOrganizations/org2.example.com/tlsca/tlsca.org2.example.com-cert.pem --version 1.0.1 --sequence 2
+ res=0
2024-03-13 02:41:22.753 UTC 0001 INFO [chaincodeCmd] ClientWait -> txid [b09486f1d8f0f88e6645e81c27c17da0e24dd9794309e8820a950bd4b4d1c156] committed with status (VALID) at localhost:9051
2024-03-13 02:41:22.764 UTC 0002 INFO [chaincodeCmd] ClientWait -> txid [b09486f1d8f0f88e6645e81c27c17da0e24dd9794309e8820a950bd4b4d1c156] committed with status (VALID) at localhost:7051
Chaincode definition committed on channel 'mychannel'
Using organization 1
Querying chaincode definition on peer0.org1 on channel 'mychannel'...
Attempting to Query committed status on peer0.org1, Retry after 3 seconds.
+ peer lifecycle chaincode querycommitted --channelID mychannel --name basic
+ res=0
Committed chaincode definition for chaincode 'basic' on channel 'mychannel':
Version: 1.0.1, Sequence: 2, Endorsement Plugin: escc, Validation Plugin: vscc, Approvals: [Org1MSP: true, Org2MSP: true]
Query chaincode definition successful on peer0.org1 on channel 'mychannel'
Using organization 2
Querying chaincode definition on peer0.org2 on channel 'mychannel'...
Attempting to Query committed status on peer0.org2, Retry after 3 seconds.
+ peer lifecycle chaincode querycommitted --channelID mychannel --name basic
+ res=0
Committed chaincode definition for chaincode 'basic' on channel 'mychannel':
Version: 1.0.1, Sequence: 2, Endorsement Plugin: escc, Validation Plugin: vscc, Approvals: [Org1MSP: true, Org2MSP: true]
Query chaincode definition successful on peer0.org2 on channel 'mychannel'
Chaincode initialization is not required



==========================================================================================================================================================


		
		
	
		
 
 
 