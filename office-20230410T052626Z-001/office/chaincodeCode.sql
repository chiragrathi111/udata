Chaincode method:-

peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.
˓→com --tls --cafile "${PWD}/organizations/ordererOrganizations/example.com/orderers/
˓→orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem" -C mychannel -n
˓→basic --peerAddresses localhost:7051 --tlsRootCertFiles "${PWD}/organizations/
˓→peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt" --
˓→peerAddresses localhost:9051 --tlsRootCertFiles "${PWD}/organizations/
˓→peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt" -c '{
˓→"function":"InitLedger","Args":[]}'







peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com 
--tls --cafile "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem" 
-C mychannel -n basic --peerAddresses localhost:7051 --tlsRootCertFiles "
${PWD}/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/tlsca.crt" 
--peerAddresses localhost:9051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/org2.example.com/users/Admin@org2.example.com/tls/ca.crt" 
-c '{"function":"InitLedger","Args":[]}'

complete remove commands:-

docker rm -f $(docker ps -aq)
docker rmi -f $(docker images -q)
docker network prune


If chaincode deploy three thing is more important part
1. network
2. path
3.language
tino init hone ke baad hi hum chaincode mai kush kar sakte chaincode
