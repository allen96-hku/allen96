#!/bin/bash

printf "Create user with abnormal username\n\n" > 3_1abnormalUsername.txt

STR='-e "CORE_PEER_LOCALMSPID=HallAMSP" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/hallA.hku.com/users/Admin@hallA.hku.com/msp" cli peer chaincode invoke -o orderer.hku.com:7050 -C hkuhall -n hkucc -c'

loop(){
    docker exec $STR '{"Args":["initUser", "'$2'"]}' 2>temp.txt
    printf "%-15s %-15s:" "$1" "($2)" >> 3_1abnormalUsername.txt
    d="`grep "Error" temp.txt | cut -d$':' -f1`"
    if [ "$d" == "" ] ; then
        echo "Correct!" >>3_1abnormalUsername.txt
    else
        echo $d >>3_1abnormalUsername.txt
    fi
}

######## Test 3.1 #########
# Space start
loop 'Space Start' ' Alice'
# Space End
loop 'Space End' 'Alice '
# Contain Space
loop 'Contain Space' 'Ali ce'
# Number start
loop 'Number Start' '2Alice'
# Contain symbol
loop 'Contain symbol' '_Alice'
loop 'Contain symbol' ',...&'
loop 'Contain symbol' './Z~.,sd'
loop 'Contain symbol' '?][{\e_+;.<?'
loop 'Contain symbol' '$A%^(\ne'
loop 'Contain symbol' ',!Alic!@#$%^&*()-=e'
# Correct input
loop 'Correct input' 'Dicky'