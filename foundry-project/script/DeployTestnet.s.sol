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
    uint256 wallet1PrivateKey;
    uint256 wallet2PrivateKey;

    function setUp() external {
        deployer = address(vm.envAddress("DEPLOYER"));
        alice = address(vm.envAddress("WALLET_1"));
        bob = address(vm.envAddress("WALLET_2"));
        deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        wallet1PrivateKey = vm.envUint("PRIVATE_KEY_DEV_WALLET_1");
        wallet2PrivateKey = vm.envUint("PRIVATE_KEY_DEV_WALLET_2");
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
        marketplace.createListing(address(nft), 0, 0.00025 ether); //listingId 1
        marketplace.createListing(address(nft), 1, 0.5 ether); //listingId 2
        marketplace.createListing(address(nft), 2, 0.25 ether); //listingId 3
        vm.stopBroadcast();

        vm.startBroadcast(wallet1PrivateKey);
        marketplace.createListing(address(nft), 3, 0.125 ether); //listingId 4
        marketplace.createListing(address(nft), 5, 0.00075 ether); //listingId 5
        vm.stopBroadcast();

        vm.startBroadcast(wallet2PrivateKey);
        marketplace.createListing(address(nft), 4, 0.125 ether); //listingId 6
        marketplace.createListing(address(nft), 6, 1.5 ether); //listingId 7
        vm.stopBroadcast();

        //Edit some of the listings
        vm.broadcast(deployerPrivateKey);
        marketplace.updateListing(2, 0.75 ether);
        vm.broadcast(alice);
        marketplace.updateListing(4, 1 ether);
        vm.broadcast(bob);
        marketplace.updateListing(6, 0.0005 ether);

        //Cancel some of the listings
        vm.broadcast(deployerPrivateKey);
        marketplace.cancelListing(2);

        //Buy some of the listings
        vm.broadcast(deployerPrivateKey);
        marketplace.buyToken{value: 0.00075 ether}(5);
        vm.broadcast(wallet1PrivateKey);
        marketplace.buyToken{value: 0.0005 ether}(6);
        vm.broadcast(wallet2PrivateKey);
        marketplace.buyToken{value: 0.00025 ether}(1);

    }
}