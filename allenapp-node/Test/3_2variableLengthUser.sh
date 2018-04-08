#!/bin/bash

COUNTER=0

printf "Create user for users with variable length\n\tmin\tsec\n" > 3_2variableLengthUser.txt

loop() {
    printf "$1:\t" >> 3_2variableLengthUser.txt
    (time docker exec -e "CORE_PEER_LOCALMSPID=HallAMSP" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/hallA.hku.com/users/Admin@hallA.hku.com/msp" cli peer chaincode invoke -o orderer.hku.com:7050 -C hkuhall -n hkucc -c '{"Args":["initUser", "'$2'"]}' 2>/dev/null) &> temp.txt
    grep "real" temp.txt | cut -d$'\t' -f2 | sed 's/m/      /g' | cut -d 's' -f1 >> 3_2variableLengthUser.txt
}


while read p || [[ -n $p ]]; do
  let COUNTER=COUNTER+1
  loop $COUNTER $p
done <./List/64differentusers1.txt