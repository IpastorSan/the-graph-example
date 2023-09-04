/* // SPDX-License-Identifier: UNLICENSED
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
        nft = new RandomERC721(base_uri);
        utils = new Utils();
        users = utils.createUsers(3);
        deployer = users[0];
        vm.label(deployer, "deployer");
        alice = users[1];
        vm.label(alice, "alice");
        bob = users[2];
        vm.label(bob, "bob");
    }
    function testNoMintPricePaid() public {
            vm.prank(alice, alice);
            //Custom Errors and events are NOT available in current scope because they come from an interface.
            //We reproduce the selector of the Custom Error
            vm.expectRevert(bytes4(keccak256(bytes("IncorrectAmountOfEther()"))));
            nft.mintNFTs{value: 0 ether}(1);
        }

    function testMintPricePaid() public {
        //sets msg.sender and tx.origin to be alice
        vm.startPrank(alice, alice);

        vm.expectEmit(true, true, false, false);
        emit NFTMinted(1, 1, alice);

        nft.mintNFTs{value: 0.1 ether }(1);
    }

    function testMaxSupplyReached() public {
        uint256 slot = stdstore.target(address(nft)).sig("index()").find();
        console.log("%s", "Storage slot for index:", slot);

        bytes32 loc = bytes32(slot);
        bytes32 mockedCurrentTokenId = bytes32(abi.encode(10000));
        vm.store(address(nft), loc, mockedCurrentTokenId);

        uint256 storage_content = stdstore.target(address(nft)).sig("index()").read_uint();
        console.log("%s", "Value in index storage slot:", storage_content);

        vm.prank(alice, alice);
        vm.expectRevert(bytes4(keccak256(bytes("NotEnoughNFTsLeft()"))));
        nft.mintNFTs{value: 0.1 ether }(1);
        }

    function testMintNewOwnerRegistered() public {
        //sets msg.sender and tx.origin to be alice
        vm.startPrank(alice, alice);
        nft.mintNFTs{value: 0.1 ether }(1);

        uint256 slot = stdstore.target(address(nft)).sig(nft.ownerOf.selector).with_key(1).find();
        //uint160 can be directly converted to address
        uint160 ownerOfTokenIdOne = uint160(
            uint256((vm.load(address(nft), bytes32(abi.encode(slot))))
            )
        );
        assertEq(address(ownerOfTokenIdOne), alice);
    }

    function testBalanceIncremented() public {
        vm.prank(alice, alice);
        nft.mintNFTs{value: 0.1 ether }(1);

        uint256 slotBalance = stdstore.target(address(nft)).sig(nft.balanceOf.selector).with_key(alice).find();
        uint256 balanceFirstMint = uint256(vm.load(address(nft), bytes32(slotBalance)));
        assertEq(balanceFirstMint, 1);

        vm.prank(alice, alice);
        nft.mintNFTs{value: 0.1 ether }(1);
        uint256 balanceSecondMint = uint256(vm.load(address(nft), bytes32(slotBalance)));
        assertEq(balanceSecondMint, 2);
    }

    function testBalanceTransfer() public {
        vm.startPrank(alice, alice);
        nft.mintNFTs{value: 0.1 ether }(1);

        uint256 slotBalanceAlice = stdstore.target(address(nft)).sig(nft.balanceOf.selector).with_key(alice).find();
        uint256 balanceAliceFirstMint = uint256(vm.load(address(nft), bytes32(slotBalanceAlice)));
        assertEq(balanceAliceFirstMint, 1);

        vm.expectEmit(true, true, false, false);
        emit Transfer(alice, bob, 1);

        nft.transferFrom(alice, bob, 1);
        uint256 slotBalanceBob = stdstore.target(address(nft)).sig(nft.balanceOf.selector).with_key(bob).find();

        uint256 balanceAlice = uint256(vm.load(address(nft), bytes32(slotBalanceAlice)));
        uint256 balanceBob = uint256(vm.load(address(nft), bytes32(slotBalanceBob)));

        assertEq(balanceAlice, 0);
        assertEq(balanceBob, 1);
    }

    function testFailURIChanged() public {
        string memory baseUriOriginal = nft.baseTokenURI();
        console.log("%s","Original base URI:", baseUriOriginal);

        nft.reveal("ipfs://new-example-hash/");
        string memory baseUriNew= nft.baseTokenURI();
        console.log("%s","Newbase URI:", baseUriNew);
        //we cant directly compare strings, but we can compare hashes
        assertEq(keccak256(abi.encodePacked(baseUriOriginal)), keccak256(abi.encodePacked(baseUriNew)));
    }

    function testURIChangedEmitsEvent() public {
        string memory baseUriOriginal = nft.baseTokenURI();
        console.log("%s","Original base URI:", baseUriOriginal);

        vm.expectEmit(true, false, false, false);
        emit BaseURIChanged("ipfs://new-example-hash/");

        nft.reveal("ipfs://new-example-hash/");
        string memory baseUriNew= nft.baseTokenURI();
        console.log("%s","Newbase URI:", baseUriNew);
    }

    function testWithdrawalWorksAsOwner() public{
        uint256 priorPayeeBalance = alice.balance;
        uint256 amount = 10;
        uint256 price = nft.PRICE();

        vm.prank(bob, bob);
        nft.mintNFTs{value: price * amount}(amount);
        // Check that the balance of the contract is correct
        uint256 nftBalance = address(nft).balance;
        assertEq(nftBalance, price * amount);

        // Withdraw the balance and assert it was transferred
        nft.transferOwnership(alice);


        //owner() is now alice
        vm.prank(alice);
        nft.withdrawETH();
        assertEq(nft.owner().balance, priorPayeeBalance + nftBalance);
    }
    function testWithdrawalFailsAsNotOwner() public {
        uint256 amount = 10;
        uint256 price = nft.PRICE();

        vm.prank(bob, bob);
        nft.mintNFTs{value: price * amount}(amount);
        // Check that the balance of the contract is correct
        assertEq(address(nft).balance, price*amount);
        // Confirm that a non-owner cannot withdraw
        vm.startPrank(alice);
        vm.expectRevert("Ownable: caller is not the owner");
        nft.withdrawETH();
        vm.stopPrank();
    }
}
 */