// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

/**
 * @title ReentrancyGuard
 * @notice This contract protects against reentrancy attacks.
 * It is adjusted from OpenZeppelin.
 */
abstract contract ReentrancyGuard {
    uint256 private _status;

    error ReentrancyFail();

    constructor() {
        _status = 1;
    }

    /**
     * @notice Modifier to wrap functions to prevent reentrancy calls
     */
    modifier nonReentrant() {
        if (_status == 2) {
            revert ReentrancyFail();
        }

        _status = 2;
        _;
        _status = 1;
    }
}
