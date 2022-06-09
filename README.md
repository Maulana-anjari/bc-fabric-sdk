# SLINMAC
Basic Hyperledger Fabric network setup for Secure Shared Ledger Implementation of Nuclear Materials Accounting and Control. The network consists of five fictional actors:

- IAEA (Orderer org)
- ASNO (Orderer org)
- Nuclear Operator A (Peer org)
- Nuclear Operator B (Peer org)
- Nuclear Operator C (Peer org)

To spin the network, firstly install Hyperledger Fabric [prerequisites](https://hyperledger-fabric.readthedocs.io/en/release-2.4/prereqs.html) and [CLI tool binaries](https://hyperledger-fabric.readthedocs.io/en/release-2.4/install.html). Then simply execute `./network.sh` script, which will perform:

1. Creation of crypto artifacts/credentials (`script/createArtifacts.sh`).
2. Running docker container network (`docker-compose`).
3. Creation of application channel `slinmac` (`scripts/createChannel.sh`).
4. Deployment of chaincode (`scripts/deployChaincode.sh`).
5. Testing of chaincode (`scripts/testChaincode.sh`). This step only invokes `UploadIdentity` function to check if the chaincode functions normally/

To shut down the docker network and remove the artifacts, run the following commands from project root:
```
$ rm -rf ./channel-artifacts
$ rm -rf ./organizations
$ docker-compose -f ./config/docker/docker-compose.yaml down --volumes --remove-orphans
```
