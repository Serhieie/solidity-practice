// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

contract HardhatDemo {
    uint demo = 111;
    string public message;
    address public caller;
    function get() public view returns(uint){
        return demo;
    }

    function pay (string memory _message) public payable{
        demo = msg.value;
        message = _message;
    }
    function callMe()public{
        caller = msg.sender;
    }

    function callError()public pure {
        assert(false); //Panic
    }
}
