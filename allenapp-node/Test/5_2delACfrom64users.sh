#!/bin/bash

printf "Del account of the users with variable username\n\tmin\tsec\n" > 5_2delACfrom64users.txt
COUNTER=1

STR='-e "CORE_PEER_LOCALMSPID=HallAMSP" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/hallA.hku.com/users/Admin@hallA.hku.com/msp" cli peer chaincode invoke -o orderer.hku.com:7050 -C hkuhall -n hkucc -c'

docker exec -e "CORE_PEER_LOCALMSPID=HallAMSP" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/hallA.hku.com/users/Admin@hallA.hku.com/msp" cli peer chaincode invoke -o orderer.hku.com:7050 -C hkuhall -n hkucc -c '{"Args":["getQueryfromString", "docType", "account"]}' 2> temp.txt
cat temp.txt | tr "}},{" "\n" | grep -E 'ACNumber' | tr '\\\"' ' ' | sed 's/ //g' | cut -d$':' -f2 | sort | uniq > ./List/64ACfromuser.txt

loop(){
    printf "$1:\t" >> 5_2delACfrom64users.txt
    (time docker exec $STR '{"Args":["delAC", "'$2'"]}' 2>/dev/null) &> temp.txt
    grep "real" temp.txt | cut -d$'\t' -f2 | sed 's/m/      /g' | cut -d 's' -f1 >>5_2delACfrom64users.txt
}


while read p || [[ -n $p ]]; do
    loop $COUNTER $p
    let COUNTER=COUNTER+1 
done <./List/64ACfromuser.txt

#5_2delACfrom64users.