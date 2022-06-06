// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

/**
 * @title OwnableTwoSteps
 * @notice This contract offers transfer of ownership in two steps.
 * @dev It is currently not possible to renounce ownership.
 */
contract OwnableTwoSteps {
    // Address of the current owner
    address private _owner;

    // Address of the potential owner
    address private _potentialOwner;

    // Custom errors
    error NoPotentialOwner();
    error NotOwner();
    error TransferAlreadyInProgress();
    error WrongPotentialOwner();

    // Events
    event CancelOwnershipTransfer(address previousPotentialOwner);
    event InitiateOwnershipTransfer(address previousOwner, address potentialOwner);
    event NewOwner(address newOwner);

    /**
     * @notice Modifier to wrap functions for contracts that inherit this contract
     */
    modifier onlyOwner() {
        if (msg.sender != _owner) {
            revert NotOwner();
        }
        _;
    }

    /**
     * @notice Constructor
     */
    constructor() {
        _owner = msg.sender;
    }

    /**
     * @notice Cancel transfer of ownership
     */
    function cancelOwnershipTransfer() external onlyOwner {
        address previousPotentialOwner = _potentialOwner;

        if (previousPotentialOwner == address(0)) {
            revert NoPotentialOwner();
        }

        _potentialOwner = address(0);

        emit CancelOwnershipTransfer(previousPotentialOwner);
    }

    /**
     * @notice Confirm ownership transfer
     * @dev It can only be called by the current potential owner
     */
    function confirmOwnershipTransfer() external {
        if (msg.sender != _potentialOwner) {
            revert WrongPotentialOwner();
        }

        _owner = msg.sender;
        _potentialOwner = address(0);

        emit NewOwner(msg.sender);
    }

    /**
     * @notice Initiate transfer of ownership to a new owner
     * @param newPotentialOwner address of the potential owner
     */
    function initiateOwnershipTransfer(address newPotentialOwner) external onlyOwner {
        if (_potentialOwner != address(0)) {
            revert TransferAlreadyInProgress();
        }

        _potentialOwner = newPotentialOwner;

        emit InitiateOwnershipTransfer(_owner, newPotentialOwner);
    }

    /**
     * @notice Returns owner address
     * @return owner address
     */
    function owner() external view returns (address) {
        return _owner;
    }

    /**
     * @notice Returns potential owner address
     * @return potential owner address
     */
    function potentialOwner() external view returns (address) {
        return _potentialOwner;
    }
}
