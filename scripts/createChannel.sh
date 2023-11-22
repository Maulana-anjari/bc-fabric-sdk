#!/usr/bin/env bash

# Note: this file is to be called from ../network.sh

# Configure environment variables
export CORE_PEER_TLS_ENABLED=true
export AAUI_CA=${PWD}/organizations/ordererOrganizations/aaui.org/orderers/orderer.aaui.org/msp/tlscacerts/tlsca.aaui.org-cert.pem

export PEER0_PRUDENTIAL_CA=${PWD}/organizations/peerOrganizations/prudential.co.id/peers/peer0.prudential.co.id/tls/ca.crt
export PEER0_PRUDENTIAL_PORT=7051

export PEER0_MANULIFE_CA=${PWD}/organizations/peerOrganizations/manulife.co.id/peers/peer0.manulife.co.id/tls/ca.crt
export PEER0_MANULIFE_PORT=8051

export PEER0_ALLIANZ_CA=${PWD}/organizations/peerOrganizations/allianz.co.id/peers/peer0.allianz.co.id/tls/ca.crt
export PEER0_ALLIANZ_PORT=9051

export FABRIC_CFG_PATH=${PWD}/config/

export AAUI_PORT=5050
export AAUI_HOST=orderer.aaui.org

CHANNEL_NAME="network-health-insurance"

########################################################################################################################
# Functions definition

setGlobalsForPeer0Prudential(){
    export CORE_PEER_LOCALMSPID="PrudentialMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_PRUDENTIAL_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/prudential.co.id/users/Admin@prudential.co.id/msp
    export CORE_PEER_ADDRESS=localhost:$PEER0_PRUDENTIAL_PORT
}

setGlobalsForPeer0Manulife(){
    export CORE_PEER_LOCALMSPID="ManulifeMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_MANULIFE_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/manulife.co.id/users/Admin@manulife.co.id/msp
    export CORE_PEER_ADDRESS=localhost:$PEER0_MANULIFE_PORT
}

setGlobalsForPeer0Allianz(){
    export CORE_PEER_LOCALMSPID="AllianzMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_ALLIANZ_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/allianz.co.id/users/Admin@allianz.co.id/msp
    export CORE_PEER_ADDRESS=localhost:$PEER0_ALLIANZ_PORT
}

createChannel(){
    # rm -rf ./channel-artifacts/*
    setGlobalsForPeer0Prudential
    
    peer channel create -o localhost:$AAUI_PORT -c $CHANNEL_NAME \
    --ordererTLSHostnameOverride $AAUI_HOST \
    -f ./channel-artifacts/${CHANNEL_NAME}.tx --outputBlock ./channel-artifacts/${CHANNEL_NAME}.block \
    --tls $CORE_PEER_TLS_ENABLED --cafile $AAUI_CA
}

joinChannel(){
    setGlobalsForPeer0Prudential
    peer channel join -b ./channel-artifacts/$CHANNEL_NAME.block

    setGlobalsForPeer0Manulife
    peer channel join -b ./channel-artifacts/$CHANNEL_NAME.block 

    setGlobalsForPeer0Allianz
    peer channel join -b ./channel-artifacts/$CHANNEL_NAME.block
}

updateAnchorPeers(){
    setGlobalsForPeer0Prudential
    peer channel update -o localhost:$AAUI_PORT --ordererTLSHostnameOverride $AAUI_HOST -c $CHANNEL_NAME \
    -f ./channel-artifacts/${CORE_PEER_LOCALMSPID}anchors.tx --tls $CORE_PEER_TLS_ENABLED --cafile $AAUI_CA
    
    setGlobalsForPeer0Manulife
    peer channel update -o localhost:$AAUI_PORT --ordererTLSHostnameOverride $AAUI_HOST -c $CHANNEL_NAME \
    -f ./channel-artifacts/${CORE_PEER_LOCALMSPID}anchors.tx --tls $CORE_PEER_TLS_ENABLED --cafile $AAUI_CA

    setGlobalsForPeer0Allianz
    peer channel update -o localhost:$AAUI_PORT --ordererTLSHostnameOverride $AAUI_HOST -c $CHANNEL_NAME \
    -f ./channel-artifacts/${CORE_PEER_LOCALMSPID}anchors.tx --tls $CORE_PEER_TLS_ENABLED --cafile $AAUI_CA
}

# Start here
echo "==================================== Creating the Channel ========================================================"
createChannel

echo "==================================== Joining the Channel ========================================================="
joinChannel

echo "==================================== Updating Anchor Peers ======================================================="
updateAnchorPeers
