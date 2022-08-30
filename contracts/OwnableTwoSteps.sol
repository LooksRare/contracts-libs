// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import {IOwnableTwoSteps} from "./interfaces/IOwnableTwoSteps.sol";

/**
 * @title OwnableTwoSteps
 * @notice This contract offers transfer of ownership in two steps with potential owner having to confirm the transaction.
 *         Renouncement of the ownership is also a two-step process with a timelock since the next potential owner is address(0).
 */
abstract contract OwnableTwoSteps is IOwnableTwoSteps {
    // Address of the current owner
    address private _owner;

    // Address of the potential owner
    address private _potentialOwner;

    // Earliest ownership renouncement timestamp
    uint256 private _earliestOwnershipRenouncementTime;

    // Ownership status
    Status public status;

    // Current delay for the timelock (in seconds)
    uint256 public delay;

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
     * @notice Initial owner is the deployment address while initial delay (for the timelock) must be set by contract that inherit from this.
     */
    constructor() {
        _owner = msg.sender;
    }

    /**
     * @notice Cancel transfer of ownership
     * @dev This function can be used for both cancelling a transfer to a new owner and
     *      cancelling the renouncement of the ownership.
     */
    function cancelOwnershipTransfer() external onlyOwner {
        if (status == Status.NoOngoingTransfer) revert NoOngoingTransferInProgress();

        if (status == Status.TransferInProgress) {
            delete _potentialOwner;
        } else if (status == Status.RenouncementInProgress) {
            delete _earliestOwnershipRenouncementTime;
        }

        delete status;

        emit CancelOwnershipTransfer();
    }

    /**
     * @notice Confirm ownership renouncement
     */
    function confirmOwnershipRenouncement() external onlyOwner {
        if (status != Status.RenouncementInProgress) revert RenouncementNotInProgress();
        if (block.timestamp < _earliestOwnershipRenouncementTime) revert RenouncementTooEarly();

        delete _earliestOwnershipRenouncementTime;
        delete _owner;
        delete status;

        emit NewOwner(address(0));
    }

    /**
     * @notice Confirm ownership transfer
     * @dev This function can only be called by the current potential owner.
     */
    function confirmOwnershipTransfer() external {
        if (status != Status.TransferInProgress) revert TransferNotInProgress();
        if (msg.sender != _potentialOwner) revert WrongPotentialOwner();

        _owner = msg.sender;
        delete status;
        delete _potentialOwner;

        emit NewOwner(_owner);
    }

    /**
     * @notice Initiate transfer of ownership to a new owner
     * @param newPotentialOwner address of the new potential owner
     */
    function initiateOwnershipTransfer(address newPotentialOwner) external onlyOwner {
        if (status != Status.NoOngoingTransfer) revert TransferAlreadyInProgress();

        status = Status.TransferInProgress;
        _potentialOwner = newPotentialOwner;

        emit InitiateOwnershipTransfer(_owner, newPotentialOwner);
    }

    /**
     * @notice Initiate ownership renouncement
     */
    function initiateOwnershipRenouncement() external onlyOwner {
        if (status != Status.NoOngoingTransfer) revert TransferAlreadyInProgress();

        status = Status.RenouncementInProgress;
        _earliestOwnershipRenouncementTime = block.timestamp + delay;

        emit InitiateOwnershipRenouncement();
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

    /**
     * @notice Returns the earliest timestamp after which the ownership renouncement
     *         can be confirmed by the current owner.
     * @return earliest timestamp for renouncement confirmation
     */
    function earliestOwnershipRenouncementTime() external view returns (uint256) {
        return _earliestOwnershipRenouncementTime;
    }

    /**
     * @notice Set up the timelock delay for renouncing ownership
     * @param _delay timelock delay for the owner to confirm renouncing the ownership
     * @dev This function is expected to be included in the constructor of the contract that inherits this contract.
     */
    function _setupDelayForRenouncingOwnership(uint256 _delay) internal {
        delay = _delay;
    }
}
