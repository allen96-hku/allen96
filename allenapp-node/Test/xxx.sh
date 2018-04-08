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
		joinWithRetry $1
	else
		COUNTER=1
	fi
  verifyResult $res "After 3 attempts, PEER has failed to Join the Channel"
}

joinWithRetry "${STR}"

