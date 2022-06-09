#!/usr/bin/env bash

# Note: this file is to be called from ../network.sh

# Configure environment variables
export CORE_PEER_TLS_ENABLED=true
export IAEA_CA=${PWD}/organizations/ordererOrganizations/iaea.org/orderers/orderer.iaea.org/msp/tlscacerts/tlsca.iaea.org-cert.pem

export PEER0_OPERATORA_CA=${PWD}/organizations/peerOrganizations/operator-a.com.au/peers/peer0.operator-a.com.au/tls/ca.crt
export PEER0_OPERATORA_PORT=7051

export PEER0_OPERATORB_CA=${PWD}/organizations/peerOrganizations/operator-b.com.au/peers/peer0.operator-b.com.au/tls/ca.crt
export PEER0_OPERATORB_PORT=8051

export PEER0_OPERATORC_CA=${PWD}/organizations/peerOrganizations/operator-c.co.nz/peers/peer0.operator-c.co.nz/tls/ca.crt
export PEER0_OPERATORC_PORT=9051

export FABRIC_CFG_PATH=${PWD}/config/

export IAEA_PORT=5050
export IAEA_HOST=orderer.iaea.org

CHANNEL_NAME="slinmac"

########################################################################################################################
# Functions definition

setGlobalsForPeer0OperatorA(){
    export CORE_PEER_LOCALMSPID="OperatorAMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_OPERATORA_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/operator-a.com.au/users/Admin@operator-a.com.au/msp
    export CORE_PEER_ADDRESS=localhost:$PEER0_OPERATORA_PORT
}

setGlobalsForPeer0OperatorB(){
    export CORE_PEER_LOCALMSPID="OperatorBMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_OPERATORB_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/operator-b.com.au/users/Admin@operator-b.com.au/msp
    export CORE_PEER_ADDRESS=localhost:$PEER0_OPERATORB_PORT
}

setGlobalsForPeer0OperatorC(){
    export CORE_PEER_LOCALMSPID="OperatorCMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_OPERATORC_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/operator-c.co.nz/users/Admin@operator-c.co.nz/msp
    export CORE_PEER_ADDRESS=localhost:$PEER0_OPERATORC_PORT
}

createChannel(){
    # rm -rf ./channel-artifacts/*
    setGlobalsForPeer0OperatorA
    
    peer channel create -o localhost:$IAEA_PORT -c $CHANNEL_NAME \
    --ordererTLSHostnameOverride $IAEA_HOST \
    -f ./channel-artifacts/${CHANNEL_NAME}.tx --outputBlock ./channel-artifacts/${CHANNEL_NAME}.block \
    --tls $CORE_PEER_TLS_ENABLED --cafile $IAEA_CA
}

joinChannel(){
    setGlobalsForPeer0OperatorA
    peer channel join -b ./channel-artifacts/$CHANNEL_NAME.block

    setGlobalsForPeer0OperatorB
    peer channel join -b ./channel-artifacts/$CHANNEL_NAME.block 

    setGlobalsForPeer0OperatorC
    peer channel join -b ./channel-artifacts/$CHANNEL_NAME.block
}

updateAnchorPeers(){
    setGlobalsForPeer0OperatorA
    peer channel update -o localhost:$IAEA_PORT --ordererTLSHostnameOverride $IAEA_HOST -c $CHANNEL_NAME \
    -f ./channel-artifacts/${CORE_PEER_LOCALMSPID}anchors.tx --tls $CORE_PEER_TLS_ENABLED --cafile $IAEA_CA
    
    setGlobalsForPeer0OperatorB
    peer channel update -o localhost:$IAEA_PORT --ordererTLSHostnameOverride $IAEA_HOST -c $CHANNEL_NAME \
    -f ./channel-artifacts/${CORE_PEER_LOCALMSPID}anchors.tx --tls $CORE_PEER_TLS_ENABLED --cafile $IAEA_CA

    setGlobalsForPeer0OperatorC
    peer channel update -o localhost:$IAEA_PORT --ordererTLSHostnameOverride $IAEA_HOST -c $CHANNEL_NAME \
    -f ./channel-artifacts/${CORE_PEER_LOCALMSPID}anchors.tx --tls $CORE_PEER_TLS_ENABLED --cafile $IAEA_CA
}

# Start here
echo "==================================== Creating the Channel ========================================================"
createChannel

echo "==================================== Joining the Channel ========================================================="
joinChannel

echo "==================================== Updating Anchor Peers ======================================================="
updateAnchorPeers
