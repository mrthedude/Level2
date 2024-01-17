// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {Vm} from "forge-std/Vm.sol";
import {tokenLendingScript} from "../script/tokenLendingDeployment.s.sol";
import {HelperConfig} from "../script/HelperConfig.s.sol";
import {tokenLending} from "../src/tokenLending.sol";
import {token} from "../src/token.sol";
import {StdCheats} from "forge-std/StdCheats.sol";

contract testToken is Test, tokenLendingScript {
    tokenLending lendingContract;
    token myToken;
    uint256 public constant STARTING_USER_BALANCE = 10 ether;
    address public constant USER = address(1);

    function setUp() public {
        tokenLendingScript deployerContract = new tokenLendingScript();
        lendingContract = deployerContract.run();
        vm.deal(USER, STARTING_USER_BALANCE);
    }

    ///////////// Testing Deployment and Token /////////////
    function testIfOwnerAddressIsCorrect() public {
        assertEq(lendingContract.getOwnerAddress(), 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266);
    }

    function testOwnerHasCorrectTokens() public {
        address owner = lendingContract.getOwnerAddress();
        myToken = token(lendingContract.getTokenAddress());
        assertEq(myToken.balanceOf(owner), 100 ether);
    }

    ///////////// Testing depositToken /////////////
    function testRevert_WhenDepositIsZero() public {
        address owner = lendingContract.getOwnerAddress();
        myToken = token(lendingContract.getTokenAddress());
        vm.startPrank(owner);
        vm.expectRevert(tokenLending.cannotBeZero.selector);
        lendingContract.depositToken(0);
    }

    function testContractBalanceIncreases() public {
        address owner = lendingContract.getOwnerAddress();
        myToken = token(lendingContract.getTokenAddress());
        vm.startPrank(owner);
        myToken.approve(address(lendingContract), 10e18);
        lendingContract.depositToken(10e18);
        vm.stopPrank();
        assertEq(myToken.balanceOf(owner), 90e18);
        assertEq(myToken.balanceOf(address(lendingContract)), 10e18);
    }

    function testDepositMappingIncreases() public {
        address owner = lendingContract.getOwnerAddress();
        myToken = token(lendingContract.getTokenAddress());
        vm.startPrank(owner);
        myToken.approve(address(lendingContract), 10e18);
        lendingContract.depositToken(10e18);
        assertEq(lendingContract.getDepositBalance(), 10e18);
        vm.stopPrank();
    }

    ///////////// Testing withdrawToken /////////////
    function testRevert_whenWithdrawIsZero() public {
        address owner = lendingContract.getOwnerAddress();
        myToken = token(lendingContract.getTokenAddress());
        vm.startPrank(owner);
        myToken.approve(address(lendingContract), 10e18);
        lendingContract.depositToken(10e18);
        vm.expectRevert(tokenLending.cannotBeZero.selector);
        lendingContract.withdrawToken(0);
        vm.stopPrank();
    }

    function testRevert_whenWithdrawlIsMoreThanDeposit() public {
        address owner = lendingContract.getOwnerAddress();
        myToken = token(lendingContract.getTokenAddress());
        vm.startPrank(owner);
        myToken.approve(owner, 10e18);
        myToken.transferFrom(owner, USER, 10e18);
        myToken.approve(address(lendingContract), 10e18);
        lendingContract.depositToken(10e18);
        vm.stopPrank();
        vm.startPrank(USER);
        myToken.approve(address(lendingContract), 10e18);
        lendingContract.depositToken(10e18);
        vm.stopPrank();
        vm.startPrank(owner);
        vm.expectRevert(tokenLending.cannotWithdrawMoreThanDeposited.selector);
        lendingContract.withdrawToken(11e18);
        vm.stopPrank();
    }

    function testRevert_whenTryingToWithdrawWithBorrowPosition() public {}

    function testTokensAreTransferredToCallerAfterWithdraw() public {
        address owner = lendingContract.getOwnerAddress();
        myToken = token(lendingContract.getTokenAddress());
        vm.startPrank(owner);
        myToken.approve(address(lendingContract), 10e18);
        lendingContract.depositToken(10e18);
        lendingContract.withdrawToken(10e18);
        vm.stopPrank();
        assertEq(myToken.balanceOf(owner), 100e18);
    }

    function testDepositBalanceReducesByWithdrawAmount() public {
        address owner = lendingContract.getOwnerAddress();
        myToken = token(lendingContract.getTokenAddress());
        vm.startPrank(owner);
        myToken.approve(address(lendingContract), 10e18);
        lendingContract.depositToken(10e18);
        lendingContract.withdrawToken(10e18);
        assertEq(lendingContract.getDepositBalance(), 0);
        vm.stopPrank();
    }

    ///////////// Testing borrowToken /////////////
    function testRever_ifBorrowAmountIsZero() public {
        address owner = lendingContract.getOwnerAddress();
        myToken = token(lendingContract.getTokenAddress());
        vm.startPrank(owner);
        myToken.approve(address(lendingContract), 10e18);
        lendingContract.depositToken(10e18);
        vm.expectRevert(tokenLending.cannotBeZero.selector);
        lendingContract.borrowToken(0);
        vm.stopPrank();
    }

    function testRevert_whenBorrowExceedsMaxCollateralRatio() public {
        address owner = lendingContract.getOwnerAddress();
        myToken = token(lendingContract.getTokenAddress());
        vm.startPrank(owner);
        myToken.approve(address(lendingContract), 10e18);
        lendingContract.depositToken(10e18);
        vm.expectRevert(tokenLending.cannotExceedMaximumCollateralRatio.selector);
        lendingContract.borrowToken(7.6e18);
        vm.stopPrank();
    }
}
