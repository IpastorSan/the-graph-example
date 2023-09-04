# Basic NFT Marketplace example

## This project

This project is intended to be used as a basic example for a NFT marketplace using Foundry, with the purpose of showing how you can use the events emited by a smart contract to build a [Subgraph](https://thegraph.com/)

This should NOT be used for any production NFT marketplace, as it only has the basic functionality to be able to generate an NFT listing by a seller and allow a buyer to buy it.

The project is made of the smart contract, a deployment script that will also simulate activity in the marketplace (listing, updating, canceling and buying) and some basic tests. The events emited by each of these actions will be picked up by our custom Subgraph so we will be able to query and get the state of the marketplace as a whole (each individual listing and its current state). This is useful to create UIs that would allow user interaction, using the smart contracts and the Graph, anyone could build on top and make their own version of the marketplace (again, not recommending it for this specific implementation).

The contracts and Subgraph will be deployed in the Sepolia network
- marketplace address:
- mock nft address: 
- subgraph link: []() 

## Instructions.
Assuming you already have Rust and Foundry installed

1. 
```bash
cd foundry-project
forge install
```
2. Compile the project
```bash
forge build
``` 
3. Run test suite
```bash
forge test
```

### Generate docs based on Natspec on files

```bash
forge doc
```

### Check test coverage 
```bash
forge coverage
```

See the [Book of Foundry](https://book.getfoundry.sh/projects/working-on-an-existing-project.html) to learn more

**Run Locally**

Open Anvil local node
```bash
anvil
```
Load .env variables 
in .env file->NO spaces between variable name and value, value with quotes. PRIVATE_KEY="blablabla"
```bash
source .env
```
Run on local node
```bash
forge script script/DeployLocal.s.sol:Deploy --fork-url http://localhost:8545  --private-key $PRIVATE_KEY --broadcast 
```

**Deploy to Sepolia**

Load .env variables 
in .env file->NO spaces between variable name and value, value with quotes. PRIVATE_KEY="blablabla"
```bash
source .env
```
Deploy to Sepolia and verify
```bash
forge script script/Deploy.s.sol:Deploy --rpc-url $RPC_KEY  --private-key $PRIVATE_KEY --broadcast --verify --etherscan-api-key $ETHERSCAN_KEY -vvvv
```
