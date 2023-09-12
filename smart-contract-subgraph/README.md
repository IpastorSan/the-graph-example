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
const graphEndpoint = "https://api.studio.thegraph.com/query/52096/verso-test/version/latest" 
const graphQLQuery = { query: `{ userProfiles(first: 5, skip:0) 
                                {id
                                profileId
                                address
                                collections}}` }         
const fetched = await axios.post(graphEndpoint, graphQLQuery)
```