// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;


import {Test, console} from "../lib/forge-std/src/Test.sol";
import { MyNFT } from "../src/MyNFT.sol";
import { MyNFTMarketplace, NFTAdded } from "../src/MyNFTMarketplace.sol";
import { Strings } from "../src/Strings.sol";
import { IERC721Receiver } from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

contract MyNFTMarketplaceTest is Test, IERC721Receiver  {
    using  Strings for uint256;

    MyNFT nft;
    MyNFTMarketplace shop;

    address alice = makeAddr("alice");
    address bob = makeAddr("bob");
    

    function setUp() public {
        nft = new MyNFT();
        shop = new MyNFTMarketplace(address(nft));

        nft.safeMint(alice);
    }

    function testMyNFTName() external view {
        assertEq(nft.name(), "MyNFT");
    }

    function testCanAddMyNFT() external {
        uint tokenId = 1;
        uint price = 1 ether;

        vm.prank(alice);
        nft.approve(address(shop), tokenId);
        vm.prank(alice);
        shop.add(tokenId, price);

        assertEq(nft.balanceOf(address(alice)), 1);
        assertEq(shop.items(tokenId), 1 ether);
        assertEq(shop.owners(tokenId), address(alice));
    }

    function testCanRemoveMyNFT() external {
        uint tokenId = 1;
        uint price = 1 ether;

        vm.prank(alice);
        nft.approve(address(shop), tokenId);
        vm.prank(alice);
        shop.add(tokenId, price);

        assertEq(shop.items(tokenId), 1 ether);
        assertEq(shop.owners(tokenId), address(alice));

        vm.prank(alice);
        nft.approve(address(0), tokenId);
        vm.prank(alice);
        shop.removeMyNFT(tokenId);

        assertEq(shop.items(tokenId), 0);
        assertEq(shop.owners(tokenId), address(0));
        assertEq(nft.getApproved(tokenId), address(0));

        vm.expectRevert();
        shop.buy(tokenId);
        
    }

    function testCanBuyMyNFT() external { 
        uint tokenId = 1;
        uint price = 1 ether;
        uint earnEth =  price - (price * 5) / 100;


        vm.prank(alice);
        nft.approve(address(shop), tokenId);
        vm.prank(alice);

        shop.add(tokenId, price);

        hoax(bob);
        shop.buy{value: price}(tokenId);

        assertEq(nft.balanceOf(address(alice)), 0);
        assertEq(nft.balanceOf(address(bob)), 1);
        assertEq(nft.ownerOf(tokenId), address(bob));
        assertEq(shop.owners(tokenId), address(0));
        assertEq(shop.items(tokenId), 0);
        assertEq(alice.balance, earnEth);

        vm.expectRevert();
        shop.buy(tokenId); 
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
