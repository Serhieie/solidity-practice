// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./IERC4907.sol";

contract ERC4907 is ERC721, IERC4907 {
    struct UserInfo{
        address user;
        uint64 expires;
    }

    mapping (uint256 => UserInfo) internal _users;

    constructor(string memory name_, string memory symbol_)ERC721(name_, symbol_){}

     function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return
            interfaceId == type(IERC4907).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function setUser(uint tokenId, address user, uint64 expires) public virtual{
        require(_isApprovedOrOwner(msg.sender, tokenId));
        UserInfo storage info = _users[tokenId];
        info.user = user;
        info.expires = expires;

        emit UpdateUser(tokenId, user, expires);
        }
    function userOf(uint tokenId) public view virtual returns(address){
        if(userExpires(tokenId) >= block.timestamp) {
            return _users[tokenId].user;
        } else {
            return address(0);
        }
    }
    function userExpires(uint tokenId) public view virtual returns(uint){
        return _users[tokenId].expires;
    }



    function _isApprovedOrOwner(address spender, uint tokenId) internal view returns(bool) {
    address owner = ownerOf(tokenId);
    return(
            spender == owner ||
            isApprovedForAll(owner, spender) ||
            getApproved(tokenId) == spender
        );
    }


    function _beforeTokenTransfer(address from, address to, uint256 tokenId, uint batchSize) internal virtual {
        // super._beforeTokenTransfer(from,to,tokenId, batchSize);

        if(from != to && _users[tokenId].user != address(0)){
            delete _users[tokenId];
        }

        emit UpdateUser(tokenId, address(0), 0);
    }


    //usual at ERC721
    // function _beforeTokenTransfer(
    //     address from, address to, uint tokenId, uint batchSize
    // ) internal virtual {
    //     if(batchSize > 1){
    //         if(from != address(0)){
    //             _balances[from] -= batchSize;
    //         }
    //         if(to != address(0)){
    //             _balances[from] += batchSize;
    //         }
    //     }
    // }
}