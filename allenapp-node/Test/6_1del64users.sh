#!/bin/bash

printf "Delete user with the variable length of username\n\tmin\tsec\n" > 6_1del64users.txt
COUNTER=1

STR='-e "CORE_PEER_LOCALMSPID=HallAMSP" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/hallA.hku.com/users/Admin@hallA.hku.com/msp" cli peer chaincode invoke -o orderer.hku.com:7050 -C hkuhall -n hkucc -c'

loop(){
    printf "$1:\t" >> 6_1del64users.txt
    (time docker exec $STR '{"Args":["delUser", "'$2'"]}' 2>/dev/null) &> temp.txt
    grep "real" temp.txt | cut -d$'\t' -f2 | sed 's/m/      /g' | cut -d 's' -f1 >>6_1del64users.txt
}


while read p || [[ -n $p ]]; do
    loop $COUNTER $p
    let COUNTER=COUNTER+1 
done <./List/64differentusers1.txt

#6_1del64users