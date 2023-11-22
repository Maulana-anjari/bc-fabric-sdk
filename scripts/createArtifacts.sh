#!/usr/bin/env bash

# Note: this file is to be called from ../network.sh

# Generate (key material) Crypto artifacts for organizations 
echo "==================================== Generating Cryptos ========================================================================"
cryptogen generate --config=./config/crypto-config.yaml --output=./organizations/

# System channel
SYS_CHANNEL="sys-channel"
CHANNEL_NAME="network-health-insurance"

echo $CHANNEL_NAME

# Generate System Genesis block
echo "==================================== Generating Orderer Genesis ========================================================================"
configtxgen -profile OrdererGenesis -configPath ./config/ -channelID $SYS_CHANNEL -outputBlock ./channel-artifacts/genesis.block

echo "==================================== Generating Channel Genesis ========================================================================"
# Generate channel configuration block
configtxgen -profile BasicChannel -configPath ./config/ -outputCreateChannelTx ./channel-artifacts/network-health-insurance.tx -channelID $CHANNEL_NAME

echo "==================================== Generating Anchor Prudential ========================================================================"
configtxgen -profile BasicChannel -configPath ./config/ -outputAnchorPeersUpdate ./channel-artifacts/PrudentialMSPanchors.tx -channelID $CHANNEL_NAME -asOrg PrudentialMSP

echo "==================================== Generating Anchor Manulife ========================================================================"
configtxgen -profile BasicChannel -configPath ./config/ -outputAnchorPeersUpdate ./channel-artifacts/ManulifeMSPanchors.tx -channelID $CHANNEL_NAME -asOrg ManulifeMSP

echo "==================================== Generating Anchor Allianz ========================================================================"
configtxgen -profile BasicChannel -configPath ./config/ -outputAnchorPeersUpdate ./channel-artifacts/AllianzMSPanchors.tx -channelID $CHANNEL_NAME -asOrg AllianzMSP

# echo "==================================== Generating Connection Profiles ===================================="
# source ccp-generate.sh
