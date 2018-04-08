#!/bin/bash

printf "Paying variable amount of money to ac from same user\n" > 7_2singlePAYtosingle.txt
printf "Created AC from user Alice and add 95000000000000000 to her ac\n\tmin\tsec\tBalance\n" >> 7_2singlePAYtosingle.txt


COUNTER=1

STR='-e "CORE_PEER_LOCALMSPID=HallAMSP" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/hallA.hku.com/users/Admin@hallA.hku.com/msp" cli peer chaincode invoke -o orderer.hku.com:7050 -C hkuhall -n hkucc -c'

docker exec $STR '{"Args":["addValue", "17011b53193b3ceca", "95000000000000000"]}' &>/dev/null
sleep 3

loop(){
    AMOUNT=$(bc -l <<< "$1*300000000000000")
    NONCE=$(($1-1))
    printf "$1:\t" >> 7_2singlePAYtosingle.txt
    (time docker exec $STR '{"Args":["pay", "17011b53193b3ceca", "'$2'", "'$AMOUNT'", "'$NONCE'"]}' 2>/dev/null)  &> temp.txt
    grep "real" temp.txt | cut -d$'\t' -f2 | sed 's/m/      /g' | cut -d 's' -f1 | tr "\n" "\t" >>7_2singlePAYtosingle.txt
    sleep 2
    docker exec $STR '{"Args":["getQueryfromString", "ACNumber", "'$2'"]}' 2> temp.txt
    cat temp.txt | tr "}},{" "\n" | grep -E 'Balance' | tr '\\\"' ' ' | sed 's/ //g' | cut -d$':' -f2 | sort | uniq >> 7_2singlePAYtosingle.txt
    sleep 3
}

while read p || [[ -n $p ]]; do
    if [ "$p" != "17011b53193b3ceca" ]; then
        loop $COUNTER $p
        let COUNTER=COUNTER+1
    fi
done <./List/25ACfromAlice.txt

