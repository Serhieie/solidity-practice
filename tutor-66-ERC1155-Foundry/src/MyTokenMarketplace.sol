// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import {MyToken } from "./MyToken.sol";

contract MyTokenMarketplace {
    MyToken token;

    struct OwnedToken {
        uint amount;
        uint price;
    }

    mapping(address owner => mapping(uint tokenId => OwnedToken)) public ownedTokens;
    mapping(address owner => uint[] tokenIds) public tokensByOwner;
    mapping(uint tokenId => uint totalAmount) public tokensInStock;
    mapping(uint tokenId => address[] owners) public canBePurchasedFrom;

    uint[] public availableTokenIds;

    constructor (address _token){
        token = MyToken(_token);
    }


    function addTokens(
        uint[] memory tokenIds,
        uint[] memory amounts,
        uint[] memory prices
        )external {
        address tokensOwner = msg.sender;
        require(token.isApprovedForAll(tokensOwner, address(this)), "Invalid approval");
        uint count = tokenIds.length;
        require(count == amounts.length && count == prices.length);

        for(uint i = 0; i < count; ++i){
            uint currentId = tokenIds[i];
            uint currentBalance = token.balanceOf(tokensOwner, currentId);
            uint currentAmount = amounts[i];

            require(currentBalance >= currentAmount);

            uint currentPrice  = prices[i];

            require(currentPrice > 0);

            if(tokensInStock[currentId] == 0) {
                availableTokenIds.push(currentId);
            }

            tokensInStock[currentId] += currentAmount;
            OwnedToken storage currentOwnedToken = ownedTokens[tokensOwner][currentId];
            if(currentOwnedToken.price == 0 && currentOwnedToken.amount == 0){
                tokensByOwner[tokensOwner].push(currentId);

                canBePurchasedFrom[currentId].push(tokensOwner);
            }

            currentOwnedToken.price = currentPrice;
            currentOwnedToken.amount += currentAmount;
        }
    }

    function removeAllTokens()
    external {
        address tokensOwner = msg.sender;
        uint totalTokensNum = tokensByOwner[tokensOwner].length;

        for(uint i = 0; i < totalTokensNum; ++i){
            uint currentId = tokensByOwner[tokensOwner][i];

            OwnedToken storage currentToken =
             ownedTokens[tokensOwner][currentId];

            decreaseTokensInStock(currentId, currentToken.amount);

            removeCanBePurchasedFrom(currentId, tokensOwner);

            removeOwnedTokens(currentId, tokensOwner);
        }
            delete tokensByOwner[tokensOwner];
    }



    // Ще треба доробити що б функція спочатку продавала найдешевіші токени (Питання сортування маппінгів, чи це дорого)
    function buy(
    uint[] memory ids,
    uint[] memory amounts
    ) external payable{
        uint grandTotal;
        uint count = ids.length;
        require(count == amounts.length);

         for(uint i = 0; i < count; ++i){
            uint currentId = ids[i];
            uint desiredAmount = amounts[i];

            require(availableAmount(currentId) >= desiredAmount); 

            uint currentAmount;
            uint j;

            while(currentAmount < desiredAmount){
                bool allTokensBought;
                address currentOwner = canBePurchasedFrom[currentId][j];
                OwnedToken storage currentlyOwnedToken = ownedTokens[currentOwner][currentId];

                uint requiredTokens = desiredAmount - currentAmount;
                uint amountAvailable;
                uint currentPrice = currentlyOwnedToken.price;

                if(currentlyOwnedToken.amount > requiredTokens){
                    amountAvailable = requiredTokens;

                    currentlyOwnedToken.amount -= requiredTokens;
                } else {
                    amountAvailable = currentlyOwnedToken.amount;
                    removeCanBePurchasedFrom(currentId, currentOwner);
                    removeTokensByOwner(currentId, currentOwner);
                    removeOwnedTokens(currentId, currentOwner);

                    allTokensBought = true;
                }
                currentAmount += amountAvailable;
                decreaseTokensInStock(currentId, amountAvailable);
                uint subTotal = amountAvailable * currentPrice;

                //.call
                // pendingWithdrawals[currentOwner] += subTotal;

                grandTotal += subTotal;

                token.safeTransferFrom(currentOwner, msg.sender, currentId, amountAvailable, "");

                if(!allTokensBought)++j;
            }
         }
        
        require(grandTotal == msg.value);
    }

    function totalPrice(uint[] memory ids,
    uint[] memory amounts) external view returns(uint price){
        uint count = ids.length;
        require(count == amounts.length );

        for(uint i = 0; i < count; ++i){
            uint currentId = ids[i];
            uint desiredAmount = amounts[i];

            require(availableAmount(currentId) >= desiredAmount); 

            uint currentAmount;
            uint j;

            while(currentAmount < desiredAmount){
                address currentOwner = canBePurchasedFrom[currentId][j];

                OwnedToken storage currentlyOwnedToken =
                ownedTokens[currentOwner][currentId];

                uint requiredTokens = desiredAmount - currentAmount;

                if(currentlyOwnedToken.amount > requiredTokens){
                    currentAmount = desiredAmount;
                    price = price + (requiredTokens * currentlyOwnedToken.price);
                } else {
                    currentAmount += currentlyOwnedToken.amount;

                    price = price + (currentlyOwnedToken.amount * currentlyOwnedToken.price);
                }   
                ++j;
            }

        }
        // revert("I cannot find the requested element!");
    }
    //helpers time
    //funcs helpers ця функція змішує індекси і нарушає порядок але видаляє потрібний
    function removeCanBePurchasedFrom(uint currentId, address currentOwner) private {
        uint256 ownerIndex = indexOfOwner(currentId, currentOwner);

        canBePurchasedFrom[currentId][ownerIndex] =
        canBePurchasedFrom[currentId][canBePurchasedFrom[currentId].length - 1];

        canBePurchasedFrom[currentId].pop();
    }

    function decreaseTokensInStock(uint currentId, uint amount)private{
        tokensInStock[currentId] -= amount;

        if(tokensInStock[currentId] == 0){
            uint index = indexOfTokenId(currentId);

            availableTokenIds[index] = availableTokenIds[availableTokenIds.length - 1];
            availableTokenIds.pop();
        }
    }
    

    function indexOfOwner(uint _tokenId, address _ownerToSearch) internal view returns(uint){
        uint length = canBePurchasedFrom[_tokenId].length;

        for(uint i = 0; i < length; ++i){
            if(canBePurchasedFrom[_tokenId][i] == _ownerToSearch){
                return i;
            }
        }
        revert("I cannot find the requested element!");
    }

    function removeOwnedTokens(uint currentId, address currentOwner) private{
        delete ownedTokens[currentOwner][currentId];
    }

    function removeTokensByOwner(uint currentId, address currentOwner) private {
        uint tokenByOwnerIndex = indexOfTokenByOwner(currentOwner, currentId);
        tokensByOwner[currentOwner][tokenByOwnerIndex] = 
        tokensByOwner[currentOwner][tokensByOwner[currentOwner].length - 1];

        tokensByOwner[currentOwner].pop();
    }

    function indexOfTokenId(uint _seatchFor)internal view returns(uint){
        uint length = availableTokenIds.length;

        for(uint i = 0; i < length; ++i){
            if(availableTokenIds[i] == _seatchFor){
                return i;
            }
        }

        revert("I cannot find the requested element!");
    }

    function indexOfTokenByOwner(address _owner, uint _tokenToSearch) internal view returns(uint){
        uint length = tokensByOwner[_owner].length;

        for(uint i = 0; i < length; ++i){
            if(tokensByOwner[_owner][i] == _tokenToSearch){
                return i;
            }
        }

        revert("I cannot find the requested element!");
    }


    function availableAmount(uint _tokenId) public view returns(uint){
        return tokensInStock[_tokenId];
    }

    function anyOwner(uint _tokenId)public view returns(bool) {
        return canBePurchasedFrom[_tokenId].length > 0;
     }

}
