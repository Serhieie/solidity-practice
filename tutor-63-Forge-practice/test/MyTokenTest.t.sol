// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {Test, console} from "../lib/forge-std/src/Test.sol";
import {MyToken} from "../src/MyToken.sol";

contract MyTokenTest is Test{
    MyToken token;
    address alice = makeAddr("alice");
    address bob = makeAddr("bob");

    function setUp() public {
        token = new MyToken(123);
    }

    function testInitialSupply() external view{
        assertEq(token.totalSupply(), 123 * 10 ** token.decimals());
    }


    function testTokenTransfer() external {
        uint amount = 10;
        token.transfer(alice, amount);
        assertEq(token.balanceOf(alice), amount);
    }


    function testTransferFrom()external {
        uint totalAmount = 10;
        uint transferAmount = 6;

        token.approve(bob, totalAmount);

        vm.prank(bob);
        token.transferFrom(address(this), alice, transferAmount);

        assertEq(token.allowance(address(this), bob), totalAmount - transferAmount);
        assertEq(token.balanceOf(alice), transferAmount);
    }

    function testMint() external {
        uint amount = 10;
        uint initialSupply = token.totalSupply();
        token.mint(alice, amount);

        assertEq(token.balanceOf(alice), amount);
        assertEq(token.totalSupply(), initialSupply + amount);
    }

    function testBurn() external {
        uint amount = 10;
        uint initialSupply = token.totalSupply();
        token.burn(amount);

        assertEq(token.balanceOf(address(this)), initialSupply - amount);
        assertEq(token.totalSupply(), initialSupply - amount);
    }

}