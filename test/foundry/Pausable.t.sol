// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {Pausable} from "../../contracts/Pausable.sol";
import {TestHelpers} from "./utils/TestHelpers.sol";

contract PausableContract is Pausable {
    bool public called;

    function pause() external {
        _pause();
    }

    function unpause() external {
        _unpause();
    }

    function callFunction() external whenNotPaused {
        called = true;
    }
}

contract PausableTest is TestHelpers {
    PausableContract private pausable;

    event Paused(address account);
    event Unpaused(address account);

    function setUp() public {
        pausable = new PausableContract();
    }

    function test_pause() public {
        vm.expectEmit({checkTopic1: true, checkTopic2: true, checkTopic3: true, checkData: true});
        emit Paused(address(this));
        pausable.pause();
        assertTrue(pausable.paused());
    }

    function test_pause_RevertIf_IsPaused() public {
        pausable.pause();
        vm.expectRevert(Pausable.IsPaused.selector);
        pausable.pause();
    }

    function test_unpause() public {
        pausable.pause();
        vm.expectEmit({checkTopic1: true, checkTopic2: true, checkTopic3: true, checkData: true});
        emit Unpaused(address(this));
        pausable.unpause();
        assertFalse(pausable.paused());
    }

    function test_unpause_RevertIf_NotPaused() public {
        vm.expectRevert(Pausable.NotPaused.selector);
        pausable.unpause();
    }

    function test_callFunction() public {
        pausable.callFunction();
        assertTrue(pausable.called());
    }

    function test_callFunction_RevertIf_Paused() public {
        pausable.pause();
        vm.expectRevert(Pausable.IsPaused.selector);
        pausable.callFunction();
    }
}
