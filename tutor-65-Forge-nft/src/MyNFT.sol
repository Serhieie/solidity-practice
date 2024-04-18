// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MyNFT  is ERC721 , ERC721Burnable {
    uint private _nextTokenId = 1;

    constructor ()ERC721("MyNFT", "MNFT"){}

    function tokenURI(uint256 tokenId) public view override returns(string memory){
        string memory fullURI = super.tokenURI(tokenId);
        return string.concat(fullURI, ".jpg");
    }

    function _baseURI() internal pure override returns(string memory){
        return "https://example-of-your-site/nfts";
    }

    function safeMint(address to) public {
        uint tokenId = _nextTokenId++;

        _safeMint(to, tokenId);
    }


}
