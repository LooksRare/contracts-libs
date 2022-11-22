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

    // Delay for the timelock (in seconds)
    uint256 public delay;

    // Earliest ownership renouncement timestamp
    uint256 public earliestOwnershipRenouncementTime;

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
     *         Delay (for the timelock) must be set by the contract that inherits from this.
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
        if (ownershipStatus == Status.NoOngoingTransfer) revert NoOngoingTransferInProgress();

        if (ownershipStatus == Status.TransferInProgress) {
            delete potentialOwner;
        } else if (ownershipStatus == Status.RenouncementInProgress) {
            delete earliestOwnershipRenouncementTime;
        }

        delete ownershipStatus;

        emit CancelOwnershipTransfer();
    }

    /**
     * @notice Confirm ownership renouncement
     */
    function confirmOwnershipRenouncement() external onlyOwner {
        if (ownershipStatus != Status.RenouncementInProgress) revert RenouncementNotInProgress();
        if (block.timestamp < earliestOwnershipRenouncementTime) revert RenouncementTooEarly();

        delete earliestOwnershipRenouncementTime;
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
        earliestOwnershipRenouncementTime = block.timestamp + delay;

        emit InitiateOwnershipRenouncement(earliestOwnershipRenouncementTime);
    }

    /**
     * @notice Set up the timelock delay for renouncing ownership
     * @param _delay Timelock delay for the owner to confirm renouncing the ownership
     * @dev This function is expected to be included in the constructor of the contract that inherits this contract.
     *      If it is not set, there is no timelock to renounce the ownership.
     */
    function _setupDelayForRenouncingOwnership(uint256 _delay) internal {
        delay = _delay;
    }
}
