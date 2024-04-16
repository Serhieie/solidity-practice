// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script, console} from "../lib/forge-std/src/Script.sol";
import "../src/MyToken.sol";

// forge script script/MyToken.s.sol:MTKDeploy --fork-url http://localhost:8545 --broadcast
contract MTKDeploy is Script {


    function run() external {   
        uint deployerPrivatKey = vm.envUint("PRIVATE_KEY");
        address to = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
        uint amount = 5;

        ///@notice броадкаст приймає приватний ключ і далі всі виклики будуть від нього
        vm.startBroadcast(deployerPrivatKey);

        MyToken token = new MyToken(100);
        token.transfer(to, amount * 10 ** token.decimals());

        vm.stopBroadcast();
         
    }
}