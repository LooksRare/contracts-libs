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
    address public owner;

    // Address of the potential owner
    address public potentialOwner;

    // Ownership status
    Status public ownershipStatus;

    /**
     * @notice Modifier to wrap functions for contracts that inherit this contract
     */
    modifier onlyOwner() {
        if (msg.sender != owner) {
            revert NotOwner();
        }
        _;
    }

    /**
     * @notice Constructor
     *         Initial owner is the deployment address.
     */
    constructor() {
        owner = msg.sender;
    }

    /**
     * @notice Cancel transfer of ownership
     * @dev This function can be used for both cancelling a transfer to a new owner and
     *      cancelling the renouncement of the ownership.
     */
    function cancelOwnershipTransfer() external onlyOwner {
        Status _ownershipStatus = ownershipStatus;
        if (_ownershipStatus == Status.NoOngoingTransfer) revert NoOngoingTransferInProgress();

        if (_ownershipStatus == Status.TransferInProgress) {
            delete potentialOwner;
        }

        delete ownershipStatus;

        emit CancelOwnershipTransfer();
    }

    /**
     * @notice Confirm ownership renouncement
     */
    function confirmOwnershipRenouncement() external onlyOwner {
        if (ownershipStatus != Status.RenouncementInProgress) revert RenouncementNotInProgress();

        delete owner;
        delete ownershipStatus;

        emit NewOwner(address(0));
    }

    /**
     * @notice Confirm ownership transfer
     * @dev This function can only be called by the current potential owner.
     */
    function confirmOwnershipTransfer() external {
        if (ownershipStatus != Status.TransferInProgress) revert TransferNotInProgress();
        if (msg.sender != potentialOwner) revert WrongPotentialOwner();

        owner = msg.sender;
        delete ownershipStatus;
        delete potentialOwner;

        emit NewOwner(msg.sender);
    }

    /**
     * @notice Initiate transfer of ownership to a new owner
     * @param newPotentialOwner New potential owner address
     */
    function initiateOwnershipTransfer(address newPotentialOwner) external onlyOwner {
        if (ownershipStatus != Status.NoOngoingTransfer) revert TransferAlreadyInProgress();

        ownershipStatus = Status.TransferInProgress;
        potentialOwner = newPotentialOwner;

        /**
         * @dev This function can only be called by the owner, so msg.sender is the owner.
         *      We don't have to SLOAD the owner again.
         */
        emit InitiateOwnershipTransfer(msg.sender, newPotentialOwner);
    }

    /**
     * @notice Initiate ownership renouncement
     */
    function initiateOwnershipRenouncement() external onlyOwner {
        if (ownershipStatus != Status.NoOngoingTransfer) revert TransferAlreadyInProgress();

        ownershipStatus = Status.RenouncementInProgress;

        emit InitiateOwnershipRenouncement();
    }
}
