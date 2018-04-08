#!/bin/bash

printf "Del ac with the same username\n\tmin\tsec\n" > 5_1Delete50AC.txt
COUNTER=1

STR='-e "CORE_PEER_LOCALMSPID=HallAMSP" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/hallA.hku.com/users/Admin@hallA.hku.com/msp" cli peer chaincode invoke -o orderer.hku.com:7050 -C hkuhall -n hkucc -c'

loop(){
    printf "$1:\t" >> 5_1Delete50AC.txt
    (time docker exec $STR '{"Args":["delAC", "'$2'"]}' 2>>/dev/null) &> temp.txt
    grep "real" temp.txt | cut -d$'\t' -f2 | sed 's/m/      /g' | cut -d 's' -f1 >>5_1Delete50AC.txt
}


while read p || [[ -n $p ]]; do
    loop $COUNTER $p
    let COUNTER=COUNTER+1
    sleep 2
done <./List/25ACfromAlice.txt

#5_1Delete50AC