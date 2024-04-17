// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract TheFuzz {

    function callMe(address _to, uint256 _nonce) external payable  returns(bytes memory) {
        require(_nonce > 0 && _to != address(0), "wrong params");
        return abi.encode(uint256(uint160(_to)), _nonce);
    }
}
