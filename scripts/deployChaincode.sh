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
CC_RUNTIME_LANGUAGE="node"
VERSION="1"
CC_SRC_PATH="./chaincode/"
CC_NAME="contract"

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

packageChaincode() {
    rm -rf ${CC_NAME}.tar.gz

    setGlobalsForPeer0OperatorA
    peer lifecycle chaincode package ${CC_NAME}.tar.gz \
        --path ${CC_SRC_PATH} --lang ${CC_RUNTIME_LANGUAGE} \
        --label ${CC_NAME}_${VERSION}
    echo "===================== Chaincode is packaged ===================== "
}

installChaincode() {
    setGlobalsForPeer0OperatorA
    peer lifecycle chaincode install ${CC_NAME}.tar.gz
    echo "===================== Chaincode is installed on peer0.OperatorA ===================== "

    setGlobalsForPeer0OperatorB
    peer lifecycle chaincode install ${CC_NAME}.tar.gz
    echo "===================== Chaincode is installed on peer0.OperatorB ===================== "

    setGlobalsForPeer0OperatorC
    peer lifecycle chaincode install ${CC_NAME}.tar.gz
    echo "===================== Chaincode is installed on peer0.OperatorC ===================== "
}

queryInstalled() {
    setGlobalsForPeer0OperatorC
    peer lifecycle chaincode queryinstalled >&log.txt
    cat log.txt
    PACKAGE_ID=$(sed -n "/${CC_NAME}_${VERSION}/{s/^Package ID: //; s/, Label:.*$//; p;}" log.txt)
    echo PackageID is ${PACKAGE_ID}
    echo "===================== Query installed successful on peer0.OperatorC on channel ${CHANNEL_NAME}===================== "
}

approveChaincode() {

    setGlobalsForPeer0OperatorA
    peer lifecycle chaincode approveformyorg -o localhost:$IAEA_PORT \
        --ordererTLSHostnameOverride $IAEA_HOST --tls \
        --cafile $IAEA_CA --channelID $CHANNEL_NAME --name ${CC_NAME} --version ${VERSION} \
        --package-id ${PACKAGE_ID} \
        --sequence ${VERSION}
    echo "===================== chaincode approved from OperatorA ===================== "

    setGlobalsForPeer0OperatorB
    peer lifecycle chaincode approveformyorg -o localhost:$IAEA_PORT \
        --ordererTLSHostnameOverride $IAEA_HOST --tls \
        --cafile $IAEA_CA --channelID $CHANNEL_NAME --name ${CC_NAME} --version ${VERSION} \
        --package-id ${PACKAGE_ID} \
        --sequence ${VERSION}
    echo "===================== chaincode approved from OperatorB ===================== "

    setGlobalsForPeer0OperatorC
    peer lifecycle chaincode approveformyorg -o localhost:$IAEA_PORT \
        --ordererTLSHostnameOverride $IAEA_HOST --tls \
        --cafile $IAEA_CA --channelID $CHANNEL_NAME --name ${CC_NAME} --version ${VERSION} \
        --package-id ${PACKAGE_ID} \
        --sequence ${VERSION}
    echo "===================== chaincode approved from OperatorC ===================== "
}

checkCommitReadyness() {
    setGlobalsForPeer0OperatorA
    peer lifecycle chaincode checkcommitreadiness \
        --channelID $CHANNEL_NAME --name ${CC_NAME} --version ${VERSION} \
        --sequence ${VERSION} --output json
    echo "===================== Checking Commit Readyness ===================== "
}

commitChaincodeDefinition() {
    setGlobalsForPeer0OperatorA
    peer lifecycle chaincode commit -o localhost:$IAEA_PORT --ordererTLSHostnameOverride $IAEA_HOST \
        --tls $CORE_PEER_TLS_ENABLED --cafile $IAEA_CA \
        --channelID $CHANNEL_NAME --name ${CC_NAME} \
        --peerAddresses localhost:$PEER0_OPERATORA_PORT --tlsRootCertFiles $PEER0_OPERATORA_CA \
        --peerAddresses localhost:$PEER0_OPERATORB_PORT --tlsRootCertFiles $PEER0_OPERATORB_CA \
        --peerAddresses localhost:$PEER0_OPERATORC_PORT --tlsRootCertFiles $PEER0_OPERATORC_CA \
        --version ${VERSION} --sequence ${VERSION}
    echo "===================== Committing Chaincode ===================== "
}

queryCommitted() {
    setGlobalsForPeer0OperatorC
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
