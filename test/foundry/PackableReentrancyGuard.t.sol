// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {PackableReentrancyGuard, IReentrancyGuard} from "../../contracts/PackableReentrancyGuard.sol";
import {TestHelpers} from "./utils/TestHelpers.sol";

abstract contract Faucet {
    error AlreadyClaimed();

    mapping(address => bool) internal _hasClaimed;

    function claim() external virtual;

    function _claim() internal {
        if (_hasClaimed[msg.sender]) {
            revert AlreadyClaimed();
        }

        bool status;
        address to = msg.sender;
        uint256 amount = 0.01 ether;

        assembly {
            status := call(gas(), to, amount, 0, 0, 0, 0)
            // returndatacopy(t, f, s)
            // copy s bytes from returndata at position f to mem at position t
            returndatacopy(0, 0, returndatasize())
            switch status
            case 0 {
                // revert(p, s)
                // end execution, revert state changes, return data mem[p…(p+s))
                revert(0, returndatasize())
            }
        }

        _hasClaimed[msg.sender] = true;
    }
}

contract UnsafeFaucet is Faucet {
    function claim() external override {
        _claim();
    }
}

contract SafeFaucet is Faucet, PackableReentrancyGuard {
    function claim() external override nonReentrant {
        _claim();
    }
}

contract ReentrancyCaller {
    uint256 private _counter;
    Faucet public faucet;

    constructor(address _faucet) {
        faucet = Faucet(_faucet);
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
