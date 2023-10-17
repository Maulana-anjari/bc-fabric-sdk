# PHARMA-CHAIN

Basic Hyperledger Fabric network setup for secure and transparent data exchange between healthcare providers, insurance companies, and pharmaceutical supply chain entities. For this network configuration, it will be used as a decentralized healthcare network which includes 2 hospital association organizations (public and private), 1 regional central public hospital, 1 national central public hospital, and 1 national cancer center hospital. The healthcare network consists of five fictional actors:

- ARSADA (Orderer org)
- ARSSI (Orderer org)
- Sardjito Hospital (Peer org)
- RSCM Hospital (Peer org)
- Dharmais Hospita (Peer org)

To spin the network, firstly install Hyperledger Fabric [prerequisites](https://hyperledger-fabric.readthedocs.io/en/release-2.1/prereqs.html) and [CLI tool binaries](https://hyperledger-fabric.readthedocs.io/en/release-2.1/install.html). Then simply execute `./network.sh` script, which will perform:

1. Creation of crypto artifacts/credentials (`script/createArtifacts.sh`).
2. Running docker container network (`docker-compose`).
3. Creation of application channel `slinmac` (`scripts/createChannel.sh`).
4. Deployment of chaincode (`scripts/deployChaincode.sh`).
5. Testing of chaincode (`scripts/testChaincode.sh`). This step only invokes `UploadIdentity` function to check if the chaincode functions normally/

### NOTE
To shut down the docker network and remove the artifacts, run the following commands from project root:
```
$ rm -rf ./channel-artifacts
$ rm -rf ./organizations
$ docker-compose -f ./config/docker/docker-compose.yaml down --volumes --remove-orphans
```
