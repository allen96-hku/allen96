#!/bin/bash

loop (){
    (time docker exec -e "CORE_PEER_ADDRESS=peer$2.hall$1.hku.com:7051" -e "CORE_PEER_LOCALMSPID=Hall$1MSP" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/hall$1.hku.com/users/Admin@hall$1.hku.com/msp" cli peer chaincode invoke -o orderer.hku.com:7050 -C hkuhall -n hkucc -c '{"Args":["initAC", "Alice"]}' 2>>./temp/err$1$2.txt) &> ./temp/temp$1$2.txt
    printf "$3:\t" >> 4_1SimuInitAC$1$2.txt
    grep "real" ./temp/temp$1$2.txt | cut -d$'\t' -f2 | sed 's/m/      /g' | cut -d 's' -f1 >> 4_1SimuInitAC$1$2.txt
}

loop2 (){
    COUNTER=1
    printf "Init AC simultaneously on peer$2.hall$1 %s\n\tmin\tsec\n" > 4_1SimuInitAC$1$2.txt
    while [ $COUNTER -lt 6 ]; do
        loop $1 $2 $COUNTER
        let COUNTER=COUNTER+1
        sleep 2
    done
}

loop2 'A' '0' &
loop2 'A' '1' &
loop2 'B' '0' &
loop2 'B' '1' &