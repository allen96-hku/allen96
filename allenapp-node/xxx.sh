#!/bin/bash

COUNTER=1
STR='-e "CORE_PEER_ADDRESS=peer1.hallA.hku.com:7051" -e "CORE_PEER_LOCALMSPID=HallAMSP" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/hallA.hku.com/users/Admin@hallA.hku.com/msp"'
COUNTER=1



joinWithRetry () {
	docker exec $1 cli peer channel join -b hkuhall.block >&log.txt
	res=$?
	cat log.txt
	if [ $res -ne 0 -a $COUNTER -lt 3 ]; then
		COUNTER=` expr $COUNTER + 1`
		echo "PEER failed to join the channel, Retry after 2 seconds"
		sleep 5
		joinWithRetry "${1}"
	else
		COUNTER=1
	fi
  #verifyResult $res "After 3 attempts, PEER has failed to Join the Channel"
}

joinWithRetry "${STR}"


docker exec -e "CORE_PEER_LOCALMSPID=HallAMSP" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/hallA.hku.com/users/Admin@hallA.hku.com/msp" cli peer chaincode invoke -o orderer.hku.com:7050 -C hkuhall -n hkucc -c '{"Args":["initAC", "Alice"]}'

docker exec -e "CORE_PEER_LOCALMSPID=HallBMSP" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/hallB.hku.com/users/Admin@hallB.hku.com/msp" cli peer chaincode invoke -o orderer.hku.com:7050 -C hkuhall -n hkucc -c '{"Args":["initAC", "Alice"]}'

docker exec -e "CORE_PEER_ADDRESS=peer0.clubB.cuhk.com:7051" -e "CORE_PEER_LOCALMSPID=ClubBMSP" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/clubB.cuhk.com/users/Admin@clubB.cuhk.com/msp" cli peer chaincode invoke -o orderer.hku.com:7050 -C cuhkchannel -n hkucc -c '{"Args":["initAC", "Alice"]}'
cli peer chaincode upgrade -o orderer.hku.com:7050 -C cuhkchannel -n hkucc -v 1.0  -c '{"Args":["init"]}'
cli peer chaincode invoke -o orderer.hku.com:7050 -C cuhkchannel -n hkucc -c '{"Args":["initAC", "Alice"]}'