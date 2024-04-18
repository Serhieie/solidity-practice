// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import { MyNFT } from "./MyNFT.sol";

event NFTAdded(uint indexed tokenId, uint price, address seller);

contract MyNFTMarketplace  {
    MyNFT nft;
    address owner;

    mapping(uint tokenId => uint price) public items;
    mapping(uint tokenId => address owner) public owners;

    uint public constant FEE = 5; //5%

    constructor (address _token){
        owner = msg.sender;
        nft = MyNFT(_token);
    }

    //1 Овнер робить апрув поперше для маркетплейсу
    //2 Овнер викликає функцію Адд
    //3 Маркетплейс перевіряє апрув
    function add(uint _tokenId, uint _price)external {
        address currentOwner = nft.ownerOf(_tokenId);
        require(currentOwner == msg.sender);
        require(nft.isApprovedForAll(currentOwner, address(this)) || 
        nft.getApproved(_tokenId) == address(this), "Invalid approval");
        require(_price > 0);

        items[_tokenId] = _price;
        owners[_tokenId] = currentOwner;

        emit NFTAdded(_tokenId, _price, msg.sender);
    }

    function buy(uint _tokenId) external payable {
        require(nft.ownerOf(_tokenId) != address(0));
        require(items[_tokenId] > 0 );
        address currentOwner = owners[_tokenId];
        uint price = items[_tokenId];
        require(msg.value == price);

        nft.safeTransferFrom(currentOwner, msg.sender, _tokenId);

        delete items[_tokenId];
        delete owners[_tokenId];

        (bool ok, ) = currentOwner.call{value: (price - (price * FEE) / 100)}("");
        require(ok);
    }


    function removeMyNFT(uint _tokenId) external {
        address nftOwner = owners[_tokenId];     
        require(nftOwner == msg.sender);

        delete items[_tokenId];
        delete owners[_tokenId];
    }
}
