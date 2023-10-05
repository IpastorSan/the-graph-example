# Example Subgraph for a simple marketplace smart contract

This is the partner repository for the article on how to create your own subgraph [Article]()

## Foundry project 

It contains a simple marketplace smart contract with a mockERC721 and a Deployment script that will perform a series of contract interactions that would populate the entities in the Subgraph upon the emission of the events being triggered. The contracts are developed using the Foundry framework.

The smart contracts are deployed on Sepolia and their addresses are:
- `SimpleMarketplace.sol` : 0xd4DEca77F965C3c42FB278C2Cb0C51dF8551C049
- `RandomERC721.sol` : 0x3bAD430f16F8de999E1452d53d3B6328cA82A009



## Smart Contract Subgraph

This directory contains the custom Subgraph that would allow a developer to track the events and, most importantly, the internal status of the contract. For this Subgraph, we focus specially on NFT listings.

This is useful to save a lot of view functions that we would need to inspect the current value of the Listing structs, either for internal analysis or for Front-End development.

The test Subgraph is deplopyed here: Link here

# Example Subgraph for Simple Marketplace

type UserProfile @entity {
  id: String! # Add this line
  profileId: ID!
  address: Bytes! # address
  collections: [String!]
  collectedVerso: [Token!]
  createdVerso: [Token!]
  blockNumber: BigInt!
  blockTimestamp: BigInt!
  transactionHash: Bytes!
}

type Token @entity {
  id: String! # Add this line
  tokenId: ID!
  uri: String!
  creator : ID!
  collectors: [String!]
  blockNumber: BigInt!
  blockTimestamp: BigInt!
  transactionHash: Bytes!
}

## Basic commands to manage the Graph

```bash
graph codegen && graph build
```

```bash
graph auth --studio <DEPLOY_KEY>
```

```bash
graph deploy --studio <SUBGRAPH_NAME>
```

## Axios example
```javascript
const graphEndpoint = "https://api.studio.thegraph.com/query/52096/marketplace-example/version/latest" 
const graphQLQuery = { query: `{ Listing(first: 5, skip:0) 
                                {id
                                listingId
                                nft
                                tokenId
                                price}}` }         
const fetched = await axios.post(graphEndpoint, graphQLQuery)
```

## Basic NFT Marketplace example


This project is intended to be used as a basic example for a NFT marketplace using Foundry, with the purpose of showing how you can use the events emited by a smart contract to build a [Subgraph](https://thegraph.com/)

This should NOT be used for any production NFT marketplace, as it only has the basic functionality to be able to generate an NFT listing by a seller and allow a buyer to buy it.

The project is made of the smart contract, a deployment script that will also simulate activity in the marketplace (listing, updating, canceling and buying) and some basic tests. The events emited by each of these actions will be picked up by our custom Subgraph so we will be able to query and get the state of the marketplace as a whole (each individual listing and its current state). This is useful to create UIs that would allow user interaction, using the smart contracts and the Graph, anyone could build on top and make their own version of the marketplace (again, not recommending it for this specific implementation).

The contracts and Subgraph will be deployed in the Sepolia network
- marketplace address: 0xd4DEca77F965C3c42FB278C2Cb0C51dF8551C049
- mock nft address: 0x3bAD430f16F8de999E1452d53d3B6328cA82A009
- subgraph link: [https://api.studio.thegraph.com/query/52096/marketplace-example/version/latest](https://api.studio.thegraph.com/query/52096/marketplace-example/version/latest) 

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
forge script script/DeployLocal.s.sol:Deploy --fork-url http://localhost:8545  --private-key $PRIVATE_KEY_DEPLOYER --broadcast 
```

**Deploy to Sepolia**

Load .env variables 
in .env file->NO spaces between variable name and value, value with quotes. PRIVATE_KEY="blablabla"
```bash
source .env
```
Deploy to Sepolia and verify
```bash
forge script script/DeployTestnet.s.sol:Deploy --rpc-url $RPC_URL  --private-key $PRIVATE_KEY --broadcast --verify --etherscan-api-key $ETHERSCAN_API_KEY -vvvv
```
