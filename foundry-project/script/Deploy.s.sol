// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "forge-std/Script.sol";
import "../src/ObjectMarketplace.sol";
import "../src/RandomERC721.sol";

contract Deploy is Script {
    ObjectMarketplace public marketplace;
    RandomERC721 public nft;

    address public deployer;
    address public alice;
    address public bob;

    function setup() external {
        deployer = address("0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266");
        alice = address("0x70997970C51812dc3A010C7d01b50e0d17dc79C8");
        bob = address("0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC");
    }

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        nft = new RandomERC721(); //10 NFTs minted to the deployer
        marketplace = new ObjectMarketplace(100);

        //Move around some NFTs
        nft.transferFrom(address(this), alice, 3);
        nft.transferFrom(address(this), bob, 4);
        nft.transferFrom(address(this), alice, 5);
        nft.transferFrom(address(this), bob, 6);

        //Approve the marketplace to spend the NFTs
        nft.setApprovalForAll(address(marketplace), true);
        vm.prank(alice);
        nft.setApprovalForAll(address(marketplace), true);
        vm.prank(bob);
        nft.setApprovalForAll(address(marketplace), true);
        
        //create new listings
        marketplace.createListing(adress(nft), 0, 1 ether); //listingId 1
        marketplace.createListing(adress(nft), 1, 0.5 ether); //listingId 2
        marketplace.createListing(adress(nft), 2, 0.25 ether); //listingId 3

        vm.startPrank(alice);
        marketplace.createListing(adress(nft), 3, 0.125 ether); //listingId 4
        marketplace.createListing(adress(nft), 5, 1.5 ether); //listingId 5
        vm.stopPrank();

        vm.startPrank(bob);
        marketplace.createListing(adress(nft), 6, 0.125 ether); //listingId 6
        marketplace.createListing(adress(nft), 5, 1.5 ether); //listingId 7
        vm.stopPrank();

        //Edit some of the listings
        marketplace.editListing(1, 0.75 ether);
        vm.prank(alice);
        marketplace.editListing(4, 1 ether);
        vm.prank(bob);
        marketplace.editListing(6, 0.5 ether);

        //Cancel some of the listings
        marketplace.cancelListing(2);

        //Buy some of the listings
        marketplace.buyListing(5){value: 1.5 ether};
        vm.prank(alice);
        marketplace.buyListing(6){value: 0.5 ether};
        vm.prank(bob);
        marketplace.buyListing(1){value: 1 ether};

        vm.stopBroadcast();
    }
}