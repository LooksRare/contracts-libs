// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {OwnableTwoSteps} from "../../contracts/OwnableTwoSteps.sol";
import {IOwnableTwoSteps} from "../../contracts/interfaces/IOwnableTwoSteps.sol";
import {TestHelpers} from "./utils/TestHelpers.sol";

abstract contract TestParameters {
    address internal _owner = address(42);
}

contract ImplementedOwnableTwoSteps is TestParameters, OwnableTwoSteps {
    constructor() OwnableTwoSteps(_owner) {}
}

contract OwnableTwoStepsTest is TestParameters, TestHelpers, IOwnableTwoSteps {
    ImplementedOwnableTwoSteps public ownableTwoSteps;

    function setUp() public asPrankedUser(_owner) {
        vm.expectEmit(true, false, false, true);
        emit NewOwner(_owner);
        ownableTwoSteps = new ImplementedOwnableTwoSteps();
    }

    function testConstructor() public {
        assertEq(ownableTwoSteps.owner(), _owner);
        assertEq(ownableTwoSteps.potentialOwner(), address(0));
        assertEq(uint8(ownableTwoSteps.ownershipStatus()), uint8(Status.NoOngoingTransfer));
    }

    function testTransferOwnershipToNewOwner() public {
        address newOwner = address(45);

        // 1. Initiate ownership transfer
        vm.prank(_owner);
        vm.expectEmit(false, false, false, true);
        emit InitiateOwnershipTransfer(_owner, newOwner);
        ownableTwoSteps.initiateOwnershipTransfer(newOwner);
        assertEq(ownableTwoSteps.potentialOwner(), newOwner);
        assertEq(uint8(ownableTwoSteps.ownershipStatus()), uint8(Status.TransferInProgress));

        // 2. Accept ownership transfer
        vm.prank(newOwner);
        vm.expectEmit(false, false, false, true);
        emit NewOwner(newOwner);
        ownableTwoSteps.confirmOwnershipTransfer();
        assertEq(ownableTwoSteps.potentialOwner(), address(0));
        assertEq(ownableTwoSteps.owner(), newOwner);
        assertEq(uint8(ownableTwoSteps.ownershipStatus()), uint8(Status.NoOngoingTransfer));
    }

    function testRenounceOwnership() public asPrankedUser(_owner) {
        // 1. Initiate renouncement of ownership
        vm.expectEmit(false, false, false, true);
        emit InitiateOwnershipRenouncement();
        ownableTwoSteps.initiateOwnershipRenouncement();
        assertEq(ownableTwoSteps.potentialOwner(), address(0));
        assertEq(uint8(ownableTwoSteps.ownershipStatus()), uint8(Status.RenouncementInProgress));

        // 2. Confirm renouncement of ownership
        vm.expectEmit(false, false, false, true);
        emit NewOwner(address(0));
        ownableTwoSteps.confirmOwnershipRenouncement();
        assertEq(ownableTwoSteps.potentialOwner(), address(0));
        assertEq(ownableTwoSteps.owner(), address(0));
        assertEq(uint8(ownableTwoSteps.ownershipStatus()), uint8(Status.NoOngoingTransfer));
    }

    function testCancelTransferOwnership() public asPrankedUser(_owner) {
        address newOwner = address(45);

        // 1. Initiate ownership transfer
        vm.expectEmit(false, false, false, true);
        emit InitiateOwnershipTransfer(_owner, newOwner);
        ownableTwoSteps.initiateOwnershipTransfer(newOwner);
        assertEq(ownableTwoSteps.potentialOwner(), newOwner);
        assertEq(uint8(ownableTwoSteps.ownershipStatus()), uint8(Status.TransferInProgress));

        // 2. Cancel ownership transfer
        vm.expectEmit(false, false, false, true);
        emit CancelOwnershipTransfer();
        ownableTwoSteps.cancelOwnershipTransfer();
        assertEq(ownableTwoSteps.potentialOwner(), address(0));
        assertEq(ownableTwoSteps.owner(), _owner);
        assertEq(uint8(ownableTwoSteps.ownershipStatus()), uint8(Status.NoOngoingTransfer));

        // 3. Initiate ownership renouncement
        vm.expectEmit(false, false, false, true);
        emit InitiateOwnershipRenouncement();
        ownableTwoSteps.initiateOwnershipRenouncement();
        assertEq(ownableTwoSteps.potentialOwner(), address(0));
        assertEq(uint8(ownableTwoSteps.ownershipStatus()), uint8(Status.RenouncementInProgress));

        // 4. Cancel ownership renouncement
        vm.expectEmit(false, false, false, true);
        emit CancelOwnershipTransfer();
        ownableTwoSteps.cancelOwnershipTransfer();
        assertEq(ownableTwoSteps.potentialOwner(), address(0));
        assertEq(ownableTwoSteps.owner(), _owner);
        assertEq(uint8(ownableTwoSteps.ownershipStatus()), uint8(Status.NoOngoingTransfer));
    }

    function testWrongRecipientCannotClaim() public {
        address newOwner = address(45);
        address wrongOwner = address(30);

        // 1. Initiate ownership transfer
        vm.prank(_owner);
        vm.expectEmit(false, false, false, true);
        emit InitiateOwnershipTransfer(_owner, newOwner);
        ownableTwoSteps.initiateOwnershipTransfer(newOwner);

        vm.prank(wrongOwner);
        vm.expectRevert(WrongPotentialOwner.selector);
        ownableTwoSteps.confirmOwnershipTransfer();
    }

    function testOwnableFunctionsOnlyCallableByOwner(address randomUser) public asPrankedUser(randomUser) {
        vm.assume(randomUser != _owner);

        vm.expectRevert(NotOwner.selector);
        ownableTwoSteps.cancelOwnershipTransfer();

        vm.expectRevert(NotOwner.selector);
        ownableTwoSteps.confirmOwnershipRenouncement();

        vm.expectRevert(NotOwner.selector);
        ownableTwoSteps.initiateOwnershipTransfer(randomUser);

        vm.expectRevert(NotOwner.selector);
        ownableTwoSteps.initiateOwnershipRenouncement();
    }

    function testCannotConfirmOwnershipOrRenouncementTransferIfNotInProgress() public asPrankedUser(_owner) {
        vm.expectRevert(TransferNotInProgress.selector);
        ownableTwoSteps.confirmOwnershipTransfer();

        vm.expectRevert(RenouncementNotInProgress.selector);
        ownableTwoSteps.confirmOwnershipRenouncement();
    }

    function testCannotCancelTransferIfNoTransferInProgress() public asPrankedUser(_owner) {
        vm.expectRevert(NoOngoingTransferInProgress.selector);
        ownableTwoSteps.cancelOwnershipTransfer();
    }

    function testCannotRenounceOrInitiateTransferASecondtime() public asPrankedUser(_owner) {
        // 1. Cannot initiate renouncement/transfer to new owner after transfer to new owner is initiated
        address newOwner = address(45);
        ownableTwoSteps.initiateOwnershipTransfer(newOwner);
        vm.expectRevert(TransferAlreadyInProgress.selector);
        ownableTwoSteps.initiateOwnershipTransfer(newOwner);
        vm.expectRevert(TransferAlreadyInProgress.selector);
        ownableTwoSteps.initiateOwnershipRenouncement();

        // Reset ownership status
        ownableTwoSteps.cancelOwnershipTransfer();

        // 2. Cannot initiate renouncement/transfer to new owner after renouncement is initiated
        ownableTwoSteps.initiateOwnershipRenouncement();
        vm.expectRevert(TransferAlreadyInProgress.selector);
        ownableTwoSteps.initiateOwnershipRenouncement();
        vm.expectRevert(TransferAlreadyInProgress.selector);
        ownableTwoSteps.initiateOwnershipTransfer(newOwner);
    }
}
