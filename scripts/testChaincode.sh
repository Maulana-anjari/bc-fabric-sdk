#!/usr/bin/env bash

# Note: this file is to be called from ../network.sh

# Configure environment variables
export CORE_PEER_TLS_ENABLED=true
export AAUI_CA=${PWD}/organizations/ordererOrganizations/aaui.org/orderers/orderer.aaui.org/msp/tlscacerts/tlsca.aaui.org-cert.pem

export PEER0_PRUDENTIAL_CA=${PWD}/organizations/peerOrganizations/prudential.co.id/peers/peer0.prudential.co.id/tls/ca.crt
export PEER0_PRUDENTIAL_PORT=7051

export PEER0_MANULIFE_CA=${PWD}/organizations/peerOrganizations/manulife.co.id/peers/peer0.manulife.co.id/tls/ca.crt
export PEER0_MANULIFE_PORT=8051

export FABRIC_CFG_PATH=${PWD}/config/
export AAUI_PORT=5050
export AAUI_HOST=orderer.aaui.org

CHANNEL_NAME="network_health_insurance"
CC_NAME="pchic-contract"

setGlobalsForPeer0Prudential(){
    export CORE_PEER_LOCALMSPID="PrudentialMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_PRUDENTIAL_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/prudential.co.id/users/Admin@prudential.co.id/msp
    export CORE_PEER_ADDRESS=localhost:$PEER0_PRUDENTIAL_PORT
}

setGlobalsForPeer0Prudential

echo "Invoking the chaincode: function: 'UploadIdentity'..."
peer chaincode invoke -o localhost:$AAUI_PORT \
--ordererTLSHostnameOverride $AAUI_HOST \
--tls --cafile $AAUI_CA \
-C $CHANNEL_NAME -n $CC_NAME \
--peerAddresses localhost:$PEER0_PRUDENTIAL_PORT \
--tlsRootCertFiles $PEER0_PRUDENTIAL_CA \
--peerAddresses localhost:$PEER0_MANULIFE_PORT \
--tlsRootCertFiles $PEER0_MANULIFE_CA \
-c '{"function":"UploadIdentity","Args":["abcdef123"]}'
echo "============================================================================="
