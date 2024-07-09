// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {BlastPoints} from "../../contracts/BlastPoints.sol";
import {TestHelpers} from "./utils/TestHelpers.sol";

import {MockBlastPoints} from "../mock/MockBlastPoints.sol";

contract BlastPoints_Test is TestHelpers {
    MockBlastPoints private mockBlastPoints;
    BlastPoints private blastPoints;

    address public operator = address(420);

    function setUp() public {
        mockBlastPoints = new MockBlastPoints();
        blastPoints = new BlastPoints(address(mockBlastPoints), operator);
    }

    function test_setUpState() public {
        assertEq(mockBlastPoints.contractOperators(address(blastPoints)), operator);
    }
}
