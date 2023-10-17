#!/usr/bin/env bash

# Note: this file is to be called from ../network.sh

# Generate (key material) Crypto artifacts for organizations 
echo "==================================== Generating Cryptos ========================================================================"
cryptogen generate --config=./config/crypto-config.yaml --output=./organizations/

# System channel
SYS_CHANNEL="sys-channel"
CHANNEL_NAME="pharma-chain"

echo $CHANNEL_NAME

# Generate System Genesis block
echo "==================================== Generating Orderer Genesis ========================================================================"
configtxgen -profile OrdererGenesis -configPath ./config/ -channelID $SYS_CHANNEL -outputBlock ./channel-artifacts/genesis.block

echo "==================================== Generating Channel Genesis ========================================================================"
# Generate channel configuration block
configtxgen -profile BasicChannel -configPath ./config/ -outputCreateChannelTx ./channel-artifacts/pharma-chain.tx -channelID $CHANNEL_NAME

echo "==================================== Generating Anchor Sardjito ========================================================================"
configtxgen -profile BasicChannel -configPath ./config/ -outputAnchorPeersUpdate ./channel-artifacts/SardjitoMSPanchors.tx -channelID $CHANNEL_NAME -asOrg SardjitoMSP

echo "==================================== Generating Anchor RSCM ========================================================================"
configtxgen -profile BasicChannel -configPath ./config/ -outputAnchorPeersUpdate ./channel-artifacts/RSCMMSPanchors.tx -channelID $CHANNEL_NAME -asOrg RSCMMSP

echo "==================================== Generating Anchor Dharmais ========================================================================"
configtxgen -profile BasicChannel -configPath ./config/ -outputAnchorPeersUpdate ./channel-artifacts/DharmaisMSPanchors.tx -channelID $CHANNEL_NAME -asOrg DharmaisMSP

# echo "==================================== Generating Connection Profiles ===================================="
# source ccp-generate.sh
