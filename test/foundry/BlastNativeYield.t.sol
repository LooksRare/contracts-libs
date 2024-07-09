// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {BlastNativeYield} from "../../contracts/BlastNativeYield.sol";
import {TestHelpers} from "./utils/TestHelpers.sol";
import {YieldMode, GasMode} from "../../contracts/interfaces/IBlast.sol";

import {MockBlastPoints} from "../mock/MockBlastPoints.sol";
import {MockBlastYield} from "../mock/MockBlastYield.sol";

contract BlastNativeYield_Test is TestHelpers {
    MockBlastYield private mockBlastYield;
    MockBlastPoints private mockBlastPoints;
    BlastNativeYield private blastNativeYield;

    address public owner = address(69);
    address public operator = address(420);

    function setUp() public {
        mockBlastPoints = new MockBlastPoints();
        mockBlastYield = new MockBlastYield();
        blastNativeYield = new BlastNativeYield(address(mockBlastYield), address(mockBlastPoints), operator, owner);
    }

    function test_setUpState() public {
        (YieldMode yieldMode, GasMode gasMode, address governor) = mockBlastYield.config(address(blastNativeYield));
        assertEq(uint8(yieldMode), uint8(YieldMode.CLAIMABLE));
        assertEq(uint8(gasMode), uint8(GasMode.CLAIMABLE));
        assertEq(governor, owner);
    }
}
