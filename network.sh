#!/usr/bin/env bash

# network.sh
# PHARMA-CHAIN
# (c) 2023

# Delete existing artifacts
if [ -d channel-artifacts ]; then
  rm -rf ./channel-artifacts
fi
if [ -d ./organizations/ ]; then
  rm -rf ./organizations
fi

# Stop the network (if any)
docker-compose -f ./config/docker/docker-compose.yaml down --volumes --remove-orphans

# Create artifacts
scripts/createArtifacts.sh

# Start the network
echo "==================================== Starting Docker network ====================================================="
docker-compose -f ./config/docker/docker-compose.yaml up -d

sleep 3

# Create channel
scripts/createChannel.sh

# Deploy chain code
scripts/deployChaincode.sh

# Test the chain code
scripts/testChaincode.sh
