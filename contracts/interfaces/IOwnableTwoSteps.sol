// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

/**
 * @title IOwnableTwoSteps
 */
interface IOwnableTwoSteps {
    enum Status {
        NoOngoingTransfer,
        TransferInProgress,
        RenouncementInProgress
    }

    // Custom errors
    error NoOngoingTransferInProgress();
    error NotOwner();
    error RenouncementNotInProgress();
    error TransferAlreadyInProgress();
    error TransferNotInProgress();
    error WrongPotentialOwner();

    // Events
    event CancelOwnershipTransfer();
    event InitiateOwnershipRenouncement();
    event InitiateOwnershipTransfer(address previousOwner, address potentialOwner);
    event NewOwner(address newOwner);
}
