#!/usr/bin/env bash

# Note: this file is to be called from ../network.sh

# Configure environment variables
export CORE_PEER_TLS_ENABLED=true
export ARSADA_CA=${PWD}/organizations/ordererOrganizations/arsada.org/orderers/orderer.arsada.org/msp/tlscacerts/tlsca.arsada.org-cert.pem

export PEER0_SARDJITO_CA=${PWD}/organizations/peerOrganizations/sardjito.co.id/peers/peer0.sardjito.co.id/tls/ca.crt
export PEER0_SARDJITO_PORT=7051

export PEER0_RSCM_CA=${PWD}/organizations/peerOrganizations/rscm.co.id/peers/peer0.rscm.co.id/tls/ca.crt
export PEER0_RSCM_PORT=8051

export FABRIC_CFG_PATH=${PWD}/config/
export ARSADA_PORT=5050
export ARSADA_HOST=orderer.arsada.org

CHANNEL_NAME="pharma-chain"
CC_NAME="pharma-contract"

setGlobalsForPeer0Sardjito(){
    export CORE_PEER_LOCALMSPID="SardjitoMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_SARDJITO_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/sardjito.co.id/users/Admin@sardjito.co.id/msp
    export CORE_PEER_ADDRESS=localhost:$PEER0_SARDJITO_PORT
}

setGlobalsForPeer0Sardjito

echo "Invoking the chaincode: function: 'UploadIdentity'..."
peer chaincode invoke -o localhost:$ARSADA_PORT \
--ordererTLSHostnameOverride $ARSADA_HOST \
--tls --cafile $ARSADA_CA \
-C $CHANNEL_NAME -n $CC_NAME \
--peerAddresses localhost:$PEER0_SARDJITO_PORT \
--tlsRootCertFiles $PEER0_SARDJITO_CA \
--peerAddresses localhost:$PEER0_RSCM_PORT \
--tlsRootCertFiles $PEER0_RSCM_CA \
-c '{"function":"UploadIdentity","Args":["abcdef123"]}'
echo "============================================================================="
