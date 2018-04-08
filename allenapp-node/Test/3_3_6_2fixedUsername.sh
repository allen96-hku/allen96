#!/bin/bash

printf "Create user with the same username %s\n\tmin\tsec\n" "Alice" > 3_3fixedUsername.txt
printf "Del user with the same username %s\n\tmin\tsec\n" "Alice" > 6_2delfixedUsername.txt
COUNTER=1

STR='-e "CORE_PEER_LOCALMSPID=HallAMSP" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/hallA.hku.com/users/Admin@hallA.hku.com/msp" cli peer chaincode invoke -o orderer.hku.com:7050 -C hkuhall -n hkucc -c'

loop(){
    printf "$1:\t" >> 6_2delfixedUsername.txt
    (time docker exec $STR '{"Args":["delUser", "'$2'"]}' 2>/dev/null) &> temp.txt
    grep "real" temp.txt | cut -d$'\t' -f2 | sed 's/m/      /g' | cut -d 's' -f1 >>6_2delfixedUsername.txt
    sleep 2   
    printf "$1:\t" >> 3_3fixedUsername.txt
    (time docker exec $STR '{"Args":["initUser", "'$2'"]}' 2>/dev/null) &> temp.txt
    grep "real" temp.txt | cut -d$'\t' -f2 | sed 's/m/      /g' | cut -d 's' -f1 >>3_3fixedUsername.txt
    sleep 2
}

while [ $COUNTER -lt 26 ]; do
    loop $COUNTER 'Alice'
    let COUNTER=COUNTER+1 
done