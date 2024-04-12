// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "../lib/forge-std/src/Test.sol";
import { Counter } from "../src/Counter.sol";
import {Helper} from "./Helper.sol";
import "../lib/forge-std/src/console.sol";

contract CounterTest is Test, Helper{
    Counter public counter;
    event Inc(uint indexed number, address indexed initiator);

    function setUp() public {
        counter = new Counter(100);
        console.log(counter.myNum());
        console.log(counter.owner());
        console.log(address(this));
        console.log(address(this).balance);

    }

    // function testFailSubstraction() public view {
    //     uint myNum = counter.myNum();
    //     myNum -= 1000;
    // }

        function testSubstractionUnderFlow() public {
        uint myNum = counter.myNum();
        vm.expectRevert(stdError.arithmeticError);
        myNum -= 1000;
    }

    function testIncrement() public {
        vm.expectEmit(true, true, true, false);
        emit Inc(101, address(this));
        counter.increment();
        assertEq(counter.myNum(), 101);
        console.log(counter.myNum());
    }

    // function testFailIncrementNotAnOwner() public {
    //     vm.prank(address(0));
    //     counter.increment();
    // }

    function testIncrementNotAnOwner() public {
        vm.expectRevert(bytes("not an owner!"));
        vm.prank(address(0));
        counter.increment();
    }


    function testReceive() public {
        assertEq(address(counter).balance, 0);
        (bool success,)  = address(counter).call{value: 100}("");
        assertEq(success, true);
        assertEq(address(counter).balance, 100);
    }
}