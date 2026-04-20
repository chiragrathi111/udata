#!/bin/bash

LOG_FILE="/var/log/ec2-startup.log"

# Clear old log safely (max 1MB backup)
[ -f $LOG_FILE ] && cp $LOG_FILE ${LOG_FILE}.bak
echo "" > $LOG_FILE

log() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a $LOG_FILE
}

log "===== EC2 Startup Script Started ====="

set -e  # Stop script if any command fails

# -----------------------------------
# 1. Start ActiveMQ
# -----------------------------------
log "Starting ActiveMQ..."
cd /opt/activemq/bin
./activemq start >> $LOG_FILE 2>&1 || log "ActiveMQ already running"

sleep 10

# -----------------------------------
# 2. Start Fabric Network
# -----------------------------------
log "Starting Fabric Network..."
cd /home/ubuntu/fabric-samples/test-network

./network.sh up -ca -s couchdb >> $LOG_FILE 2>&1

log "Waiting for containers..."
sleep 20

docker ps >> $LOG_FILE 2>&1

# -----------------------------------
# 3. Wait for Peer Ready
# -----------------------------------
log "Checking peer readiness..."

for i in {1..12}
do
    if netstat -tulnp | grep 7051 > /dev/null; then
        log "Peer is ready!"
        break
    fi
    log "Waiting for peer..."
    sleep 10
done

# -----------------------------------
# 4. Set Fabric ENV
# -----------------------------------
export PATH=${PWD}/../bin:$PATH
export FABRIC_CFG_PATH=$PWD/../config/
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="Org1MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
export CORE_PEER_ADDRESS=localhost:7051

log "Waiting for RAFT leader election..."
sleep 30

# -----------------------------------
# 5. Init Ledger (only once)
# -----------------------------------
log "Initializing Ledger..."

peer chaincode query -C mychannel -n basic -c '{"Args":["GetAllAssets"]}' > /dev/null 2>&1

if [ $? -ne 0 ]; then
    log "Ledger not initialized. Running InitLedger..."
    
    peer chaincode invoke -o localhost:7050 \
    --ordererTLSHostnameOverride orderer.example.com \
    --tls \
    --cafile "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem" \
    -C mychannel -n basic \
    --peerAddresses localhost:7051 \
    --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt" \
    --peerAddresses localhost:9051 \
    --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt" \
    -c '{"function":"InitLedger","Args":[]}' >> $LOG_FILE 2>&1
else
    log "Ledger already initialized. Skipping."
fi

# -----------------------------------
# 6. Node + PM2
# -----------------------------------
log "Starting Node App..."

export NVM_DIR="/home/ubuntu/.nvm"
source $NVM_DIR/nvm.sh
export PATH=/home/ubuntu/.nvm/versions/node/v18.20.3/bin:$PATH

cd /home/ubuntu/fabric-samples/asset-transfer-basic/chaincode-typescript/src
nvm use 18 >> $LOG_FILE 2>&1
npm run build >> $LOG_FILE 2>&1

cd /home/ubuntu/fabric-samples/asset-transfer-basic/application-gateway-typescript/src
nvm use 18 >> $LOG_FILE 2>&1
npm run build >> $LOG_FILE 2>&1

cd /home/ubuntu/fabric-samples/asset-transfer-basic/application-gateway-typescript/

nvm use 18 >> $LOG_FILE 2>&1

pm2 update >> $LOG_FILE 2>&1 || true
pm2 kill >> $LOG_FILE 2>&1 || true
pm2 start dist/app.js --name app >> $LOG_FILE 2>&1
pm2 save >> $LOG_FILE 2>&1

pm2 list >> $LOG_FILE 2>&1

log "===== Startup Completed Successfully ====="

#-------------------------------------------------------------------
# We need one file 
# touch /var/log/ec2-startup.log

# if gotting any error use sudo

# sudo touch /var/log/ec2-startup.log

# after that change owner

# sudo chown ubuntu:ubuntu ec2-startup.log

# after that we need run that script file in deamon side  

# sudo nano /etc/systemd/system/ec2-startup.service

# enter below line 

# [Unit]
# Description=EC2 Full Startup Script
# After=network.target docker.service

# [Service]
# Type=oneshot
# User=ubuntu
# ExecStart=/opt/start-all.sh
# RemainAfterExit=yes
# TimeoutStartSec=0

# [Install]
# WantedBy=multi-user.target

# after save run below commnds:-

# sudo systemctl daemon-reexec
# sudo systemctl daemon-reload
# sudo systemctl enable ec2-startup
# sudo systemctl start ec2-startup

# OR 

# sudo systemctl restart ec2-startup