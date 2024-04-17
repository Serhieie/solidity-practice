// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;


import  "../lib/forge-std/src/Test.sol";
import  "../lib/forge-std/src/console.sol";
import {Demo} from "../src/Demo.sol";

contract DemoTest is Test {
    Demo public counter;

    function setUp() public {
        counter = new Demo();
    }

}
