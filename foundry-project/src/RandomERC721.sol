//SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

//@dev This is a simple ERC721 contract that mints 10 NFTs to the contract owner
contract RandomERC721 is ERC721 {

    constructor() ERC721("RandomNFT721", "RNFT") {
        for (uint256 i= 0; i < 10; i++){
            _mint(msg.sender, i);
        }
    }

}