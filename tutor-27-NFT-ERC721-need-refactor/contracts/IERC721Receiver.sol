// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./IERC721.sol";

interface IERC721Receiver {
    function onERC721Received(
        address operator,
        address from,
        uint tokenId,
        bytes calldata data
    ) external returns(bytes4);
}