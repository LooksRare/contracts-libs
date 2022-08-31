// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import {ReentrancyGuard, IReentrancyGuard} from "../../contracts/ReentrancyGuard.sol";
import {TestHelpers} from "./utils/TestHelpers.sol";

interface IFaucet {
    error AlreadyClaimed();

    function claim() external;
}

contract UnsafeFaucet is IFaucet {
    mapping(address => bool) internal _hasClaimed;

    function claim() external override {
        if (_hasClaimed[msg.sender]) {
            revert AlreadyClaimed();
        }

        bool status;
        address to = msg.sender;
        uint256 amount = 0.01 ether;

        assembly {
            status := call(gas(), to, amount, 0, 0, 0, 0)
        }

        if (!status) {
            revert();
        }

        _hasClaimed[msg.sender] = true;
    }
}

contract SafeFaucet is IFaucet, ReentrancyGuard {
    mapping(address => bool) internal _hasClaimed;

    function claim() external override nonReentrant {
        if (_hasClaimed[msg.sender]) {
            revert AlreadyClaimed();
        }

        bool status;
        address to = msg.sender;
        uint256 amount = 0.01 ether;

        assembly {
            status := call(gas(), to, amount, 0, 0, 0, 0)
        }

        if (!status) {
            revert();
        }

        _hasClaimed[msg.sender] = true;
    }
}

contract ReentrancyCaller {
    uint256 private _counter;
    IFaucet public faucet;

    constructor(address _faucet) {
        faucet = IFaucet(_faucet);
    }

    receive() external payable {
        if (_counter++ < 5) {
            faucet.claim();
        }
    }

    function claim() external {
        faucet.claim();
        // reset counter
        _counter = 0;
    }
}

contract ReentrancyGuardTest is TestHelpers {
    SafeFaucet public safeFaucet;
    UnsafeFaucet public unsafeFaucet;

    function setUp() public {
        safeFaucet = new SafeFaucet();
        unsafeFaucet = new UnsafeFaucet();

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

        vm.expectRevert();
        reentrancyCaller.claim();
        assertEq(uint256(address(reentrancyCaller).balance), 0 ether);
    }
}
