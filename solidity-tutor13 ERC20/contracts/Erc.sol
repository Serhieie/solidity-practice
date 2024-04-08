// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "./IERC20.sol";

contract ERC20 is IERC20 {
    uint totalTokens;
    address owner;

    mapping(address => uint)balances;
    mapping(address => mapping(address => uint)) allowances;
    mapping(address => bool) blacklist;
    string _name;
    string _symbol;

    // Events
    event Blacklist(address indexed account);
    event Whitelist(address indexed account);
    
    //basic fu =================
    function name() external view  returns (string memory) {
        return _name;
    }

    function symbol() external view  returns (string memory) {
        return _symbol;
    }

    function decimals() external pure  returns (uint) {
        return 18; //1 token === 1 wei
    }

    function totalSupply() external view  returns (uint) {
        return totalTokens;
    }

    function balanceOf(address account) public view  returns (uint) {
        return balances[account];
    }

    //modifiers =================

    modifier enoughTokens(address _from, uint _amount) {
        require(balanceOf(_from) >= _amount, "Not enough tokens!");
        _;
    }
    modifier onlyOwner(){
        require(msg.sender == owner, "not an owner");
        _;
    }

    //token constructor ==========

    constructor(string memory name_, string memory symbol_, uint initialSupply, address shop){
        _name = name_;
        _symbol = symbol_;
        owner = msg.sender;
        mint(initialSupply, shop);
    }


    //operations fu ===============
    function mint(uint amount , address shop) public onlyOwner{
        _beforeTokenTransfer(address(0), shop, amount);
        balances[shop] += amount;
        totalTokens += amount;

    // Ціна в 4 долари за один токен
    // uint priceInWei = 4 * 10**18; // 1 Ether = 10^18 Wei
    
    // // Передача ефірів за вартість відповідно до кількості токенів
    // payable(shop).transfer(priceInWei * amount);
        emit Transfer(address(0),shop, amount);

    }

    function burn(address _from , uint amount) public onlyOwner enoughTokens(_from, amount){
        _beforeTokenTransfer(_from, address(0), amount);
        balances[_from] -= amount;
        totalTokens -= amount;
        }

    function transfer(address to, uint amount) external enoughTokens(msg.sender, amount) {
        _beforeTokenTransfer(msg.sender, to, amount);
        balances[msg.sender] -= amount;
        balances[to] += amount;
        emit Transfer(address(0),to, amount);
    }


    function allowance(address _owner, address spender) public view  returns (uint) {
    return allowances[_owner][spender];
    }

    function approve(address spender, uint amount) public {
        _approve(msg.sender, spender, amount);
    }

    function _approve(address sender, address spender, uint amount) internal virtual  {
        allowances[sender][spender] = amount;
        emit Approve(sender, spender, amount);
    }   

     function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external enoughTokens(sender, amount) {
        _beforeTokenTransfer(sender, recipient, amount);

        allowances[sender][msg.sender] -= amount;

        balances[sender] -= amount;
        balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
    }



    // Blacklist functions
    function addToBlacklist(address account) external onlyOwner {
        blacklist[account] = true;
        emit Blacklist(account);
    }

    function removeFromBlacklist(address account) external onlyOwner {
        blacklist[account] = false;
    }

    function isBlacklisted(address account) external view returns (bool) {
        return blacklist[account];
    }



    //helper fu =================
    function _beforeTokenTransfer(address from, address to, uint amount) internal virtual {}
}


contract SGRToken is ERC20 {
    constructor (address shop) ERC20("Solar Green", "SGR", 100000000, shop) {}
        function _beforeTokenTransfer(address from, address to, uint amount) internal pure override {
            // require(from != address(0));
        }
}


contract TShop {
    IERC20 public token;
    address payable public owner;
    event Bought(uint _amount, address indexed _buyer);
    event Sold(uint _amount, address indexed seller);
    constructor(){
        token = new SGRToken(address(this));
        owner = payable(msg.sender);
        
    }

     modifier onlyOwner(){
        require(msg.sender == owner, "not an owner");
        _;
    }

    function sell(uint _amountToSell) external {
        require(
            _amountToSell > 0 && token.balanceOf(msg.sender) >= _amountToSell,
            "incorrect amount!"
        );
        
        uint allowance = token.allowance(msg.sender, address(this));
        require(allowance >= _amountToSell, "check allowance");

        token.transferFrom(msg.sender, address(this), _amountToSell);

        payable(msg.sender).transfer(_amountToSell);
    }
        
        function balanceOf (address addressToCheck) public view returns(uint){
        return token.balanceOf(addressToCheck);
        }


        receive() external payable{
        uint tokensToBuy = msg.value;

        require(tokensToBuy > 0 , "not anough founds!");
        require(tokenBalance() >= tokensToBuy, "not enough tokens!");
        
        token.transfer(msg.sender, tokensToBuy);
        emit Bought(tokensToBuy, msg.sender);
    }

    function tokenBalance() public view returns(uint){
        return token.balanceOf(address(this));
    }
}

// Localhost