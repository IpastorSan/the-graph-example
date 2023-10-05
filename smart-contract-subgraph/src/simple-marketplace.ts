import {
  ItemSold as ItemSoldEvent,
  ListingCancelled as ListingCancelledEvent,
  ListingCreated as ListingCreatedEvent,
  ListingUpdated as ListingUpdatedEvent,
} from "../generated/SimpleMarketplace/SimpleMarketplace"
import {
  ItemSold,
  Listing
} from "../generated/schema"
import { store } from '@graphprotocol/graph-ts'

export function handleItemSold(event: ItemSoldEvent): void {
  let entity = new ItemSold(event.params.listingId.toString())

  entity.listingId = event.params.listingId
  entity.nft = event.params.nft
  entity.seller = event.params.seller
  entity.buyer = event.params.buyer
  entity.price = event.params.price

  entity.blockNumber = event.block.number
  entity.blockTimestamp = event.block.timestamp
  entity.transactionHash = event.transaction.hash

  entity.save()

  store.remove("Listing", event.params.listingId.toString())
}

export function handleListingCancelled(event: ListingCancelledEvent): void {
  let entity: Listing | null
  entity = Listing.load(event.params.listingId.toString())

  if (entity!== null){
    store.remove("Listing", event.params.listingId.toString())
  }

}

export function handleListingCreated(event: ListingCreatedEvent): void {
  let entity: Listing | null
  entity = new Listing(event.params.listingId.toString())
  
  entity.listingId = event.params.listingId
  entity.seller = event.params.seller
  entity.nft = event.params.nft
  entity.tokenId = event.params.tokenId
  entity.price = event.params.price
  entity.exist = event.params.exist

  entity.blockNumber = event.block.number
  entity.blockTimestamp = event.block.timestamp
  entity.transactionHash = event.transaction.hash

  entity.save()
}

export function handleListingUpdated(event: ListingUpdatedEvent): void {
  let entity: Listing | null
  entity = Listing.load(event.params.listingId.toString())

  if(entity !== null){
    entity.listingId = event.params.listingId
    entity.seller = event.params.seller
    entity.nft = event.params.nft
    entity.tokenId = event.params.tokenId
    entity.price = event.params.price
  
    entity.blockNumber = event.block.number
    entity.blockTimestamp = event.block.timestamp
    entity.transactionHash = event.transaction.hash
  
    entity.save()
  }

}

