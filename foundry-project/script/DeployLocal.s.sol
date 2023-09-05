// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "forge-std/Script.sol";
import "../src/SimpleMarketplace.sol";
import "../src/RandomERC721.sol";

contract Deploy is Script {
    SimpleMarketplace public marketplace;
    RandomERC721 public nft;

    address public deployer;
    address public alice;
    address public bob;

    uint256 deployerPrivateKey;
    uint256 alicePrivateKey;
    uint256 bobPrivateKey;

    function setUp() external {
        deployer = address(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266);
        alice = address(0x70997970C51812dc3A010C7d01b50e0d17dc79C8);
        bob = address(0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC);
        deployerPrivateKey = vm.envUint("PRIVATE_KEY_DEPLOYER");
        alicePrivateKey = vm.envUint("PRIVATE_KEY_ALICE");
        bobPrivateKey = vm.envUint("PRIVATE_KEY_BOB");
    }

    function run() external {
        vm.startBroadcast(deployerPrivateKey);

        nft = new RandomERC721(); //10 NFTs minted to the deployer
        marketplace = new SimpleMarketplace(100);

        //Move around some NFTs
        nft.transferFrom(deployer, alice, 3);
        nft.transferFrom(deployer, bob, 4);
        nft.transferFrom(deployer, alice, 5);
        nft.transferFrom(deployer, bob, 6);

        //Approve the marketplace to spend the NFTs
        nft.setApprovalForAll(address(marketplace), true);
        vm.stopBroadcast();
        vm.broadcast(alice);
        nft.setApprovalForAll(address(marketplace), true);
        vm.broadcast(bob);
        nft.setApprovalForAll(address(marketplace), true);
        
        //create new listings
        vm.startBroadcast(deployerPrivateKey);
        marketplace.createListing(address(nft), 0, 1 ether); //listingId 1
        marketplace.createListing(address(nft), 1, 0.5 ether); //listingId 2
        marketplace.createListing(address(nft), 2, 0.25 ether); //listingId 3
        vm.stopBroadcast();

        vm.startBroadcast(alicePrivateKey);
        marketplace.createListing(address(nft), 3, 0.125 ether); //listingId 4
        marketplace.createListing(address(nft), 5, 1.5 ether); //listingId 5
        vm.stopBroadcast();

        vm.startBroadcast(bobPrivateKey);
        marketplace.createListing(address(nft), 4, 0.125 ether); //listingId 6
        marketplace.createListing(address(nft), 6, 1.5 ether); //listingId 7
        vm.stopBroadcast();

        //Edit some of the listings
        vm.broadcast(deployerPrivateKey);
        marketplace.updateListing(1, 0.75 ether);
        vm.broadcast(alice);
        marketplace.updateListing(4, 1 ether);
        vm.broadcast(bob);
        marketplace.updateListing(6, 0.5 ether);

        //Cancel some of the listings
        vm.broadcast(deployerPrivateKey);
        marketplace.cancelListing(2);

        //Buy some of the listings
        vm.broadcast(deployerPrivateKey);
        marketplace.buyToken{value: 1.5 ether}(5);
        vm.broadcast(alicePrivateKey);
        marketplace.buyToken{value: 0.5 ether}(6);
        vm.broadcast(bobPrivateKey);
        marketplace.buyToken{value: 0.75 ether}(1);

    }
}