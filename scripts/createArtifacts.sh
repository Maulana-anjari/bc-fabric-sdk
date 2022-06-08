#!/usr/bin/env bash

# Note: this file is to be called from ../network.sh

# Generate Crypto artifacts for organizations
echo "==================================== Generating Cryptos ========================================================================"
cryptogen generate --config=./config/crypto-config.yaml --output=./organizations/

# System channel
SYS_CHANNEL="sys-channel"
CHANNEL_NAME="slinmac"

echo $CHANNEL_NAME

# Generate System Genesis block
echo "==================================== Generating Orderer Genesis ========================================================================"
configtxgen -profile OrdererGenesis -configPath ./config/ -channelID $SYS_CHANNEL  -outputBlock ./channel-artifacts/genesis.block

echo "==================================== Generating Channel Genesis ========================================================================"
# Generate channel configuration block
configtxgen -profile BasicChannel -configPath ./config/ -outputCreateChannelTx ./channel-artifacts/slinmac.tx -channelID $CHANNEL_NAME

echo "==================================== Generating Anchor OperatorA ========================================================================"
configtxgen -profile BasicChannel -configPath ./config/ -outputAnchorPeersUpdate ./channel-artifacts/OperatorAMSPanchors.tx -channelID $CHANNEL_NAME -asOrg OperatorAMSP

echo "==================================== Generating Anchor OperatorB ========================================================================"
configtxgen -profile BasicChannel -configPath ./config/ -outputAnchorPeersUpdate ./channel-artifacts/OperatorBMSPanchors.tx -channelID $CHANNEL_NAME -asOrg OperatorBMSP

echo "==================================== Generating Anchor OperatorC ========================================================================"
configtxgen -profile BasicChannel -configPath ./config/ -outputAnchorPeersUpdate ./channel-artifacts/OperatorCMSPanchors.tx -channelID $CHANNEL_NAME -asOrg OperatorCMSP

# echo "==================================== Generating Connection Profiles ===================================="
# source ccp-generate.sh
