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
CC_RUNTIME_LANGUAGE="node"
VERSION="1"
CC_SRC_PATH="./chaincode/"
CC_NAME="pharma-contract"

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

packageChaincode() {
    rm -rf ${CC_NAME}.tar.gz

    setGlobalsForPeer0Sardjito
    peer lifecycle chaincode package ${CC_NAME}.tar.gz \
        --path ${CC_SRC_PATH} --lang ${CC_RUNTIME_LANGUAGE} \
        --label ${CC_NAME}_${VERSION}
    echo "===================== Chaincode is packaged ===================== "
}

installChaincode() {
    setGlobalsForPeer0Sardjito
    peer lifecycle chaincode install ${CC_NAME}.tar.gz
    echo "===================== Chaincode is installed on peer0.sardjito ===================== "

    setGlobalsForPeer0RSCM
    peer lifecycle chaincode install ${CC_NAME}.tar.gz
    echo "===================== Chaincode is installed on peer0.rscm ===================== "

    setGlobalsForPeer0Dharmais
    peer lifecycle chaincode install ${CC_NAME}.tar.gz
    echo "===================== Chaincode is installed on peer0.dharmais ===================== "
}

queryInstalled() {
    setGlobalsForPeer0Dharmais
    peer lifecycle chaincode queryinstalled >&log.txt
    cat log.txt
    PACKAGE_ID=$(sed -n "/${CC_NAME}_${VERSION}/{s/^Package ID: //; s/, Label:.*$//; p;}" log.txt)
    echo PackageID is ${PACKAGE_ID}
    echo "===================== Query installed successful on peer0.dharmais on channel ${CHANNEL_NAME}===================== "
}

approveChaincode() {

    setGlobalsForPeer0Sardjito
    peer lifecycle chaincode approveformyorg -o localhost:$ARSADA_PORT \
        --ordererTLSHostnameOverride $ARSADA_HOST --tls \
        --cafile $ARSADA_CA --channelID $CHANNEL_NAME --name ${CC_NAME} --version ${VERSION} \
        --package-id ${PACKAGE_ID} \
        --sequence ${VERSION}
    echo "===================== chaincode approved from SARDJITO ===================== "

    setGlobalsForPeer0RSCM
    peer lifecycle chaincode approveformyorg -o localhost:$ARSADA_PORT \
        --ordererTLSHostnameOverride $ARSADA_HOST --tls \
        --cafile $ARSADA_CA --channelID $CHANNEL_NAME --name ${CC_NAME} --version ${VERSION} \
        --package-id ${PACKAGE_ID} \
        --sequence ${VERSION}
    echo "===================== chaincode approved from RSCM ===================== "

    setGlobalsForPeer0Dharmais
    peer lifecycle chaincode approveformyorg -o localhost:$ARSADA_PORT \
        --ordererTLSHostnameOverride $ARSADA_HOST --tls \
        --cafile $ARSADA_CA --channelID $CHANNEL_NAME --name ${CC_NAME} --version ${VERSION} \
        --package-id ${PACKAGE_ID} \
        --sequence ${VERSION}
    echo "===================== chaincode approved from DHARMAIS ===================== "
}

checkCommitReadyness() {
    setGlobalsForPeer0Sardjito
    peer lifecycle chaincode checkcommitreadiness \
        --channelID $CHANNEL_NAME --name ${CC_NAME} --version ${VERSION} \
        --sequence ${VERSION} --output json
    echo "===================== Checking Commit Readyness ===================== "
}

commitChaincodeDefinition() {
    setGlobalsForPeer0Sardjito
    peer lifecycle chaincode commit -o localhost:$ARSADA_PORT --ordererTLSHostnameOverride $ARSADA_HOST \
        --tls $CORE_PEER_TLS_ENABLED --cafile $ARSADA_CA \
        --channelID $CHANNEL_NAME --name ${CC_NAME} \
        --peerAddresses localhost:$PEER0_SARDJITO_PORT --tlsRootCertFiles $PEER0_SARDJITO_CA \
        --peerAddresses localhost:$PEER0_RSCM_PORT --tlsRootCertFiles $PEER0_RSCM_CA \
        --peerAddresses localhost:$PEER0_DHARMAIS_PORT --tlsRootCertFiles $PEER0_DHARMAIS_CA \
        --version ${VERSION} --sequence ${VERSION}
    echo "===================== Committing Chaincode ===================== "
}

queryCommitted() {
    setGlobalsForPeer0Dharmais
    peer lifecycle chaincode querycommitted --channelID $CHANNEL_NAME #--name ${CC_NAME}
}

# Start here
packageChaincode
installChaincode
queryInstalled
approveChaincode
# sleep 3
checkCommitReadyness
# sleep 3
commitChaincodeDefinition
queryCommitted
