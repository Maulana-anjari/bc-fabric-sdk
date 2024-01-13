#!/usr/bin/env bash

# Note: this file is to be called from ../network.sh

# Configure environment variables
export CORE_PEER_TLS_ENABLED=true
export AAUI_CA=${PWD}/organizations/ordererOrganizations/aaui.org/orderers/orderer.aaui.org/msp/tlscacerts/tlsca.aaui.org-cert.pem

export PEER0_PRUDENTIAL_CA=${PWD}/organizations/peerOrganizations/prudential.aaui.org/peers/peer0.prudential.aaui.org/tls/ca.crt
export PEER0_PRUDENTIAL_PORT=7051

export PEER0_MANULIFE_CA=${PWD}/organizations/peerOrganizations/manulife.aaui.org/peers/peer0.manulife.aaui.org/tls/ca.crt
export PEER0_MANULIFE_PORT=8051

export PEER0_ALLIANZ_CA=${PWD}/organizations/peerOrganizations/allianz.aaui.org/peers/peer0.allianz.aaui.org/tls/ca.crt
export PEER0_ALLIANZ_PORT=9051

export FABRIC_CFG_PATH=${PWD}/config/

export AAUI_PORT=5050
export AAUI_HOST=orderer.aaui.org

CHANNEL_NAME="network-health-insurance"
CC_RUNTIME_LANGUAGE="node"
VERSION="1"
CC_SRC_PATH="./chaincode/"
CC_NAME="insurance-contract"

########################################################################################################################
# Functions definition

setGlobalsForPeer0Prudential(){
    export CORE_PEER_LOCALMSPID="PrudentialMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_PRUDENTIAL_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/prudential.aaui.org/users/Admin@prudential.aaui.org/msp
    export CORE_PEER_ADDRESS=localhost:$PEER0_PRUDENTIAL_PORT
}

setGlobalsForPeer0Manulife(){
    export CORE_PEER_LOCALMSPID="ManulifeMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_MANULIFE_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/manulife.aaui.org/users/Admin@manulife.aaui.org/msp
    export CORE_PEER_ADDRESS=localhost:$PEER0_MANULIFE_PORT
}

setGlobalsForPeer0Allianz(){
    export CORE_PEER_LOCALMSPID="AllianzMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_ALLIANZ_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/allianz.aaui.org/users/Admin@allianz.aaui.org/msp
    export CORE_PEER_ADDRESS=localhost:$PEER0_ALLIANZ_PORT
}

packageChaincode() {
    rm -rf ${CC_NAME}.tar.gz

    setGlobalsForPeer0Prudential
    peer lifecycle chaincode package ${CC_NAME}.tar.gz \
        --path ${CC_SRC_PATH} --lang ${CC_RUNTIME_LANGUAGE} \
        --label ${CC_NAME}_${VERSION}
    echo "===================== Chaincode is packaged ===================== "
}

installChaincode() {
    setGlobalsForPeer0Prudential
    peer lifecycle chaincode install ${CC_NAME}.tar.gz
    echo "===================== Chaincode is installed on peer0.prudential ===================== "

    setGlobalsForPeer0Manulife
    peer lifecycle chaincode install ${CC_NAME}.tar.gz
    echo "===================== Chaincode is installed on peer0.manulife ===================== "

    setGlobalsForPeer0Allianz
    peer lifecycle chaincode install ${CC_NAME}.tar.gz
    echo "===================== Chaincode is installed on peer0.allianz ===================== "
}

queryInstalled() {
    setGlobalsForPeer0Allianz
    peer lifecycle chaincode queryinstalled >&log.txt
    cat log.txt
    PACKAGE_ID=$(sed -n "/${CC_NAME}_${VERSION}/{s/^Package ID: //; s/, Label:.*$//; p;}" log.txt)
    echo PackageID is ${PACKAGE_ID}
    echo "===================== Query installed successful on peer0.allianz on channel ${CHANNEL_NAME}===================== "
}

approveChaincode() {

    setGlobalsForPeer0Prudential
    peer lifecycle chaincode approveformyorg -o localhost:$AAUI_PORT \
        --ordererTLSHostnameOverride $AAUI_HOST --tls \
        --cafile $AAUI_CA --channelID $CHANNEL_NAME --name ${CC_NAME} --version ${VERSION} \
        --package-id ${PACKAGE_ID} \
        --sequence ${VERSION}
    echo "===================== chaincode approved from PRUDENTIAL ===================== "

    setGlobalsForPeer0Manulife
    peer lifecycle chaincode approveformyorg -o localhost:$AAUI_PORT \
        --ordererTLSHostnameOverride $AAUI_HOST --tls \
        --cafile $AAUI_CA --channelID $CHANNEL_NAME --name ${CC_NAME} --version ${VERSION} \
        --package-id ${PACKAGE_ID} \
        --sequence ${VERSION}
    echo "===================== chaincode approved from MANULIFE ===================== "

    setGlobalsForPeer0Allianz
    peer lifecycle chaincode approveformyorg -o localhost:$AAUI_PORT \
        --ordererTLSHostnameOverride $AAUI_HOST --tls \
        --cafile $AAUI_CA --channelID $CHANNEL_NAME --name ${CC_NAME} --version ${VERSION} \
        --package-id ${PACKAGE_ID} \
        --sequence ${VERSION}
    echo "===================== chaincode approved from ALLIANZ ===================== "
}

checkCommitReadyness() {
    setGlobalsForPeer0Prudential
    peer lifecycle chaincode checkcommitreadiness \
        --channelID $CHANNEL_NAME --name ${CC_NAME} --version ${VERSION} \
        --sequence ${VERSION} --output json
    echo "===================== Checking Commit Readyness ===================== "
}

commitChaincodeDefinition() {
    setGlobalsForPeer0Prudential
    peer lifecycle chaincode commit -o localhost:$AAUI_PORT --ordererTLSHostnameOverride $AAUI_HOST \
        --tls $CORE_PEER_TLS_ENABLED --cafile $AAUI_CA \
        --channelID $CHANNEL_NAME --name ${CC_NAME} \
        --peerAddresses localhost:$PEER0_PRUDENTIAL_PORT --tlsRootCertFiles $PEER0_PRUDENTIAL_CA \
        --peerAddresses localhost:$PEER0_MANULIFE_PORT --tlsRootCertFiles $PEER0_MANULIFE_CA \
        --peerAddresses localhost:$PEER0_ALLIANZ_PORT --tlsRootCertFiles $PEER0_ALLIANZ_CA \
        --version ${VERSION} --sequence ${VERSION}
    echo "===================== Committing Chaincode ===================== "
}

queryCommitted() {
    setGlobalsForPeer0Allianz
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
