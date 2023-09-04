// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/RandomERC721.sol";
import "./utils/Utils.sol";

contract NftTest is Test {
    using stdStorage for StdStorage;
    Utils internal utils;

    address payable[] internal users;

    address internal owner;
    address internal alice;
    address internal bob;

    RandomERC721 private nft;

    event ItemSold(uint256 listingId, address nft, address seller, address buyer, uint256 price);
    event ListingCreated(uint256 listingId, address seller, address nft, uint256 tokenId, uint256 price, bool exist);
    event ListingUpdated(uint256 listingId, address seller,  address nft, uint256 tokenId, uint256 price);
    event ListingCancelled(uint256 listingId);

    function setUp() public {
        nft = new BasicERC721(base_uri);
        utils = new Utils();
        users = utils.createUsers(3);
        deployer = users[0];
        vm.label(deployer, "deployer");
        alice = users[1];
        vm.label(alice, "alice");
        bob = users[2];
        vm.label(bob, "bob");
    }

}