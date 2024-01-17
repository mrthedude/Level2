// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {tokenLending} from "../src/tokenLending.sol";
import {token} from "../src/token.sol";
import {HelperConfig} from "../script/HelperConfig.s.sol";

contract tokenDeployer is Script {
    HelperConfig helperConfig = new HelperConfig();
    address addi = helperConfig.getOwnerAddress();

    function runToken() public returns (token) {
        token myToken = new token(addi);
        return myToken;
    }
}

contract tokenLendingScript is Script, tokenDeployer {
    function run() public returns (tokenLending) {
        HelperConfig helperConfig = new HelperConfig();
        address addi = helperConfig.getOwnerAddress();
        tokenDeployer deployToken = new tokenDeployer();
        vm.startBroadcast();

        tokenLending lendingContract = new tokenLending(address(deployToken.runToken()), addi);

        vm.stopBroadcast();
        return lendingContract;
    }
}
