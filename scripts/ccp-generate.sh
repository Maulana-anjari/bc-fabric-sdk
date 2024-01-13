#!/bin/bash

function one_line_pem {
    echo "`awk 'NF {sub(/\\n/, ""); printf "%s\\\\\\\n",$0;}' $1`"
}

function json_ccp {
    local PP=$(one_line_pem $5)
    local CP=$(one_line_pem $6)
    sed -e "s/\${ORG}/$1/" \
        -e "s/\${P0PORT}/$2/" \
        -e "s/\${CAPORT}/$3/" \
        -e "s#\${PEERPEM}#$PP#" \
        -e "s#\${CAPEM}#$CP#" \
        -e "s/\${ORGMSP}/$4/" \
        scripts/ccp-template.json
}

ORG=prudential
ORGMSP=Prudential
P0PORT=7051
CAPORT=7054
PEERPEM=organizations/peerOrganizations/prudential.aaui.org/tlsca/tlsca.prudential.aaui.org-cert.pem
CAPEM=organizations/peerOrganizations/prudential.aaui.org/ca/ca.prudential.aaui.org-cert.pem

echo "$(json_ccp $ORG $P0PORT $CAPORT $ORGMSP $PEERPEM $CAPEM)" > organizations/peerOrganizations/prudential.aaui.org/connection-prudential.json

ORG=manulife
ORGMSP=Manulife
P0PORT=9051
CAPORT=8054
PEERPEM=organizations/peerOrganizations/manulife.aaui.org/tlsca/tlsca.manulife.aaui.org-cert.pem
CAPEM=organizations/peerOrganizations/manulife.aaui.org/ca/ca.manulife.aaui.org-cert.pem

echo "$(json_ccp $ORG $P0PORT $CAPORT $ORGMSP $PEERPEM $CAPEM)" > organizations/peerOrganizations/manulife.aaui.org/connection-manulife.json

ORG=allianz
ORGMSP=Allianz
P0PORT=10051
CAPORT=10054
PEERPEM=organizations/peerOrganizations/allianz.aaui.org/tlsca/tlsca.allianz.aaui.org-cert.pem
CAPEM=organizations/peerOrganizations/allianz.aaui.org/ca/ca.allianz.aaui.org-cert.pem

echo "$(json_ccp $ORG $P0PORT $CAPORT $ORGMSP $PEERPEM $CAPEM)" > organizations/peerOrganizations/allianz.aaui.org/connection-allianz.json