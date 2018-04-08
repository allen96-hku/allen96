#!/bin/bash
#
# Reference: IBM Corp
#
# SPDX-License-Identifier: Apache-2.0
#
# Exit on first error
#set -e

# don't rewrite paths for Windows Git Bash users
export MSYS_NO_PATHCONV=1
starttime=$(date +%s)
LANGUAGE=${1:-"golang"}
CC_SRC_PATH=github.com/chaincode/hkuchaincode/go

# clean the keystore
rm -rf ./hfc-key-store

# launch network; create channel and join peer to channel
cd ./basic-network
./start.sh
./rejoin.sh 2>/dev/null

# Now launch the CLI container in order to install, instantiate chaincode
# and prime the ledger with our 10 cars

docker exec -e "CORE_PEER_LOCALMSPID=HallAMSP" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/hallA.hku.com/users/Admin@hallA.hku.com/msp" cli peer chaincode install -n hkucc -v 0.1 -p "$CC_SRC_PATH" -l "$LANGUAGE"

sleep 10

docker exec -e "CORE_PEER_LOCALMSPID=HallAMSP" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/hallA.hku.com/users/Admin@hallA.hku.com/msp" cli peer chaincode instantiate -o orderer.hku.com:7050 -C hkuhall -n hkucc -l "$LANGUAGE" -v 0.1 -c '{"Args":["init"]}' -P "OR ('ClubBMSP.member','ClubAMSP.member')"

sleep 10

docker exec -e "CORE_PEER_LOCALMSPID=HallAMSP" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/hallA.hku.com/users/Admin@hallA.hku.com/msp" cli peer chaincode install -n hkucc -v 1.0 -p "$CC_SRC_PATH"

sleep 10

docker exec -e "CORE_PEER_LOCALMSPID=HallAMSP" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/hallA.hku.com/users/Admin@hallA.hku.com/msp" cli peer chaincode upgrade -o orderer.hku.com:7050 -C hkuhall -n hkucc -v 1.0  -c '{"Args":["init"]}'


sleep 10

docker exec -e "CORE_PEER_LOCALMSPID=HallAMSP" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/hallA.hku.com/users/Admin@hallA.hku.com/msp" cli peer chaincode invoke -o orderer.hku.com:7050 -C hkuhall -n hkucc -c '{"Args":["initUser", "Alice"]}'

sleep 10

#docker exec -e "CORE_PEER_LOCALMSPID=HallAMSP" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/hallA.hku.com/users/Admin@hallA.hku.com/msp" cli peer chaincode invoke -o orderer.hku.com:7050 -C hkuhall -n hkucc -c '{"Args":["initAC", "testing"]}'

docker rm -f dev-peer0.hallA.hku.com-hkucc-0.1


docker exec -e "CORE_PEER_ADDRESS=peer1.hallA.hku.com:7051" -e "CORE_PEER_LOCALMSPID=HallAMSP" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/hallA.hku.com/users/Admin@hallA.hku.com/msp" cli peer chaincode install -n hkucc -v 1.0 -p "github.com/chaincode/hkuchaincode/go"

docker exec -e "CORE_PEER_ADDRESS=peer0.hallB.hku.com:7051" -e "CORE_PEER_LOCALMSPID=HallBMSP" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/hallB.hku.com/users/Admin@hallB.hku.com/msp" cli peer chaincode install -n hkucc -v 1.0 -p "github.com/chaincode/hkuchaincode/go"

docker exec -e "CORE_PEER_ADDRESS=peer1.hallB.hku.com:7051" -e "CORE_PEER_LOCALMSPID=HallBMSP" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/hallB.hku.com/users/Admin@hallB.hku.com/msp" cli peer chaincode install -n hkucc -v 1.0 -p "github.com/chaincode/hkuchaincode/go"

docker exec -e "CORE_PEER_ADDRESS=peer0.clubA.cuhk.com:7051" -e "CORE_PEER_LOCALMSPID=ClubAMSP" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/clubA.cuhk.com/users/Admin@clubA.cuhk.com/msp" cli peer chaincode install -n hkucc -v 1.0 -p "$CC_SRC_PATH"

docker exec -e "CORE_PEER_ADDRESS=peer0.clubB.cuhk.com:7051" -e "CORE_PEER_LOCALMSPID=ClubBMSP" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/clubB.cuhk.com/users/Admin@clubB.cuhk.com/msp" cli peer chaincode install -n hkucc -v 1.0 -p "$CC_SRC_PATH"



printf "\nTotal setup execution time : $(($(date +%s) - starttime)) secs ...\n\n\n"