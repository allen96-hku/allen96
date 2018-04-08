#!/bin/bash
read -p "Run on peer [cons] [org] [peer#] :" CONS ORG PEER


if [ "$CONS" == "hku" ]; then
    docker exec -e "CORE_PEER_ADDRESS=peer$PEER.hall$ORG.hku.com:7051" -e "CORE_PEER_LOCALMSPID=Hall${ORG}MSP" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/hall$ORG.hku.com/users/Admin@hall$ORG.hku.com/msp" cli peer chaincode invoke -o orderer.hku.com:7050 -C hkuhall -n hkucc -c '{"Args":["initAC", "Alice"]}'
else
    docker exec -e "CORE_PEER_ADDRESS=peer$PEER.club$ORG.cuhk.com:7051" -e "CORE_PEER_LOCALMSPID=Club${ORG}MSP" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/club$ORG.cuhk.com/users/Admin@club$ORG.cuhk.com/msp" cli peer chaincode invoke -o orderer.hku.com:7050 -C cuhkchannel -n hkucc -c '{"Args":["initUser", "Alice"]}'
fi


