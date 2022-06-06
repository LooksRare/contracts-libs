// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {OwnableTwoSteps} from "../../contracts/OwnableTwoSteps.sol";
import {TestHelpers} from "./TestHelpers.sol";

abstract contract TestParameters {
    address internal _OWNER = address(42);
}

abstract contract OwnableTwoStepsErrorAndEvents {
    event CancelOwnershipTransfer(address previousPotentialOwner);
    event InitiateOwnershipTransfer(address previousOwner, address potentialOwner);
    event NewOwner(address newOwner);

    error NoPotentialOwner();
    error NotOwner();
    error TransferAlreadyInProgress();
    error WrongPotentialOwner();
}

contract OwnableTwoStepsTest is TestParameters, TestHelpers, OwnableTwoStepsErrorAndEvents {
    OwnableTwoSteps public ownableTwoSteps;

    function setUp() public asPrankedUser(_OWNER) {
        ownableTwoSteps = new OwnableTwoSteps();
    }

    function testConstructor() public {
        assertEq(ownableTwoSteps.owner(), _OWNER);
        assertEq(ownableTwoSteps.potentialOwner(), address(0));
    }

    function testTransfer() public {
        address newOwner = address(45);

        // 1. Initiate ownership transfer
        vm.prank(_OWNER);
        vm.expectEmit(false, false, false, true);
        emit InitiateOwnershipTransfer(_OWNER, newOwner);
        ownableTwoSteps.transferOwnership(newOwner);
        assertEq(ownableTwoSteps.potentialOwner(), newOwner);

        // 2. Accept ownership transfers
        vm.prank(newOwner);
        vm.expectEmit(false, false, false, true);
        emit NewOwner(newOwner);
        ownableTwoSteps.acceptOwnership();
        assertEq(ownableTwoSteps.potentialOwner(), address(0));
        assertEq(ownableTwoSteps.owner(), newOwner);
    }

    function testWrongRecipientCannotClaim() public {
        address newOwner = address(45);
        address wrongOwner = address(30);

        // 1. Initiate ownership transfer
        vm.prank(_OWNER);
        vm.expectEmit(false, false, false, true);
        emit InitiateOwnershipTransfer(_OWNER, newOwner);
        ownableTwoSteps.transferOwnership(newOwner);

        vm.prank(wrongOwner);
        vm.expectRevert(WrongPotentialOwner.selector);
        ownableTwoSteps.acceptOwnership();
    }
}
