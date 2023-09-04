// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165Checker.sol";
import "./interfaces/ISimpleMarketplace.sol";

contract ObjectMarketplace is ISimpleMarketplace, Ownable {
    
    using ERC165Checker for address;
    //Keeps track of total listings ever generated
    uint256 private _listingIdIndex;

    uint256 private _marketplaceFeePoints; 

    //Allows us to retrieve the info of a ListingID
    mapping(uint256 => Listing) private listingById;

    modifier onlySeller(uint256 listingId) {
        Listing storage _listing = listingById[listingId];
        if (msg.sender == _listing.seller) {
            _;
        } else {
            revert NotAllowedUser();
        }
    }

    modifier noZeroAddress(address newAddress) {
        if (newAddress == address(0)) {
            revert ZeroAddress();
        } else {
            _;
        }
    }

    constructor(uint256 fee) Ownable(msg.sender) {
        _listingIdIndex = 1; // We hate initializing from 0, very gas inefficient
        _marketplaceFeePoints = fee;
    }

    /// @notice creates new listing
    /**
     * @dev anyone can call this function
     * @param nft address of nft collection to be listed
     * @param tokenId within the collection. If @param nft is ERC1155, only 1 unit is allowed to be listed
     * @param price in wei of the token listed.
     */
    function createListing(
        address nft,
        uint256 tokenId,
        uint256 price
    ) external {
        uint256 currentIndex = _listingIdIndex;
        _listingIdIndex += 1;

        //Check if th eotken is ERC721
        if(!nft.supportsInterface(0x80ac58cd)) revert OnlyERC721Allowed();

        IERC721 instanceNFT = IERC721(nft);
        //Check if the seller is the owner of the token
        if (!(instanceNFT.ownerOf(tokenId) == msg.sender)) revert NotOwner();

        //Check if the token owner has approved the marketplace to move the tokens
        if (!instanceNFT.isApprovedForAll(msg.sender, address(this))) revert NotApproved();
        
        if (price == 0) revert PriceCantBeZero();

        //Create new listing
        listingById[currentIndex] = Listing(currentIndex, msg.sender,  nft, tokenId, price, true);

        emit ListingCreated(currentIndex, msg.sender,nft, tokenId, price, true);
    }

    /// @notice Allows seller to update @param price from listing
    /**
     * @dev only Seller can call this function
     * @param listingId to identify listing
     * @param price new price of listing
     */
    function updateListing(
        uint256 listingId,
        uint256 price
    ) external onlySeller(listingId) {
        Listing storage _listing = listingById[listingId];

        if (!_listing.exist) revert NonExistingListing();
        listingById[listingId].price = price;

        emit ListingUpdated(listingId, msg.sender, _listing.nft, _listing.tokenId, price);
    }

    /// @notice allows to cancel listing by Seller
    /**
     * @dev only original seller can call this function
     * @param listingId Id of the listing to be eliminated.
     */
    function cancelListing(uint256 listingId) external onlySeller(listingId) {
        _cancelListing(listingId);
    }

    /// @notice buys nft from existing listing.
    /**
     * @dev Separates fee payment, and amount to be paid for seller.
     * @dev Admits payments in native token 
     * @param listingId Id of the listing to be purchased.
     */
    function buyToken(uint256 listingId) external payable {
        Listing memory _listing = listingById[listingId];

        //Cancel listing
        _cancelListing(listingId);

        if (!_listing.exist) revert NonExistingListing();
        if (_listing.seller == msg.sender) revert SellerAndBuyerCantBeTheSame();

        //Calculate fees and prices
        uint256 marketplaceFee = (_listing.price * _marketplaceFeePoints) / 10000;
        uint256 priceToSeller = _listing.price - marketplaceFee;

        //We transfer the tokens to Seller, either ERC20 or native token
        if (msg.value != _listing.price) revert NotEnoughEther();

        (bool successFee, ) = payable(address(this)).call{value: marketplaceFee}("");
        (bool successPayment, ) = payable(_listing.seller).call{value: priceToSeller}("");

        if (!successFee || !successPayment) revert MarketplaceError();
            
        //Transfer the NFT to buyer
        IERC721(_listing.nft).safeTransferFrom(_listing.seller, msg.sender, _listing.tokenId);

        emit ItemSold(listingId, _listing.nft, _listing.seller, msg.sender, _listing.price);
    }

    function withdraw() external onlyOwner {
        (bool success, ) = payable(owner()).call{value: address(this).balance}("");
        if (!success) revert();
    }

    ///@dev used in different cancel listing situations
    /**
     * @param listingId Id of the listing to be eliminated.
     */
    function _cancelListing(uint256 listingId) internal {
        delete (listingById[listingId]);
        emit ListingCancelled(listingId);
    }
}
