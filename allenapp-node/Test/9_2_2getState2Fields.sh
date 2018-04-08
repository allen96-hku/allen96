#!/bin/bash


STR='-e "CORE_PEER_LOCALMSPID=HallAMSP" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/hallA.hku.com/users/Admin@hallA.hku.com/msp" cli peer chaincode invoke -o orderer.hku.com:7050 -C hkuhall -n hkucc -c'

(time docker exec $STR '{"Args":["getQueryfromString", "Balance", "0", "Owner", "Alice"]}' 2>/dev/null) &> temp.txt
printf "$1:\t" >> 9_2_2getState2Fields.txt
grep "real" temp.txt | cut -d$'\t' -f2 | sed 's/m/      /g' | cut -d 's' -f1 >> 9_2_2getState2Fields.txt