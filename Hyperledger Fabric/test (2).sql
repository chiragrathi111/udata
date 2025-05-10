# cd fabric-samples/test-network
If your system shut down then run command
#./network.sh up -s couchdb and run invoke command if any error path wise then enter path command
#./network.sh down
#./network.sh up createChannel -ca -s couchdb
if any reason above code throw error then run below command
#./network.sh up createChannel

and every work then added ca and couchdb not problem because i just try not facing any error
#./network.sh up -ca -s couchdb
and after this code then run invoke command
	all container launch and channel also joined 

Chaincode Install:-
#./network.sh deployCC -ccn basic -ccp ../asset-transfer-basic/chaincode-typescript -ccl typescript -ccv 1.0.3

Invoke command:-
#cd fabric-samples/test-network
#export PATH=${PWD}/../bin:$PATH
export FABRIC_CFG_PATH=$PWD/../config/
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="Org1MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
export CORE_PEER_ADDRESS=localhost:7051

main Invoke code
#peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem" -C mychannel -n basic --peerAddresses localhost:7051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt" --peerAddresses localhost:9051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt" -c '{"function":"InitLedger","Args":[]}'

Showing Message:-
2024-06-10 10:18:09.930 IST 0001 INFO [chaincodeCmd] chaincodeInvokeOrQuery -> Chaincode invoke successful. result: status:200
Process Done

Chaincode any update using command:-
#npm run build


API Gateway code:-
#node -v (first check node version 18)if not then throw error
#fabric-samples/asset-transfer-basic/application-gateway-typescript
#npm start (this explaine package.json file see one file or one more file to display tis commamd)
below also explaine how can add multiple file in same command

// "start": "node dist/app.js"
			
			running one file

"node dist/app.js && node dist/external-service.js"
	running two file


Install ActiveMq in Hyper ledger fabric:-
go visit Active Mq side and direct download
after download please start active mq other wise okay  	
	

	
	
	
	
=============================================================================
Active MQ:-
#fabric-samples/asset-transfer-basic/application-gateway-typescript
create new folder called typing
#mkdir typings
#cd typings
#touch stomp-client.d.ts
open file and paste this below code:-
--------------------------------------
declare module 'stomp-client' {
    interface Headers {
        [key: string]: string;
    }

    class StompClient {
        constructor(host: string, port: number, username?: string, password?: string, protocolVersion?: string);

        connect(callback: (sessionId: string) => void): void;
        disconnect(callback: () => void): void;
        publish(queueName: string, message: string, headers?: Headers): void;
        subscribe(queueName: string, callback: (body: string, headers: Headers) => void): void;
    }

    export = StompClient;
}
-----------------------------------------

update your existing tsconfig file:-
-----------------------------------------
{
  "extends": "@tsconfig/node18/tsconfig.json",
  "compilerOptions": {
    "experimentalDecorators": true,
    "emitDecoratorMetadata": true,
    "outDir": "dist",
    "declaration": true,
    "sourceMap": true,
    "noImplicitAny": true,
    "esModuleInterop": true, // Ensure compatibility with CommonJS modules
    "skipLibCheck": true, // Skip type checking of declaration files
    "forceConsistentCasingInFileNames": true
  },
  "include": [
    "./src/**/*",
    "./typings/**/*"
  ],
  "exclude": [
    "./src/**/*.spec.ts"
  ]
}
----------------------------------------

Update app.ts file inside src folder:-
-----------------------------------------
import StompClient from 'stomp-client';

// Connect to ActiveMQ
        const client = new StompClient('127.0.0.1', 61613, 'admin', 'admin');

        client.connect((sessionId: string) => {
            console.log('Connected to ActiveMQ with session ID: ' + sessionId);

            // Send a message
            client.publish('/queue/test', 'Hello, ActiveMQ!');

            // Subscribe to the queue
            client.subscribe('/queue/test', (body: string, headers: { [key: string]: string }) => {
                console.log('Received message from ActiveMQ: ' + body);
            });
        });
        
-----------------------------------------

all update file save and run build command
#npm run build       
this above code is working fine then run below command if show error then not run below command
#npm start  

	
========================================================================================	
If system restart or shut down then every time active mq restart command run like
	cd /home/chirag/Downloads/apache...../bin/
	./activemq start	
	
