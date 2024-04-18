// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import {Strings } from "./Strings.sol";

contract MyToken is ERC1155 , ERC1155Burnable {
    using Strings for uint256;

    constructor ()ERC1155("https://example-of-your-site/nfts"){}

    function setURI(string memory newUri) public {
        _setURI(newUri);
    }

    function uri(
        uint256 tokenId
        ) public view override returns(string memory){
        string memory _uri = super.uri(0);
        return string.concat(_uri, tokenId.toString());
    }

    function mint(
        address account,
        uint256 id,
        uint256 amount,
        bytes memory data
        ) public {
        _mint(account, id, amount, data);
    }

    function mintBatch(
        address to, 
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
        ) public {
        _mintBatch(to, ids, amounts, data);
    }


}
