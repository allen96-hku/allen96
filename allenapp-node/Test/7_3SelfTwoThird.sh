#!/bin/bash

printf "Test for paying 2/3 money\n" > 7_3SelfTwoThird.txt
printf "Created AC from user Alice and add 1 to her ac\n\tmin\tsec\tPayer Balance\t\tReceiver Balance\n" >> 7_3SelfTwoThird.txt


COUNTER=0

STR='-e "CORE_PEER_LOCALMSPID=HallAMSP" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/hallA.hku.com/users/Admin@hallA.hku.com/msp" cli peer chaincode invoke -o orderer.hku.com:7050 -C hkuhall -n hkucc -c'

docker exec $STR '{"Args":["initAC", "Alice"]}' &>/dev/null
sleep 3
docker exec $STR '{"Args":["initAC", "Alice"]}' &>/dev/null
sleep 3
docker exec $STR '{"Args":["addValue", "17011b53193b3ceca", "20"]}' &>/dev/null
sleep 3

loop(){
    AMOUNT=$(bc -l <<< "2/3")
    printf "$1:\t" >> 7_3SelfTwoThird.txt
    (time docker exec $STR '{"Args":["pay", "17011b53193b3ceca", "1dc01b043d05307b5", "'$AMOUNT'", "'$1'"]}' 2>err.txt)  &> temp.txt
    grep "real" temp.txt | cut -d$'\t' -f2 | sed 's/m/      /g' | cut -d 's' -f1 | tr "\n" "\t" >>7_3SelfTwoThird.txt
    sleep 2
    docker exec $STR '{"Args":["getQueryfromString", "ACNumber", "17011b53193b3ceca"]}' 2> temp.txt
    cat temp.txt | tr "}},{" "\n" | grep -E 'Balance' | tr '\\\"' ' ' | sed 's/ //g' | cut -d$':' -f2 | sort | uniq | tr "\n" "\t" >> 7_3SelfTwoThird.txt
    docker exec $STR '{"Args":["getQueryfromString", "ACNumber", "1dc01b043d05307b5"]}' 2> temp.txt
    cat temp.txt | tr "}},{" "\n" | grep -E 'Balance' | tr '\\\"' ' ' | sed 's/ //g' | cut -d$':' -f2 | sort | uniq >> 7_3SelfTwoThird.txt
    sleep 2
}

while [ $COUNTER -lt 30 ]; do
    loop $COUNTER
    let COUNTER=COUNTER+1
done

docker exec $STR '{"Args":["getQueryfromString", "Name", "Alice"]}' 2> temp.txt
printf "Final equity of user:\t" >> 7_3SelfTwoThird.txt
cat temp.txt | tr "}},{" "\n" | grep -E 'Equity' | tr '\\\"' ' ' | sed 's/ //g' | cut -d$':' -f2 | sort | uniq >> 7_3SelfTwoThird.txt