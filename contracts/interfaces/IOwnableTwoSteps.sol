// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

/**
 * @title IOwnableTwoSteps
 */
contract IOwnableTwoSteps {
    enum Status {
        NoOngoingTransfer,
        TransferInProgress,
        RenouncementInProgress
    }

    // Custom errors
    error NoOngoingTransferInProgress();
    error NotOwner();
    error RenouncementTooEarly();
    error RenouncementNotInProgress();
    error TransferAlreadyInProgress();
    error TransferNotInProgress();
    error WrongPotentialOwner();

    // Events
    event CancelOwnershipTransfer();
    event InitiateOwnershipRenouncement(uint256 earliestOwnershipRenouncementTime);
    event InitiateOwnershipTransfer(address previousOwner, address potentialOwner);
    event NewOwner(address newOwner);
}
