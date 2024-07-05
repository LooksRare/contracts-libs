// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {OwnableTwoSteps} from "../../contracts/OwnableTwoSteps.sol";
import {BlastPoints} from "../../contracts/BlastPoints.sol";
import {TestHelpers} from "./utils/TestHelpers.sol";

import {MockBlastPoints} from "../mock/MockBlastPoints.sol";

contract BlastPointsOwnableTwoSteps is BlastPoints, OwnableTwoSteps {
    constructor(
        address _blastPoints,
        address _blastPointsOperator
    ) BlastPoints(_blastPoints, _blastPointsOperator) OwnableTwoSteps(_blastPointsOperator) {}
}

contract BlastPointsOwnableTwoSteps_Test is TestHelpers {
    MockBlastPoints private mockBlastPoints;
    BlastPointsOwnableTwoSteps private blastPointsOwnableTwoSteps;

    address public operator = address(420);
    address private constant TREASURY = address(69420);

    function setUp() public {
        mockBlastPoints = new MockBlastPoints();
        blastPointsOwnableTwoSteps = new BlastPointsOwnableTwoSteps(address(mockBlastPoints), operator);
    }

    function test_setUpState() public {
        assertEq(mockBlastPoints.contractOperators(address(blastPointsOwnableTwoSteps)), operator);
    }
}
