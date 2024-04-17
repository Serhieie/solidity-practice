// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "../lib/forge-std/src/Test.sol";
import "../lib/forge-std/src/console.sol";
import "../src/MyToken.sol";
import "../src/FlashBorrower.sol";
import {IERC3156FlashLender} from "../src/IERC3156FlashLender.sol";

contract MyTokenTest is Test {
    MyToken mtk;
    FlashBorrower borrower;
    address self = address(this);
    event Action1(address borrower, address token, uint amount, uint fee);

    function setUp() public {
        mtk = new MyToken();
        borrower = new FlashBorrower(IERC3156FlashLender(address(mtk)));

        mtk.mint(address(borrower), 10);
    }

    function testFlashBorrow() public {
        assertEq(mtk.balanceOf(self), 0);
        uint amount = 20000;
        uint fee = mtk.flashFee(address(mtk), amount);

        vm.expectEmit(false, false, false, true, address(borrower));
        emit Action1(address(borrower), address(mtk), amount, fee);
        borrower.flashBorrow(address(mtk), amount, abi.encode(1));

        assertEq(mtk.balanceOf(self), fee);
    }
}