#!/bin/bash
echo 'Instantiate for cuhkchannel too? [y/n]'
read ans

if [ "$ans" == "y" ]; then
    docker exec -e "CORE_PEER_ADDRESS=peer0.clubA.cuhk.com:7051" -e "CORE_PEER_LOCALMSPID=ClubAMSP" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/clubA.cuhk.com/users/Admin@clubA.cuhk.com/msp" cli peer chaincode instantiate -o orderer.hku.com:7050 -C cuhkchannel -n hkucc -v 1.0 -c '{"Args":["init"]}' -P "OR ('ClubBMSP.member','ClubAMSP.member')"
fi