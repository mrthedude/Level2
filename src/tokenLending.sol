// Layout of Contract:
// version
// imports
// interfaces, libraries, contracts
// errors
// Type declarations
// State variables
// Events
// Modifiers
// Functions

// Layout of Functions:
// constructor
// receive function (if exists)
// fallback function (if exists)
// external
// public
// internal
// private
// view & pure functions

// SPDX-License-Identifier: MIT
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

pragma solidity ^0.8.19;

/**
 * @title tokenLending
 * @notice A contract for lending ERC20 tokens with deposit, withdrawal, borrowing, and repayment functionalities.
 */
contract tokenLending {
    using SafeERC20 for IERC20;

    error cannotBeZero();
    error cannotWithdrawMoreThanDeposited();
    error cannotWithdrawWithAnOpenBorrowingPosition();
    error cannotExceedMaximumCollateralRatio();
    error cannotRepayMoreThanBorrowedAmount();
    error contractCalledWithIncompatibleData();
    error onlyTheOwnerCanCallThisFunction();
    error noEtherInContract();
    error transferFundsFailed();

    /**
     * @notice Number representing the maximum collateral ratio a user can withdraw up to
     * @dev Used in the borrow() function to set the upper limit of how much a user can borrow
     */
    uint256 private constant MAXIMUMCOLLATERALRATIO = 0.75e18;

    /**
     * @notice Variable that restricts access to certain functions
     * @dev Used only in the transferFunds function
     */
    address private _owner;

    /**
     * @notice Mapping of user addresses to their token balances in the contract.
     */
    mapping(address user => uint256 balance) private _depositBalance;

    /**
     * @notice Mapping of user addresses to the amount of tokens they have borrowed.
     */
    mapping(address user => uint256 balance) private _borrowBalance;

    /**
     * @notice The ERC20 token that this contract facilitates lending for.
     */
    IERC20 internal immutable i_token;

    event Received(address indexed sender, uint256 indexed value);
    event TransferredFundsToOwner();

    /**
     * @notice Function that restricts access to certain functions
     * @dev Used only in the transferFunds function
     */
    modifier onlyOwner() {
        if (msg.sender != _owner) {
            revert onlyTheOwnerCanCallThisFunction();
        }
        _;
    }

    /**
     * @notice restricts what values are accepted by certain functions
     * @param amount Checks if the function parameter is 0
     */
    modifier amountCannotBeZero(uint256 amount) {
        if (amount == 0) {
            revert cannotBeZero();
        }
        _;
    }

    /**
     * @notice Creates a new TokenLending contract.
     * @dev Sets the token that will be used for lending and the owner of the contract.
     * @param tokenAddress The address of the ERC20 token contract.
     */
    constructor(address tokenAddress, address contractOwner) {
        i_token = IERC20(tokenAddress);
        _owner = payable(contractOwner);
    }

    /**
     * @notice Fallback function called when Ether is sent to the contract with no calldata
     * @notice Emits an event when msg.value is sent to the contract
     */
    receive() external payable {
        emit Received(msg.sender, msg.value);
    }

    /**
     * @notice A function that is automatically called whenever a contract receives a message that is not handled by any of the contract's other functions
     */
    fallback() external {
        revert contractCalledWithIncompatibleData();
    }

    /**
     * @notice Allows a user to deposit tokens into the contract.
     * @dev Transfers tokens from the sender to the contract and updates the sender's balance.
     * @param amount The amount of tokens to deposit.
     */
    function depositToken(uint256 amount) external amountCannotBeZero(amount) {
        i_token.safeTransferFrom(msg.sender, address(this), amount);
        _depositBalance[msg.sender] += amount;
    }

    /**
     * @notice Allows a user to withdraw tokens from their balance in the contract.
     * @dev Subtracts the withdrawn amount from the sender's balance and transfers the tokens.
     * @param amount The amount of tokens to withdraw.
     */
    function withdrawToken(uint256 amount) external amountCannotBeZero(amount) {
        if (_depositBalance[msg.sender] < amount) {
            revert cannotWithdrawMoreThanDeposited();
        }
        if (_borrowBalance[msg.sender] != 0) {
            revert cannotWithdrawWithAnOpenBorrowingPosition();
        }

        i_token.safeTransfer(msg.sender, amount);
        _depositBalance[msg.sender] -= amount;
    }

    /**
     * @notice Allows a user to borrow tokens from the contract up to the maximum collateral ratio.
     * @dev Transfers the requested amount of tokens to the sender if the contract has sufficient balance.
     * @param amount The amount of tokens to borrow.
     */
    function borrowToken(uint256 amount) external amountCannotBeZero(amount) {
        if ((_borrowBalance[msg.sender] + amount) * 1e18 / _depositBalance[msg.sender] > MAXIMUMCOLLATERALRATIO) {
            revert cannotExceedMaximumCollateralRatio();
        }

        _borrowBalance[msg.sender] += amount;
        i_token.safeTransfer(msg.sender, amount);
    }

    /**
     * @notice Allows a user to repay borrowed tokens to the contract.
     * @dev Subtracts the repaid amount from the sender's borrowed balance and transfers the tokens to the contract.
     * @param amount The amount of tokens to repay.
     */
    function repayToken(uint256 amount) external amountCannotBeZero(amount) {
        if (_borrowBalance[msg.sender] < amount) {
            revert cannotRepayMoreThanBorrowedAmount();
        }

        i_token.safeTransferFrom(msg.sender, address(this), amount);
        _borrowBalance[msg.sender] -= amount;
    }

    /**
     * @notice Function used to transfer any Ether in the contract to the owner then emits an event
     */
    function transferFunds() external onlyOwner {
        if (address(this).balance == 0) {
            revert noEtherInContract();
        }

        (bool transferred,) = payable(msg.sender).call{value: address(this).balance}("mi familia");
        if (!transferred) {
            revert transferFundsFailed();
        }
        emit TransferredFundsToOwner();
    }

    /**
     * @notice Getter functions for contract variables and data
     */
    function getTokenAddress() public view returns (address tokenAddress) {
        tokenAddress = address(i_token);
    }

    function getOwnerAddress() public view returns (address ownerAddress) {
        ownerAddress = address(_owner);
    }

    function getDepositBalance(address user) public view returns (uint256 depositBalance) {
        depositBalance = _depositBalance[user];
    }

    function getBorrowBalance(address user) public view returns (uint256 borrowBalance) {
        borrowBalance = _borrowBalance[user];
    }
}
