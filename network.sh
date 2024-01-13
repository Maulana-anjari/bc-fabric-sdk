#!/usr/bin/env bash

# network.sh
# PHARMA-CHAIN
# (c) 2023

# Delete existing artifacts & Stop the network (if any)
./shutdown-network.sh

# Create artifacts
scripts/createArtifacts.sh

# Start the network
echo "==================================== Starting Docker network ===================================="
docker compose -f ./config/docker/docker-compose.yaml up -d

sleep 3

# Create channel
scripts/createChannel.sh

# Deploy chain code
scripts/deployChaincode.sh

# Test the chain code
scripts/testChaincode.sh

# Generating CCP files for Prudential, Manulife, and Allianz
scripts/ccp-generate.sh