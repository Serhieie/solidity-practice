// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract Sample {
    //state  =  2**256 - 1
    // 1 sloth = 32bytes (256bit), 1byte = 8 bit

    uint[] arr;//1 ==> main (length)
    //keccak256(position(наприклад 1)); 0x...

    uint256 a = 123;
    uint128 b = 10; // слоти записуються зправа на ліво
    uint128 c = 20;


    //address = 20 byte
    mapping(address => uint) mapp; //3
    //keccak256(key(ключ до мапінгу, який буде concat до position), position(наприклад 1)); 0x...
    // ethers.solidityPackedKeccak256(['uint256', 'uint256'], [sample.target, 4])


    constructor(){
        arr.push(10);
        arr.push(20);
        mapp[address(this)] = 100;
    }

}
