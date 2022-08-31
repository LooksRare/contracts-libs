// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {OwnableTwoSteps} from "../../contracts/OwnableTwoSteps.sol";
import {IOwnableTwoSteps} from "../../contracts/interfaces/IOwnableTwoSteps.sol";
import {TestHelpers} from "./utils/TestHelpers.sol";

abstract contract TestParameters {
    address internal _OWNER = address(42);
    uint256 internal _delay = 6 hours;
}

contract ImplementedOwnableTwoSteps is OwnableTwoSteps {
    constructor(uint256 _delay) {
        _setupDelayForRenouncingOwnership(_delay);
    }
}

contract OwnableTwoStepsTest is TestParameters, TestHelpers, IOwnableTwoSteps {
    ImplementedOwnableTwoSteps public ownableTwoSteps;

    function setUp() public asPrankedUser(_OWNER) {
        ownableTwoSteps = new ImplementedOwnableTwoSteps(_delay);
    }

    function testConstructor() public {
        assertEq(ownableTwoSteps.owner(), _OWNER);
        assertEq(ownableTwoSteps.potentialOwner(), address(0));
        assertEq(uint8(ownableTwoSteps.status()), uint8(Status.NoOngoingTransfer));
        assertEq(ownableTwoSteps.delay(), _delay);
    }

    function testTransferOwnershipToNewOwner() public {
        address newOwner = address(45);

        // 1. Initiate ownership transfer
        vm.prank(_OWNER);
        vm.expectEmit(false, false, false, true);
        emit InitiateOwnershipTransfer(_OWNER, newOwner);
        ownableTwoSteps.initiateOwnershipTransfer(newOwner);
        assertEq(ownableTwoSteps.potentialOwner(), newOwner);
        assertEq(uint8(ownableTwoSteps.status()), uint8(Status.TransferInProgress));

        // 2. Accept ownership's transfer
        vm.prank(newOwner);
        vm.expectEmit(false, false, false, true);
        emit NewOwner(newOwner);
        ownableTwoSteps.confirmOwnershipTransfer();
        assertEq(ownableTwoSteps.potentialOwner(), address(0));
        assertEq(ownableTwoSteps.owner(), newOwner);
        assertEq(uint8(ownableTwoSteps.status()), uint8(Status.NoOngoingTransfer));
    }

    function testRenounceOwnership() public asPrankedUser(_OWNER) {
        // 1. Initiate renouncement of ownership
        vm.expectEmit(false, false, false, true);
        emit InitiateOwnershipRenouncement(block.timestamp + _delay);
        ownableTwoSteps.initiateOwnershipRenouncement();
        assertEq(ownableTwoSteps.potentialOwner(), address(0));
        assertEq(ownableTwoSteps.earliestOwnershipRenouncementTime(), block.timestamp + _delay);
        assertEq(uint8(ownableTwoSteps.status()), uint8(Status.RenouncementInProgress));

        // 2. Confirm renouncement of ownership
        // Time travel
        vm.warp(ownableTwoSteps.earliestOwnershipRenouncementTime());
        vm.expectEmit(false, false, false, true);
        emit NewOwner(address(0));
        ownableTwoSteps.confirmOwnershipRenouncement();
        assertEq(ownableTwoSteps.potentialOwner(), address(0));
        assertEq(ownableTwoSteps.owner(), address(0));
        assertEq(uint8(ownableTwoSteps.status()), uint8(Status.NoOngoingTransfer));
    }

    function testCancelTransferOwnership() public asPrankedUser(_OWNER) {
        address newOwner = address(45);

        // 1. Initiate ownership transfer
        vm.expectEmit(false, false, false, true);
        emit InitiateOwnershipTransfer(_OWNER, newOwner);
        ownableTwoSteps.initiateOwnershipTransfer(newOwner);
        assertEq(ownableTwoSteps.potentialOwner(), newOwner);
        assertEq(uint8(ownableTwoSteps.status()), uint8(Status.TransferInProgress));

        // 2. Cancel ownership transfer
        vm.expectEmit(false, false, false, true);
        emit CancelOwnershipTransfer();
        ownableTwoSteps.cancelOwnershipTransfer();
        assertEq(ownableTwoSteps.potentialOwner(), address(0));
        assertEq(ownableTwoSteps.owner(), _OWNER);
        assertEq(uint8(ownableTwoSteps.status()), uint8(Status.NoOngoingTransfer));

        // 3. Initiate ownership renouncement
        vm.expectEmit(false, false, false, true);
        emit InitiateOwnershipRenouncement(block.timestamp + _delay);
        ownableTwoSteps.initiateOwnershipRenouncement();
        assertEq(ownableTwoSteps.potentialOwner(), address(0));
        assertEq(ownableTwoSteps.earliestOwnershipRenouncementTime(), block.timestamp + _delay);
        assertEq(uint8(ownableTwoSteps.status()), uint8(Status.RenouncementInProgress));

        // 4. Cancel ownership renouncement
        vm.expectEmit(false, false, false, true);
        emit CancelOwnershipTransfer();
        ownableTwoSteps.cancelOwnershipTransfer();
        assertEq(ownableTwoSteps.potentialOwner(), address(0));
        assertEq(ownableTwoSteps.owner(), _OWNER);
        assertEq(uint8(ownableTwoSteps.status()), uint8(Status.NoOngoingTransfer));
    }

    function testWrongRecipientCannotClaim() public {
        address newOwner = address(45);
        address wrongOwner = address(30);

        // 1. Initiate ownership transfer
        vm.prank(_OWNER);
        vm.expectEmit(false, false, false, true);
        emit InitiateOwnershipTransfer(_OWNER, newOwner);
        ownableTwoSteps.initiateOwnershipTransfer(newOwner);

        vm.prank(wrongOwner);
        vm.expectRevert(WrongPotentialOwner.selector);
        ownableTwoSteps.confirmOwnershipTransfer();
    }

    function testCannotConfirmRenouncementOwnershipPriorToTimelock() public asPrankedUser(_OWNER) {
        // Initiate renouncement of ownership
        vm.expectEmit(false, false, false, true);
        emit InitiateOwnershipRenouncement(block.timestamp + _delay);
        ownableTwoSteps.initiateOwnershipRenouncement();
        assertEq(ownableTwoSteps.potentialOwner(), address(0));
        assertEq(ownableTwoSteps.earliestOwnershipRenouncementTime(), block.timestamp + _delay);
        assertEq(uint8(ownableTwoSteps.status()), uint8(Status.RenouncementInProgress));

        // Time travel to 1 second prior to end of timelock
        vm.warp(ownableTwoSteps.earliestOwnershipRenouncementTime() - 1);
        vm.expectRevert(RenouncementTooEarly.selector);
        ownableTwoSteps.confirmOwnershipRenouncement();
    }

    function testOwnableFunctionsOnlyCallableByOwner() public {
        address wrongOwner = address(30);
        vm.startPrank(wrongOwner);

        vm.expectRevert(NotOwner.selector);
        ownableTwoSteps.cancelOwnershipTransfer();

        vm.expectRevert(NotOwner.selector);
        ownableTwoSteps.confirmOwnershipRenouncement();

        vm.expectRevert(NotOwner.selector);
        ownableTwoSteps.initiateOwnershipTransfer(wrongOwner);

        vm.expectRevert(NotOwner.selector);
        ownableTwoSteps.initiateOwnershipRenouncement();
    }

    function testCannotConfirmOwnershipOrRenouncementTransferIfNotInProgress() public asPrankedUser(_OWNER) {
        vm.expectRevert(TransferNotInProgress.selector);
        ownableTwoSteps.confirmOwnershipTransfer();

        vm.expectRevert(RenouncementNotInProgress.selector);
        ownableTwoSteps.confirmOwnershipRenouncement();
    }

    function testCannotCancelTransferIfNoTransferInProgress() public asPrankedUser(_OWNER) {
        vm.expectRevert(NoOngoingTransferInProgress.selector);
        ownableTwoSteps.cancelOwnershipTransfer();
    }

    function testCannotRenounceOrInitiateTransferASecondtime() public asPrankedUser(_OWNER) {
        // 1. Cannot initiate renouncement/transfer to new owner after transfer to new owner is initiated
        address newOwner = address(45);
        ownableTwoSteps.initiateOwnershipTransfer(newOwner);
        vm.expectRevert(TransferAlreadyInProgress.selector);
        ownableTwoSteps.initiateOwnershipTransfer(newOwner);
        vm.expectRevert(TransferAlreadyInProgress.selector);
        ownableTwoSteps.initiateOwnershipRenouncement();

        // Reset status
        ownableTwoSteps.cancelOwnershipTransfer();

        // 2. Cannot initiate renouncement/transfer to new owner after renouncement is initiated
        ownableTwoSteps.initiateOwnershipRenouncement();
        vm.expectRevert(TransferAlreadyInProgress.selector);
        ownableTwoSteps.initiateOwnershipRenouncement();
        vm.expectRevert(TransferAlreadyInProgress.selector);
        ownableTwoSteps.initiateOwnershipTransfer(newOwner);
    }
}
