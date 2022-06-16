// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import {Test} from "../../../lib/forge-std/src/Test.sol";

abstract contract TestHelpers is Test {
    modifier asPrankedUser(address _user) {
        vm.startPrank(_user);
        _;
        vm.stopPrank();
    }

    function _signMessage(bytes32 message, uint256 _key) internal returns (bytes memory) {
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(_key, keccak256(abi.encodePacked(message)));
        return abi.encodePacked(r, s, v);
    }

    function _computeHash(bytes32 message) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(message));
    }
}
