// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {ReentrancyGuard, IReentrancyGuard} from "../../contracts/ReentrancyGuard.sol";
import {TestHelpers} from "./utils/TestHelpers.sol";
import {Faucet} from "./utils/reentrancy/Faucet.sol";
import {UnsafeFaucet} from "./utils/reentrancy/UnsafeFaucet.sol";
import {ReentrancyCaller} from "./utils/reentrancy/ReentrancyCaller.sol";

contract SafeFaucet is Faucet, ReentrancyGuard {
    function claim() external override nonReentrant {
        _claim();
    }
}

contract ReentrancyGuardTest is TestHelpers, IReentrancyGuard {
    SafeFaucet public safeFaucet;
    UnsafeFaucet public unsafeFaucet;

    function setUp() public {
        safeFaucet = new SafeFaucet();
        unsafeFaucet = new UnsafeFaucet();
        // Top up the faucets
        vm.deal(address(safeFaucet), 200 ether);
        vm.deal(address(unsafeFaucet), 200 ether);
    }

    function testUnsafeFaucet() public {
        ReentrancyCaller reentrancyCaller = new ReentrancyCaller(address(unsafeFaucet));

        reentrancyCaller.claim();
        // 5 iterations + original claim = 6 * 0.01 = 0.06 ether
        assertEq(uint256(address(reentrancyCaller).balance), 0.06 ether);
    }

    function testSafeFaucet() public {
        ReentrancyCaller reentrancyCaller = new ReentrancyCaller(address(safeFaucet));

        vm.expectRevert(ReentrancyFail.selector);
        reentrancyCaller.claim();
        assertEq(uint256(address(reentrancyCaller).balance), 0 ether);
    }
}
