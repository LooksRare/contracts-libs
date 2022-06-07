// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from "../../lib/forge-std/src/Test.sol";

abstract contract TestHelpers is Test {
    modifier asPrankedUser(address _user) {
        vm.startPrank(_user);
        _;
        vm.stopPrank();
    }
}
