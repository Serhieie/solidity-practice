// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol"; 
import "@openzeppelin/contracts/access/Ownable.sol";


error InvalidSum(uint256 sum);
error InsufficientTokens(uint256 requested, uint256 available);
error InvalidAllowance(address owner, address spender, uint256 amount);
error InsufficientFunds(uint256 requested, uint256 available);

contract TokenExchange is Ownable {
    IERC20 token;

    constructor(address _token)Ownable(msg.sender){
        token = IERC20(_token);
    }

    function buy() public payable {
        uint amount = msg.value; //wei 

        if(amount < 1 ){
            revert InvalidSum(amount);
        }

        uint currentBalance = token.balanceOf(address(this));

        if (currentBalance < amount)revert InsufficientTokens(amount, currentBalance);

        token.transfer(msg.sender, amount);
    }

    function sell(uint amount_) external {
        //sell:
        //1 Шаг це продающа людина дає право списувати у нього токени 
        //2 Перевірка чи є єлованс
        //3 Забираємо токени
        //4 Повертаємо гроші 
        if(address(this).balance < amount_) 
        revert InsufficientFunds(
        amount_ , address(this).balance);

        if(token.allowance(msg.sender, address(this)) < amount_) 
        revert InvalidAllowance(
        msg.sender , address(this), amount_);

        token.transferFrom(msg.sender, address(this), amount_);

        (bool ok, ) = msg.sender.call{value: amount_}("");
    }

    function topUp() external payable onlyOwner {}

    receive() external payable {
        buy();
    }
}

