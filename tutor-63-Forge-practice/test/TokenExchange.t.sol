// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {Test, console} from "../lib/forge-std/src/Test.sol";
import {MyToken} from "../src/MyToken.sol";
import {InvalidSum, InsufficientTokens, InvalidAllowance, InsufficientFunds, TokenExchange} from "../src/TokenExchange.sol";

contract MyTokenTest is Test{
    MyToken mtk;
    TokenExchange exchange;

    address exchAddr;
    address self;
    uint256 exchangeTokenBalance = 50;


    address alice = makeAddr("alice");
    address bob = makeAddr("bob");

    function setUp() public {
        self = address(this);
        mtk = new MyToken(123);
        exchange = new TokenExchange(address(mtk));
        exchAddr = address(exchange);

        mtk.transfer(exchAddr, withDecimals(exchangeTokenBalance));
        exchange.topUp{value: 10 ether}();
    }   

    function withDecimals(uint _amount) private view returns(uint){
        return _amount * 10 ** mtk.decimals();
    }


    function testBuy()external {
        uint amount = 3 ether;
        uint initialBalance = exchAddr.balance;

        // викликається якщо на адрессі яку ми створили потрібен єфір
        hoax(alice);
        exchange.buy{value: amount}();

        assertEq(exchAddr.balance, initialBalance + amount);
        assertEq(mtk.balanceOf(exchAddr), withDecimals(exchangeTokenBalance) - amount);
        assertEq(mtk.balanceOf(alice),  amount);
    }

    function test_RevertBuyWhenNoTokens() public {
        uint amount = 350 ether;

        vm.expectRevert(
        abi.encodeWithSelector(
        InsufficientTokens.selector, amount, mtk.balanceOf(exchAddr)));
        exchange.buy{value: amount}();
    }


    function testSell()external {
        uint amount = withDecimals(5);
        uint exchEthBalance = exchAddr.balance;
        uint ownerTokenBalance = mtk.balanceOf(self);
        uint ownerEthBalance = self.balance;

        // викликається якщо на адрессі яку ми створили потрібен єфір
        mtk.approve(exchAddr, amount);
        assertEq(mtk.allowance(self, exchAddr), amount);
        
        exchange.sell(amount);
        assertEq(exchAddr.balance,  exchEthBalance - amount);
        assertEq(mtk.allowance(self, exchAddr), 0);
    }

    receive() external payable {}
}