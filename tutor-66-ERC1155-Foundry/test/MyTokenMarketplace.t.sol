// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;


import {Test, console} from "../lib/forge-std/src/Test.sol";
import { MyToken } from "../src/MyToken.sol";
import { MyTokenMarketplace } from "../src/MyTokenMarketplace.sol";
import { IERC721Receiver } from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

contract MyNFTMarketplaceTest is Test, IERC721Receiver  {


    MyToken token;
    MyTokenMarketplace shop;
    address alice = makeAddr("alice");
    address bob = makeAddr("bob");
    address joe = makeAddr("joe");
    address self;

    uint256[] tokenIds = [0,1,2];
    uint256[] amounts = [5,10,15];
    uint256[] prices = [45,58,100];

    function setUp() public {
        token = new MyToken();
        shop = new MyTokenMarketplace(address(token));
        self = address(this);

        populateShop();
        }


    function testAddTokens()external view{
        uint256 id0 = tokenIds[0];
        uint256 id1 = tokenIds[1];
        uint256 id2 = tokenIds[2];

        assertEq(shop.availableTokenIds(0), id0);
        assertEq(shop.availableTokenIds(1), id2);
        assertEq(shop.availableTokenIds(2), id1);

        assertEq(shop.availableAmount(id0), amounts[0]);
        assertEq(shop.availableAmount(id1), amounts[1]);
        assertEq(shop.availableAmount(id2), amounts[2] * 2);

        assertEq(shop.canBePurchasedFrom(id0, 0), alice);
        assertEq(shop.canBePurchasedFrom(id1, 0), bob);
        assertEq(shop.canBePurchasedFrom(id2, 0), alice);
        assertEq(shop.canBePurchasedFrom(id2, 1), bob);
    }


    function testBySingle()external {
        uint256 id0 = tokenIds[0];

        uint256[] memory idsSingle = new uint[](1);
        idsSingle[0] = id0;

        uint256[] memory amountsSingle = new uint[](1);
        amountsSingle[0] = 4;
        uint256 price = 180;
        hoax(joe);
        shop.buy{value: price}(idsSingle, amountsSingle);
        assertEq(token.balanceOf(joe, id0), amountsSingle[0]);
        assertEq(shop.tokensInStock(id0), amounts[0] - amountsSingle[0]);
        assertEq(shop.canBePurchasedFrom(id0, 0), alice);
        (uint256 currentAmount, ) = shop.ownedTokens(alice, id0);
        assertEq(currentAmount, amounts[0] - amountsSingle[0]);
    }

    function testTotalPrice()external view{
        uint256[] memory idsSingle = new uint[](1);
        idsSingle[0] = tokenIds[0];

        uint256[] memory amountsSingle = new uint[](1);
        amountsSingle[0] = 4;

        assertEq(shop.totalPrice(idsSingle, amountsSingle), amountsSingle[0] * prices[0]);

        uint256[] memory idsMult = new uint[](2);
        idsMult[0] = tokenIds[0];
        idsMult[1] = tokenIds[2];
        
        uint256[] memory amountsMult = new uint[](2);
        amountsMult[0] = 4;
        amountsMult[1] = 20;

        assertEq(shop.totalPrice(idsMult, amountsMult), 2180);
    }

    function testBuyMultiply()external{
        uint256 id0 = tokenIds[0];
        uint256 id2 = tokenIds[2];

        uint256[] memory idsMult = new uint[](2);
        idsMult[0] = tokenIds[0];
        idsMult[1] = tokenIds[2];

        uint256[] memory amountsMult = new uint[](2);
        amountsMult[0] = 5;
        amountsMult[1] = 20;


        ///@notice total price for all tokens 5 * 45 + 20 + 100 
        ///(ціна за пеший токен з індексом 0 виставлена 45 аліс та ціна на токен з індексом 2 виставлена 100 єліс та бобом)
        uint256 price = 2225;

        hoax(joe);
        shop.buy{value: price}(idsMult, amountsMult);
        assertEq(token.balanceOf(joe, id0), amountsMult[0]);
        assertEq(token.balanceOf(joe, id2), amountsMult[1]);

        assertEq(shop.availableAmount(id0),0);
        assertFalse(shop.anyOwner(id0));
        (uint256 currentAmount0,) = shop.ownedTokens(alice, id0);
        
        assertEq(currentAmount0, 0);
        assertEq(shop.availableAmount(id2), 10);
        assertTrue(shop.anyOwner(id2));
        assertEq(shop.canBePurchasedFrom(id2,0), bob);
        (uint256 currentAmountAlice2,) = shop.ownedTokens(alice, id2);
        assertEq(currentAmountAlice2, 0);
        (uint256 currentAmountBob2,) = shop.ownedTokens(bob, id2);
        assertEq(currentAmountBob2, 10);
    }

    function populateShop() private {
        token.mintBatch(alice, tokenIds, amounts, "");
        token.mintBatch(bob, tokenIds, amounts, "");
        // token.mintBatch(joe, tokenIds, amounts, "");

        uint256[] memory aliceIds = new uint256[](2);
        uint256[] memory aliceAmounts = new uint256[](2);
        uint256[] memory alicePrices = new uint256[](2);
        aliceIds[0] = tokenIds[0];
        aliceIds[1] = tokenIds[2];
        aliceAmounts[0] = amounts[0];
        aliceAmounts[1] = amounts[2];
        alicePrices[0] = prices[0];
        alicePrices[1] = prices[2];

        vm.prank(alice);
        token.setApprovalForAll(address(shop), true);
        vm.prank(alice);
        shop.addTokens(aliceIds, aliceAmounts, alicePrices);

        uint256[] memory bobIds = new uint256[](2);
        uint256[] memory bobAmounts = new uint256[](2);
        uint256[] memory bobPrices = new uint256[](2);
        bobIds[0] = tokenIds[1];
        bobIds[1] = tokenIds[2];
        bobAmounts[0] = amounts[1];
        bobAmounts[1] = amounts[2];
        bobPrices[0] = prices[1];
        bobPrices[1] = prices[2];

        vm.prank(bob);
        token.setApprovalForAll(address(shop), true);
        vm.prank(bob);
        shop.addTokens(bobIds, bobAmounts, bobPrices);


        // vm.prank(joe);
        // token.setApprovalForAll(address(shop), true);
        // vm.prank(joe);
        // shop.addTokens(tokenIds, amounts, prices);
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
