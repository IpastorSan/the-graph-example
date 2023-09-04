// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;


interface ISimpleMarketplace {
    
    error AlreadyExistingListing();
    error InvalidListing();
    error ItemAlreadySold();
    error ListingIsValid();
    error MarketplaceError();
    error NotEnoughEther();
    error NonExistingListing();
    error NotAllowedUser();
    error NotApproved();
    error NotOwner();
    error OnlyERC721Allowed();
    error PriceCantBeZero();
    error SellerAndBuyerCantBeTheSame();
    error ZeroAddress();

    struct Listing {
        // Ever increasing listing Id of tokens
        uint256 listingId;
        // Address of seller
        address seller;
        // Address of NFT contract
        address nft;
        // Address of token to be listed
        uint256 tokenId;
        //Desired price by seller
        uint256 price;
        //Check if listing exists
        bool exist;
    }

    // Emitted when a valid listed item is sold at the requested price
    event ItemSold(uint256 listingId, address nft, address seller, address buyer, uint256 price);
    // Emitted when a valid listing is created
    event ListingCreated(uint256 listingId, address seller, address nft, uint256 tokenId, uint256 price, bool exist);
    // Emitted when a valid listing is updated by the Seller
    event ListingUpdated(uint256 listingId, address seller,  address nft, uint256 tokenId, uint256 price);
    // Emitted when a listing is cancelled 
    event ListingCancelled(uint256 listingId);
    
    /// @notice buys nft from existing listing. 
    /**
     * @param listingId Id of the listing to be purchased.
    */
    function buyToken(uint256 listingId) external payable; 

    /// @notice allows to cancel listing by user
    /**
     * @dev only original seller can call this function
     * @param listingId Id of the listing to be eliminated.
     */
    function cancelListing(uint256 listingId) external;

    /// @notice creates new listing
    /**
     * @dev anyone can call this function
     * @param nft address of nft collection to be listed
     * @param tokenId within the collection. If @param nft is ERC1155, only 1 unit is allowed to be listed
     * @param price in wei of the token listed.
    */
    function createListing(address nft, uint256 tokenId, uint256 price) external;

    /// @notice Allows seller to update @param price from listing
    /** 
     * @dev only Seller can call this function
     * @param listingId to identify listing
     * @param price new price of listing
    */
    function updateListing(uint256 listingId, uint256 price) external;
}