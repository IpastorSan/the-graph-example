# Example Subgraph for a simple marketplace smart contract

This is the partner repository for the article on how to create your own subgraph [Article]()

## Foundry project 

It contains a simple marketplace smart contract with a mockERC721 and a Deployment script that will perform a series of contract interactions that would populate the entities in the Subgraph upon the emission of the events being triggered. The contracts are developed using the Foundry framework.

The smart contracts are deployed on Sepolia and their addresses are:
- `SimpleMarketplace.sol` : 
- `RandomERC721.sol` :

**See individual README.md on the directory to get more details on how to run it.** 

## Smart Contract Subgraph

This directory contains the custom Subgraph that would allow a developer to track the events and, most importantly, the internal status of the contract. For this Subgraph, we focus specially on NFT listings.

This is useful to save a lot of view functions that we would need to inspect the current value of the Listing structs, either for internal analysis or for Front-End development.

The test Subgraph is deplpyed here: Link here

**See individual README.md on the directory for more details**