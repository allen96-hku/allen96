#!/bin/bash

STR='-e "CORE_PEER_LOCALMSPID=HallAMSP" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/hallA.hku.com/users/Admin@hallA.hku.com/msp" cli peer chaincode invoke -o orderer.hku.com:7050 -C hkuhall -n hkucc -c'

(time docker exec $STR '{"Args":["initAC", "Alice"]}' 2>/dev/null) &> temp.txt
printf "$1:\t" >> 4_2Alice50ACtimelog.txt
grep "real" temp.txt | cut -d$'\t' -f2 | sed 's/m/      /g' | cut -d 's' -f1 >> 4_2Alice50ACtimelog.txt