// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/RandomERC721.sol";
import "../src/SimpleMarketplace.sol";
import "./utils/Utils.sol";

contract MarketplaceTest is Test {
    using stdStorage for StdStorage;
    Utils internal utils;

    address payable[] internal users;

    address internal deployer;
    address internal alice;
    address internal bob;

    RandomERC721 private nft;
    SimpleMarketplace marketplace;

    event ItemSold(uint256 listingId, address nft, address seller, address buyer, uint256 price);
    event ListingCreated(uint256 listingId, address seller, address nft, uint256 tokenId, uint256 price, bool exist);
    event ListingUpdated(uint256 listingId, address seller,  address nft, uint256 tokenId, uint256 price);
    event ListingCancelled(uint256 listingId);

    function setUp() public {
        utils = new Utils();
        users = utils.setupUsers(3);
        deployer = users[0];
        vm.label(deployer, "deployer");
        alice = users[1];
        vm.label(alice, "alice");
        bob = users[2];
        vm.label(bob, "bob");

        vm.prank(deployer);
        nft = new RandomERC721();

        vm.prank(deployer);
        marketplace = new SimpleMarketplace(100);

        //Move around some NFTs
        vm.startPrank(deployer);
        nft.transferFrom(deployer, alice, 3);
        nft.transferFrom(deployer, bob, 4);
        nft.transferFrom(deployer, alice, 5);
        nft.transferFrom(deployer, bob, 6);

        //Approve the marketplace to spend the NFTs
        nft.setApprovalForAll(address(marketplace), true);
        vm.stopPrank();
        vm.prank(alice);
        nft.setApprovalForAll(address(marketplace), true);
        vm.prank(bob);
        nft.setApprovalForAll(address(marketplace), true);
    }

    function testListToken() public {
        vm.prank(deployer);

        vm.expectEmit(true, true, true, true);
        emit ListingCreated(1, deployer, address(nft), 0, 1 ether, true);
        marketplace.createListing(address(nft), 0, 1 ether); //listingId 1
    }

    function testUpdateListing() public {
        vm.startPrank(deployer);

        marketplace.createListing(address(nft), 0, 1 ether); //listingId 1

        vm.expectEmit(true, true, true, true);
        emit ListingUpdated(1, deployer, address(nft), 0, 2 ether);
        marketplace.updateListing(1, 2 ether);

        vm.stopPrank();
    }

    function testCancelListing() public {
        vm.startPrank(deployer);

        marketplace.createListing(address(nft), 0, 1 ether); //listingId 1

        vm.expectEmit(true, false, false, false);
        emit ListingCancelled(1);
        marketplace.cancelListing(1);

        vm.stopPrank();
    }

    function testBuyListing() public {
        vm.prank(deployer);
        marketplace.createListing(address(nft), 0, 1 ether); //listingId 1
        vm.expectEmit(true, false, false, false);
        emit ItemSold(1, address(nft), deployer, alice, 1 ether);
        vm.prank(alice);
        marketplace.buyToken{value: 1 ether}(1);
    }

    function testWithdraw() public {
        vm.prank(deployer);
        marketplace.createListing(address(nft), 0, 1 ether); //listingId 1

        vm.prank(alice);
        marketplace.buyToken{value: 1 ether}(1);

        vm.prank(deployer);
        marketplace.withdraw();
    }
}
   