// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;


import {Test, console} from "../lib/forge-std/src/Test.sol";
import { MyNFT } from "../src/MyNFT.sol";
import { Strings } from "../src/Strings.sol";
import { IERC721Receiver } from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

contract MyNFTTest is Test, IERC721Receiver  {
    using  Strings for uint256;

    MyNFT token;
    address alice = makeAddr("alice");
    address bob = makeAddr("bob");
    address self;

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId );

    function setUp() public {
        token = new MyNFT();
        self = address(this);
    }

    function testMyNFTName() external view {
        assertEq(token.name(), "MyNFT");
    }

    function testSafeMint() external  {
        uint tokenId = 1;

        vm.expectEmit(true,true,true,false, address(token));

        emit Transfer(address(0), self, tokenId);

        token.safeMint(self);

        assertEq(token.balanceOf(self), 1);
        assertEq(token.tokenURI(tokenId), fullUriTo(tokenId));
    }

    function safeTransferFrom()external{
        uint tokenId = 1;

        token.safeMint(self);
        token.approve(bob, tokenId);

        //наступний виклик зробить боб
        vm.prank(bob);
        token.transferFrom(self,alice,tokenId);

        assertEq(token.balanceOf(self), 0);
        assertEq(token.ownerOf(tokenId), alice);
    }


    function testBurnMNFT() external {
         uint tokenId = 1;

        token.safeMint(self);

        assertEq(token.balanceOf(self), 1);

        token.burn(tokenId);

        assertEq(token.balanceOf(self), 0);
    }

    function fullUriTo(uint256 tokenId) private pure returns(string memory){
        return string.concat(
            "https://example-of-your-site/nfts", tokenId.toString(), ".jpg"
        );
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
