#!/usr/bin/env bash

# Note: this file is to be called from ../network.sh

# Configure environment variables
export CORE_PEER_TLS_ENABLED=true
export IAEA_CA=${PWD}/organizations/ordererOrganizations/iaea.org/orderers/orderer.iaea.org/msp/tlscacerts/tlsca.iaea.org-cert.pem

export PEER0_OPERATORA_CA=${PWD}/organizations/peerOrganizations/operator-a.com.au/peers/peer0.operator-a.com.au/tls/ca.crt
export PEER0_OPERATORA_PORT=7051

export PEER0_OPERATORB_CA=${PWD}/organizations/peerOrganizations/operator-b.com.au/peers/peer0.operator-b.com.au/tls/ca.crt
export PEER0_OPERATORB_PORT=8051

export FABRIC_CFG_PATH=${PWD}/config/
export IAEA_PORT=5050
export IAEA_HOST=orderer.iaea.org

CHANNEL_NAME="slinmac"
CC_NAME="contract"

setGlobalsForPeer0OperatorA(){
    export CORE_PEER_LOCALMSPID="OperatorAMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_OPERATORA_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/operator-a.com.au/users/Admin@operator-a.com.au/msp
    export CORE_PEER_ADDRESS=localhost:$PEER0_OPERATORA_PORT
}

setGlobalsForPeer0OperatorA

echo "Invoking the chaincode: function: 'UploadIdentity'..."
peer chaincode invoke -o localhost:$IAEA_PORT \
--ordererTLSHostnameOverride $IAEA_HOST \
--tls --cafile $IAEA_CA \
-C $CHANNEL_NAME -n $CC_NAME \
--peerAddresses localhost:$PEER0_OPERATORA_PORT \
--tlsRootCertFiles $PEER0_OPERATORA_CA \
--peerAddresses localhost:$PEER0_OPERATORB_PORT \
--tlsRootCertFiles $PEER0_OPERATORB_CA \
-c '{"function":"UploadIdentity","Args":["abcdef123"]}'
echo "============================================================================="
