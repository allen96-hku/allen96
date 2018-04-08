#!/bin/bash

printf "Paying variable amount of money to ac from diff user\n" > 7_1singlePAYtoMany.txt
printf "Created AC from user Alice and add 208 to her ac\n\tmin\tsec\tBalance\n" >> 7_1singlePAYtoMany.txt

printf "Created AC from user Alice and add 208 to her ac\nmin\tsec\n" > 9_2_1getState1Field.txt

COUNTER=1

STR='-e "CORE_PEER_LOCALMSPID=HallAMSP" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/hallA.hku.com/users/Admin@hallA.hku.com/msp" cli peer chaincode invoke -o orderer.hku.com:7050 -C hkuhall -n hkucc -c'

docker exec $STR '{"Args":["initAC", "Alice"]}' &>/dev/null
sleep 3
docker exec $STR '{"Args":["addValue", "17011b53193b3ceca", "208.000"]}' &>/dev/null
sleep 3

loop(){
    AMOUNT=$(bc -l <<< "$1/10")
    NONCE=$(($1-1))
    printf "$1:\t" >> 7_1singlePAYtoMany.txt
    (time docker exec $STR '{"Args":["pay", "17011b53193b3ceca", "'$2'", "'$AMOUNT'", "'$NONCE'"]}' 2>/dev/null) &> temp.txt
    grep "real" temp.txt | cut -d$'\t' -f2 | sed 's/m/      /g' | cut -d 's' -f1 | tr "\n" "\t" >>7_1singlePAYtoMany.txt
}

while read p || [[ -n $p ]]; do
    loop $COUNTER $p
    let COUNTER=COUNTER+1
    sleep 2
    (time docker exec $STR '{"Args":["getQueryfromString", "ACNumber", "17011b53193b3ceca"]}' 2> temp2.txt) &> temp.txt
    grep "real" temp.txt | cut -d$'\t' -f2 | sed 's/m/      /g' | cut -d 's' -f1 >>9_2_1getState1Field.txt
    cat temp2.txt | tr "}},{" "\n" | grep -E 'Balance' | tr '\\\"' ' ' | sed 's/ //g' | cut -d$':' -f2 | sort | uniq >> 7_1singlePAYtoMany.txt
done <./List/64ACfromuser.txt

#6_1del64users