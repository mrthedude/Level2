// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {tokenLending} from "../src/tokenLending.sol";
import {token} from "../src/token.sol";
import {HelperConfig} from "../script/HelperConfig.s.sol";

contract tokenLendingScript is Script {
    function run() public returns (token, tokenLending) {
        HelperConfig helperConfig = new HelperConfig();
        address addi = helperConfig.getOwnerAddress();
        vm.startBroadcast();

        token myToken = new token();
        tokenLending lendingContract = new tokenLending(address(myToken), addi);

        vm.stopBroadcast();
        return (myToken, lendingContract);
    }
}
