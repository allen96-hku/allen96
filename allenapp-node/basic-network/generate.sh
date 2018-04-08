#!/bin/sh
#
# Copyright IBM Corp All Rights Reserved
#
# SPDX-License-Identifier: Apache-2.0
#
export PATH=$GOPATH/src/github.com/hyperledger/fabric/build/bin:${PWD}/../bin:${PWD}:$PATH
export FABRIC_CFG_PATH=${PWD}

# remove previous crypto material and config transactions
rm -fr config/*
rm -fr crypto-config/*

# generate crypto material
../bin/cryptogen generate --config=./crypto-config.yaml

# generate genesis block for orderer
mkdir channel-artifacts

../bin/configtxgen -profile SixOrgsOrdererGenesis -outputBlock ./channel-artifacts/genesis.block


# generate channel configuration transaction
../bin/configtxgen -profile FourOrgsChannel -outputCreateChannelTx ./channel-artifacts/hkuhall.tx -channelID hkuhall
../bin/configtxgen -profile TwoOrgsChannel -outputCreateChannelTx ./channel-artifacts/cuhkchannel.tx -channelID cuhkchannel

../bin/configtxgen -profile FourOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/HallAMSPanchors.tx -channelID hkuhall -asOrg HallAMSP
../bin/configtxgen -profile FourOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/HallBMSPanchorsHKU.tx -channelID hkuhall -asOrg HallBMSP
../bin/configtxgen -profile FourOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/HallBMSPanchorsCU.tx -channelID cuhkchannel -asOrg HallBMSP


