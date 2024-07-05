// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {IOwnableTwoSteps} from "../../contracts/interfaces/IOwnableTwoSteps.sol";
import {OwnableTwoSteps} from "../../contracts/OwnableTwoSteps.sol";
import {BlastNativeYield} from "../../contracts/BlastNativeYield.sol";
import {TestHelpers} from "./utils/TestHelpers.sol";
import {YieldMode as IBlast__YieldMode, GasMode as IBlast__GasMode} from "../../contracts/interfaces/IBlast.sol";

import {MockBlastPoints} from "../mock/MockBlastPoints.sol";
import {MockBlastYield} from "../mock/MockBlastYield.sol";

contract BlastNativeYieldOwnableTwoSteps is BlastNativeYield, OwnableTwoSteps {
    constructor(
        address _blast,
        address _blastPoints,
        address _blastPointsOperator,
        address _owner
    ) BlastNativeYield(_blast, _blastPoints, _blastPointsOperator, _owner) OwnableTwoSteps(_owner) {}
}

contract BlastNativeYieldOwnableTwoSteps_Test is TestHelpers {
    MockBlastYield private mockBlastYield;
    MockBlastPoints private mockBlastPoints;
    BlastNativeYieldOwnableTwoSteps private blastNativeYieldOwnableTwoSteps;

    address public owner = address(69);
    address public operator = address(420);
    address private constant TREASURY = address(69420);

    function setUp() public {
        mockBlastPoints = new MockBlastPoints();
        mockBlastYield = new MockBlastYield();
        blastNativeYieldOwnableTwoSteps = new BlastNativeYieldOwnableTwoSteps(
            address(mockBlastYield),
            address(mockBlastPoints),
            operator,
            owner
        );
    }

    function test_setUpState() public {
        (IBlast__YieldMode yieldMode, IBlast__GasMode gasMode, address governor) = mockBlastYield.config(
            address(blastNativeYieldOwnableTwoSteps)
        );
        assertEq(uint8(yieldMode), uint8(IBlast__YieldMode.CLAIMABLE));
        assertEq(uint8(gasMode), uint8(IBlast__GasMode.CLAIMABLE));
        assertEq(governor, owner);
    }
}
