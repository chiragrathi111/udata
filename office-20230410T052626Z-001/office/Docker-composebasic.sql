TIPS
Docker compose
: tool for defining & running multi-container docker applications
: use yaml files to configure application services (docker-compose.yml)
: can start all services with a single command : docker compose up
: can stop all services with a single command : docker compose down
: can scale up selected services when required

Step 1 : install docker compose
   (already installed on windows and mac with docker)
   docker-compose -v
   
   2 Ways

   1.  https://github.com/docker/compose/rel...

   2. Using PIP
    pip install -U docker-compose

Step 2 : Create docker compose file at any location on your system
   docker-compose.yml

Step 3 : Check the validity of file by command
    docker-compose config

Step 4 : Run docker-compose.yml file by command
   docker-compose up -d

Steps 5 : Bring down application by command
   docker-compose down

TIPS
How to scale services

—scale
docker-compose up -d --scale database=4

/////All Docker images and container removeing

docker stop $(docker ps -a -q)  ; 
docker rm -f $(docker ps -aq) ; 
docker system prune -a ; 
docker volume prune ;
docker ps -a ; 
docker images -a ;
docker volume ls

// if all docker container and images removing then ca and couchdb images pull in latest but orderer and peer not comfort in latest, so some changes in oredrer and peer imagesh
# hyperledger/fabric-orderer:x86_64-1.0.0 // version showing
# docker pull hyperledger/fabric-peer:2.4
# docker tag hyperledger/fabric-peer:2.4 hyperledger/fabric-peer:latest
// this two line command in run our pc then docker images is pulling in latest mode
// This two line not put, direct command in orderer through peer image is create but container is not created.
//Every time create crypto-config folder to change ca keyfile everytime and change docker-compose.yml file ca container Environment change below line
FABRIC_CA_SERVER_CA_KEYFILE=/etc/hyperledger/fabric-ca-server-config/a44f1452c00ac8d8e555557a80100c16dc32cab6b958d1563f5d683ac46f6f43_sk
// change key value 


docker exec -e "CORE_PEER_LOCALMSPID=Org1MSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@org.realmeds.io/msp" peer0.org.realmeds.io peer channel create -o orderer.realmeds.io:7050 -c chiragchannel -f /etc/hyperledger/configtx/channel.tx

docker-compose -f ./docker-compose.yml up -d cli

docker exec -e "CORE_PEER_LOCALMSPID=Org1MSP" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.realmeds.io/users/Admin@org1.realmeds.io/msp" cli peer chaincode install -n realmeds -v 1.0 -p "$CC_SRC_PATH" -l "$CC_RUNTIME_LANGUAGE"

docker exec -e "CORE_PEER_LOCALMSPID=Org1MSP" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.realmeds.io/users/Admin@org1.realmeds.io/msp" cli peer chaincode install -n basic -v 1.0 -p /opt/gopath/src/github.com/ -l node


================================================================================================================================================================
Docker logs check in chaincode:-
docker ps (show all running Container First container is latest version chaincode and copy container id)
docker logs -f <container id>
and show logs