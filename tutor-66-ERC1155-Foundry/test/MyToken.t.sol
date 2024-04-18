// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;


import {Test, console} from "../lib/forge-std/src/Test.sol";
import { MyToken } from "../src/MyToken.sol";
import { Strings } from "../src/Strings.sol";
import { IERC721Receiver } from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

contract MyNFTTest is Test, IERC721Receiver  {
    using  Strings for uint256;

    MyToken token;
    address alice = makeAddr("alice");
    address bob = makeAddr("bob");
    address self;

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId );

    function setUp() public {
        token = new MyToken();
        self = address(this);
    }


    function onERC721Received(
        address ,
        address ,
        uint256 ,
        bytes calldata 
    ) external pure returns (bytes4){
        return IERC721Receiver.onERC721Received.selector;
    }

}
