#!/bin/bash
#
# Copyright IBM Corp All Rights Reserved
#
# SPDX-License-Identifier: Apache-2.0
#
# Exit on first error, print all commands.
set -ev

# don't rewrite paths for Windows Git Bash users
export MSYS_NO_PATHCONV=1

docker-compose -f docker-compose.yaml down

COMPOSE_PROJECT_NAME=hkunetwork docker-compose -f docker-compose.yaml up -d

# wait for Hyperledger Fabric to start
# incase of errors when running later commands, issue export FABRIC_START_TIMEOUT=<larger number>
export FABRIC_START_TIMEOUT=10
#echo ${FABRIC_START_TIMEOUT}
sleep ${FABRIC_START_TIMEOUT}

# Create the channel
docker exec cli peer channel create -o orderer.hku.com:7050 -c hkuhall -f /opt/gopath/src/github.com/hyperledger/fabric/peer/channel-artifacts/hkuhall.tx 
#--tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/hku.com/orderers/orderer.hku.com/msp/tlscacerts/tlsca.hku.com-cert.pem

sleep 5

# Join peer0.hallA.hku.com  to the channel.
docker exec cli peer channel join -b hkuhall.block

sleep 5

# Join peer1.hallA.hku.com  to the channel.
docker exec -e "CORE_PEER_ADDRESS=peer1.hallA.hku.com:7051" -e "CORE_PEER_LOCALMSPID=HallAMSP" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/hallA.hku.com/users/Admin@hallA.hku.com/msp" cli peer channel join -b hkuhall.block

sleep 5

# Join peer0.hallB.hku.com  to the channel.
docker exec -e "CORE_PEER_ADDRESS=peer0.hallB.hku.com:7051" -e "CORE_PEER_LOCALMSPID=HallBMSP" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/hallB.hku.com/users/Admin@hallB.hku.com/msp" cli peer channel join -b hkuhall.block

sleep 5

# Join peer1.hallB.hku.com  to the channel.
docker exec -e "CORE_PEER_ADDRESS=peer1.hallB.hku.com:7051" -e "CORE_PEER_LOCALMSPID=HallBMSP" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/hallB.hku.com/users/Admin@hallB.hku.com/msp" cli peer channel join -b hkuhall.block


sleep 5

# Create another channel
docker exec -e "CORE_PEER_ADDRESS=peer0.clubA.cuhk.com:7051" -e "CORE_PEER_LOCALMSPID=ClubAMSP" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/clubA.cuhk.com/users/Admin@clubA.cuhk.com/msp" cli peer channel create -o orderer.hku.com:7050 -c cuhkchannel -f /opt/gopath/src/github.com/hyperledger/fabric/peer/channel-artifacts/cuhkchannel.tx 

sleep 5

# Join peer0.clubA.cuhk.com  to the channel.
docker exec -e "CORE_PEER_ADDRESS=peer0.clubA.cuhk.com:7051" -e "CORE_PEER_LOCALMSPID=ClubAMSP" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/clubA.cuhk.com/users/Admin@clubA.cuhk.com/msp" cli peer channel join -b cuhkchannel.block

sleep 5

# Join peer0.clubB.cuhk.com  to the channel.
docker exec -e "CORE_PEER_ADDRESS=peer0.clubB.cuhk.com:7051" -e "CORE_PEER_LOCALMSPID=ClubBMSP" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/clubB.cuhk.com/users/Admin@clubB.cuhk.com/msp" cli peer channel join -b cuhkchannel.block
