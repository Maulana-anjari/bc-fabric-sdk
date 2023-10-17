#!/usr/bin/env bash

# Note: this file is to be called from ../network.sh

# Configure environment variables
export CORE_PEER_TLS_ENABLED=true
export ARSADA_CA=${PWD}/organizations/ordererOrganizations/arsada.org/orderers/orderer.arsada.org/msp/tlscacerts/tlsca.arsada.org-cert.pem

export PEER0_SARDJITO_CA=${PWD}/organizations/peerOrganizations/sardjito.co.id/peers/peer0.sardjito.co.id/tls/ca.crt
export PEER0_SARDJITO_PORT=7051

export PEER0_RSCM_CA=${PWD}/organizations/peerOrganizations/rscm.co.id/peers/peer0.rscm.co.id/tls/ca.crt
export PEER0_RSCM_PORT=8051

export PEER0_DHARMAIS_CA=${PWD}/organizations/peerOrganizations/dharmais.co.id/peers/peer0.dharmais.co.id/tls/ca.crt
export PEER0_DHARMAIS_PORT=9051

export FABRIC_CFG_PATH=${PWD}/config/

export ARSADA_PORT=5050
export ARSADA_HOST=orderer.arsada.org

CHANNEL_NAME="pharma-chain"

########################################################################################################################
# Functions definition

setGlobalsForPeer0Sardjito(){
    export CORE_PEER_LOCALMSPID="SardjitoMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_SARDJITO_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/sardjito.co.id/users/Admin@sardjito.co.id/msp
    export CORE_PEER_ADDRESS=localhost:$PEER0_SARDJITO_PORT
}

setGlobalsForPeer0RSCM(){
    export CORE_PEER_LOCALMSPID="RSCMMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_RSCM_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/rscm.co.id/users/Admin@rscm.co.id/msp
    export CORE_PEER_ADDRESS=localhost:$PEER0_RSCM_PORT
}

setGlobalsForPeer0Dharmais(){
    export CORE_PEER_LOCALMSPID="DharmaisMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_DHARMAIS_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/dharmais.co.id/users/Admin@dharmais.co.id/msp
    export CORE_PEER_ADDRESS=localhost:$PEER0_DHARMAIS_PORT
}

createChannel(){
    # rm -rf ./channel-artifacts/*
    setGlobalsForPeer0Sardjito
    
    peer channel create -o localhost:$ARSADA_PORT -c $CHANNEL_NAME \
    --ordererTLSHostnameOverride $ARSADA_HOST \
    -f ./channel-artifacts/${CHANNEL_NAME}.tx --outputBlock ./channel-artifacts/${CHANNEL_NAME}.block \
    --tls $CORE_PEER_TLS_ENABLED --cafile $ARSADA_CA
}

joinChannel(){
    setGlobalsForPeer0Sardjito
    peer channel join -b ./channel-artifacts/$CHANNEL_NAME.block

    setGlobalsForPeer0RSCM
    peer channel join -b ./channel-artifacts/$CHANNEL_NAME.block 

    setGlobalsForPeer0Dharmais
    peer channel join -b ./channel-artifacts/$CHANNEL_NAME.block
}

updateAnchorPeers(){
    setGlobalsForPeer0Sardjito
    peer channel update -o localhost:$ARSADA_PORT --ordererTLSHostnameOverride $ARSADA_HOST -c $CHANNEL_NAME \
    -f ./channel-artifacts/${CORE_PEER_LOCALMSPID}anchors.tx --tls $CORE_PEER_TLS_ENABLED --cafile $ARSADA_CA
    
    setGlobalsForPeer0RSCM
    peer channel update -o localhost:$ARSADA_PORT --ordererTLSHostnameOverride $ARSADA_HOST -c $CHANNEL_NAME \
    -f ./channel-artifacts/${CORE_PEER_LOCALMSPID}anchors.tx --tls $CORE_PEER_TLS_ENABLED --cafile $ARSADA_CA

    setGlobalsForPeer0Dharmais
    peer channel update -o localhost:$ARSADA_PORT --ordererTLSHostnameOverride $ARSADA_HOST -c $CHANNEL_NAME \
    -f ./channel-artifacts/${CORE_PEER_LOCALMSPID}anchors.tx --tls $CORE_PEER_TLS_ENABLED --cafile $ARSADA_CA
}

# Start here
echo "==================================== Creating the Channel ========================================================"
createChannel

echo "==================================== Joining the Channel ========================================================="
joinChannel

echo "==================================== Updating Anchor Peers ======================================================="
updateAnchorPeers
