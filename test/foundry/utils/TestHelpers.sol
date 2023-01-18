// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {Test} from "../../../lib/forge-std/src/Test.sol";
import {BytesLib} from "solidity-bytes-utils/contracts/BytesLib.sol";

abstract contract TestHelpers is Test {
    using BytesLib for bytes;

    modifier asPrankedUser(address _user) {
        vm.startPrank(_user);
        _;
        vm.stopPrank();
    }

    function _signMessage(bytes32 message, uint256 _key) internal returns (bytes memory) {
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(_key, keccak256(abi.encodePacked(message)));
        return abi.encodePacked(r, s, v);
    }

    /**
     * @dev Transforms a standard signature into an EIP-2098 compliant signature
     * @param signature The secp256k1 65-bytes signature
     * @return eip2098Signature The 64-bytes EIP-2098 compliant signature
     */
    function _eip2098Signature(bytes memory signature) internal pure returns (bytes memory eip2098Signature) {
        eip2098Signature = signature.slice(0, 64);
        uint8 parityBit = uint8(eip2098Signature[32]) | ((uint8(signature[64]) % 27) << 7);
        eip2098Signature[32] = bytes1(parityBit);
    }

    function _computeHash(bytes32 message) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(message));
    }
}
