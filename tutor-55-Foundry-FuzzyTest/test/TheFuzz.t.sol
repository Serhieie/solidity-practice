// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "../lib/forge-std/src/Test.sol";
import "../src/TheFuzz.sol";

contract TheFuzzTest is Test {
    TheFuzz public fuzz;

    function setUp() public {
        fuzz = new TheFuzz();
    }

    // forge-config: default.fuzz.runs = 100
    // forge-config: default.fuzz.max-test-rejects = 2
    function testFuzzCallMe(address _to, uint _nonce, uint _value) public  {
        vm.assume(_to != address(0));
        // vm.assume(_nonce != 0);
        // vm.assume(_nonce > 0 && _nonce <= 100); 
        _nonce = bound(_nonce, 1, 100);

        bytes memory expectedResult = abi.encode(
            uint256(uint160(_to)),
            _nonce
        );

        bytes memory result = fuzz.callMe{value: _value}(_to, _nonce);

        assertEq(result, expectedResult);
    }
}