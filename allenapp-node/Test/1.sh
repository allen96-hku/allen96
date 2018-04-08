#!/bin/bash

COUNTER=1

#docker exec $STR '{"Args":["initUser", "Alice"]}'

#printf "Create Account from user %s\n\tmin\tsec\n" "Alice" > 4_2Alice50ACtimelog.txt
#printf "Get History for user %s\n\tmin\tsec\n" "Alice" > 8_1getAliceHistory.txt
#printf "Get ac state by 2 fields for Owner and Balance %s\n\tmin\tsec\n" > 9_2_2getState2Fields.txt

./3_3_6_2fixedUsername.sh

while [ $COUNTER -lt 26 ]; do
    ./4_2Alice50ACtimelog.sh ${COUNTER}
    sleep 1
    ./8_1getUser.sh ${COUNTER}
    sleep 1
    ./9_2_2getState2Fields.sh ${COUNTER}
    sleep 1
    let COUNTER=COUNTER+1 
done

docker exec -e "CORE_PEER_LOCALMSPID=HallAMSP" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/hallA.hku.com/users/Admin@hallA.hku.com/msp" cli peer chaincode invoke -o orderer.hku.com:7050 -C hkuhall -n hkucc -c '{"Args":["getQueryfromString", "Owner", "Alice"]}' 2> temp.txt
cat temp.txt | tr "}},{" "\n" | grep -E 'ACNumber' | tr '\\\"' ' ' | sed 's/ //g' | cut -d$':' -f2 | sort | uniq > ./List/25ACfromAlice.txt

./7_2singlePAYtosingle.sh
./5_1DeleteAliceAC.sh