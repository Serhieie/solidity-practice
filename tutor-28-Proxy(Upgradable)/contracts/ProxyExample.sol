// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

// Uncomment this line to use console.log
// import "hardhat/console.sol";

contract Proxy {
    uint public x;
    address public inmplementation;


//onlyOwner
    function setImplementation(address _imp) external{
        inmplementation =_imp;
    }


    function _delegate(address _imp) internal virtual {
                assembly {
  // (1) copy incoming call data
  calldatacopy(0, 0, calldatasize())

  // (2) forward call to logic contract
  let result := delegatecall(gas(), _imp, 0, calldatasize(), 0, 0)

  // (3) retrieve return data
  returndatacopy(0, 0, returndatasize())

  // (4) forward return data back to caller
  switch result
  case 0 {
      revert(0, returndatasize())
  }
  default {
      return(0, returndatasize())
        }
    }
}

    fallback() external payable {
        _delegate(inmplementation);
    }

    receive() external payable {}

}


contract V1 {
    address public inmplementation;
    uint public x;

    function inc()external {
        x += 1;
    }

    function enc() external pure returns(bytes memory){
        return abi.encodeWithSelector(this.inc.selector);
    }
    function encX() external pure returns(bytes memory){
        return abi.encodeWithSelector(this.x.selector);
    }
}