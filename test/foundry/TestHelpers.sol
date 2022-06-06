// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from "../../lib/forge-std/src/Test.sol";

abstract contract TestHelpers is Test {
    address public user1 = address(1);
    address public user2 = address(2);
    address public user3 = address(3);
    address public user4 = address(4);
    address public user5 = address(5);
    address public user6 = address(6);
    address public user7 = address(7);
    address public user8 = address(8);
    address public user9 = address(9);

    modifier asPrankedUser(address _user) {
        vm.startPrank(_user);
        _;
        vm.stopPrank();
    }
}
