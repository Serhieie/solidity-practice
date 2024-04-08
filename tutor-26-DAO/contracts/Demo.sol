// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;


contract Demo {
    string public message;
    address public owner;

    constructor(){
        owner = msg.sender;
    }

    function transferOwnership(address _to) external {
        require(msg.sender == owner);
        owner = _to;
    }

    mapping(address=>uint) public balances;
    function pay (string calldata _message) external payable{
        require(msg.sender == owner, "Not an owner");
        message = _message;
        balances[msg.sender] = msg.value;
    }
}   
