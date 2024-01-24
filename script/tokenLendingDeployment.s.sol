// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {tokenLending} from "../src/tokenLending.sol";
import {token} from "../src/token.sol";
import {HelperConfig} from "../script/HelperConfig.s.sol";

contract tokenDeployer is Script {
    HelperConfig helperConfig = new HelperConfig();
    address ownerAddi = helperConfig.getOwnerAddress();

    function run() public returns (token) {
        vm.startBroadcast();
        token myToken = new token(ownerAddi);
        vm.stopBroadcast();
        return myToken;
    }
}

contract tokenLendingScript is Script {
    function run() public returns (tokenLending) {
        HelperConfig helperConfig = new HelperConfig();
        address ownerAddress = helperConfig.getOwnerAddress();
        address tokenAddress = 0x1780F615532d0ceA1FBc0Add91d7B9954073BaC6;
        vm.startBroadcast();
        tokenLending lendingContract = new tokenLending(tokenAddress, ownerAddress);
        vm.stopBroadcast();
        return lendingContract;
    }
}

contract testTokenLendingScript is Script, tokenDeployer {
    function testRun() public returns (tokenLending) {
        HelperConfig helperConfig = new HelperConfig();
        address ownerAddress = helperConfig.getOwnerAddress();
        tokenDeployer tokenScript = new tokenDeployer();
        tokenLending lendingContract = new tokenLending(address(tokenScript.run()), ownerAddress);
        return lendingContract;
    }
}
