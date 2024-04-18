// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script, console} from "../lib/forge-std/src/Script.sol";
import {MyNFT} from "../src/MyNFT.sol";

// forge script script/MyNFT.s.sol:MNFTDeploy --fork-url http://localhost:8545 --broadcast
contract MNFTDeploy is Script {
    function run() external {   
        uint deployerPrivatKey = vm.envUint("PRIVATE_KEY");
        address to = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
        address toMe = 0x046F99c7B5ab3bF7aF41063E64F679A40b2e4B08;

        ///@notice броадкаст приймає приватний ключ і далі всі виклики будуть від нього
        vm.startBroadcast(deployerPrivatKey);

        MyNFT token = new MyNFT();
        token.safeMint(to);
        token.safeMint(toMe);

        payable(to).transfer(1 ether);
        payable(toMe).transfer(1 ether);

        vm.stopBroadcast();
         
    }
}