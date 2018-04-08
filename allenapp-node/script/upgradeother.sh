#!/bin/bash

docker exec -e "CORE_PEER_ADDRESS=peer1.hallA.hku.com:7051" -e "CORE_PEER_LOCALMSPID=HallAMSP" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/hallA.hku.com/users/Admin@hallA.hku.com/msp" cli peer chaincode upgrade -o orderer.hku.com:7050 -C hkuhall -n hkucc -v $1  -c '{"Args":["init"]}'

docker exec -e "CORE_PEER_ADDRESS=peer0.hallB.hku.com:7051" -e "CORE_PEER_LOCALMSPID=HallBMSP" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/hallB.hku.com/users/Admin@hallB.hku.com/msp" cli peer chaincode upgrade -o orderer.hku.com:7050 -C hkuhall -n hkucc -v $1  -c '{"Args":["init"]}'

docker exec -e "CORE_PEER_ADDRESS=peer1.hallB.hku.com:7051" -e "CORE_PEER_LOCALMSPID=HallBMSP" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/hallB.hku.com/users/Admin@hallB.hku.com/msp" cli peer chaincode upgrade -o orderer.hku.com:7050 -C hkuhall -n hkucc -v $1  -c '{"Args":["init"]}'

docker exec -e "CORE_PEER_ADDRESS=peer0.clubA.cuhk.com:7051" -e "CORE_PEER_LOCALMSPID=ClubAMSP" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/clubA.cuhk.com/users/Admin@clubA.cuhk.com/msp" cli peer chaincode upgrade -o orderer.hku.com:7050 -C cuhkchannel -n hkucc -v $1  -c '{"Args":["init"]}'

docker exec -e "CORE_PEER_ADDRESS=peer0.clubB.cuhk.com:7051" -e "CORE_PEER_LOCALMSPID=ClubBMSP" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/clubB.cuhk.com/users/Admin@clubB.cuhk.com/msp" cli peer chaincode upgrade -o orderer.hku.com:7050 -C cuhkchannel -n hkucc -v $1  -c '{"Args":["init"]}'