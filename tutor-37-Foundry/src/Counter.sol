// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;


contract Counter {
    uint public myNum;
    address public owner;

    event Inc(uint indexed number, address indexed initiator);

     constructor(uint _initialNum){
        myNum = _initialNum;
        owner = msg.sender;
    }

    modifier onlyOwner(){
        require(msg.sender == owner, "not an owner!");
        _;
    }

    function increment() external onlyOwner{
        myNum += 1;
        emit Inc(myNum, msg.sender);
    }


    receive() external payable {

    }
}