// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";
import { MyToken } from "./MyToken.sol";

struct Item {
    uint256 price;
    uint256 quantity;
    string name;
    bool exists;
}

struct ItemInStock {
    bytes32 uid;
    uint256 price;
    uint256 quantity;
    string name;
}

struct BoughtItem {
    bytes32 uniqueId;
    uint256 numOfPurchasedItems;
    string deliveryAddress;
}

contract TokenShop is Ownable {
    mapping (bytes32 => Item) public items;
    
    bytes32[] public uniqueIds;

    mapping(address => BoughtItem[]) public buyers;

    MyToken public mtk;

    constructor(address _mtk)Ownable(msg.sender){
        mtk = MyToken(_mtk);
    }


    function addItem(
        uint _price,
        uint _quantity,
        string calldata _name)
        external onlyOwner returns(bytes32 uid){
        require(_price > 0 && _quantity > 0, "price and quantity cant be 0");
        uid = keccak256(abi.encode(_price, _name));
        
        items[uid] = Item({
            price: _price,
            name: _name,
            quantity: _quantity,
            exists: true
        });
        uniqueIds.push(uid);
    }


    function buy(bytes32 _uid, uint _numOfItems, string calldata _address )external{
        require(_numOfItems > 0, "price and quantity cant be 0");
        Item storage itemToBuy = items[_uid];
        require(itemToBuy.exists);
        require(itemToBuy.quantity >= _numOfItems);

        uint totalPrice = _numOfItems * itemToBuy.price;
        // require(check allowance);
        mtk.transferFrom(msg.sender, address(this), totalPrice);

        itemToBuy.quantity -= _numOfItems;

        buyers[msg.sender].push(
            BoughtItem({
                uniqueId: _uid,
                numOfPurchasedItems: _numOfItems,
                deliveryAddress: _address
            })
        );
    }


    //pagination foo
    function availableItems(uint _page, uint _count)external view returns(ItemInStock[] memory){
        require(_page > 0 && _count > 0);

        uint totalItems = uniqueIds.length;

        ItemInStock[] memory stockItems = new ItemInStock[](_count);

        uint counter;

        for(uint i = _count * _page - _count; i < _count * _page; ++i){
            if(i >= totalItems) break;
            bytes32 currentUid = uniqueIds[i];
            Item storage currentItem = items[currentUid];

            stockItems[counter] = ItemInStock({
                uid: currentUid,
                price: currentItem.price,
                quantity: currentItem.quantity,
                name: currentItem.name
            });
            counter ++;
        }
        return stockItems;

    }
}

