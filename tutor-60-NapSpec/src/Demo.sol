// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

error NotAnOwner(address caller);
//коментарі NapSpec для контрактів
///@title Demo contract from YouTube
///@author of Youtube channel Kruk & author of this test Serhie
///@notice a simple wallet (demo)
///@dev special info

contract Demo {

    //коментарі для змінних 
    ///@notice The current owner of this contract
    ///@dev cannot be address(0)
    ///@return The owner
    address public owner;
    uint public lastDepositAt;
    uint public constant DELAY = 120;


    /// @notice Emitted when funds are received
    /// @param amount Deposited amount
    /// @param sender  actual senderц

    //Багатострокові коментарі зірочки
    /**
     * @notice Emitted when funds are received
     * @param amount Deposited amount
     * @param sender  actual sender
     */ 
    event Deposited(uint indexed amount, address indexed sender);

    modifier onlyOwner() {
    if(msg.sender != owner) revert NotAnOwner(msg.sender);
    _;
    }

    constructor(){
        owner = msg.sender;
    }


    ///@notice Deposit funds to the wallet
    function deposit() public payable {
        require(msg.value > 0 , "nothing has been deposited!");
        lastDepositAt = block.timestamp;

        emit Deposited(msg.value, msg.sender);
    }

    /// @notice withdraw money from the wallet
    /// @param _amount The amount to withdraw 
    function withdraw(uint _amount) external onlyOwner {
        require(block.timestamp > lastDepositAt + DELAY, "too early!");
        payable(msg.sender).transfer(_amount);
    }

    /// @notice Do some calculation
    /// @param _a Value 1 
    /// @param _b Value 2
    ///@return The result of calculations
    function calculate(uint _a, uint _b) external returns(uint){
        //...
    }


    /// @notice This foo is private and its will not be writed
    /// @param _c The input param
     function secretFoo(uint _c) private {
        //...
    }

    // ///@notice If fu taked from above contract you can use inheritdoc
    // ///@param _x  The input param
    // ///@inheritdoc Parent name
    //  function someInternaFoo(uint _x) internal {
    //     //...
    // }


    ///@custom:sample тут ми пишемо що завгодно
    receive() external payable {
        deposit();
    }
}
