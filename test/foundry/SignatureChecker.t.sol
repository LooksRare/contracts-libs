// SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

import {SignatureChecker} from "../../contracts/SignatureChecker.sol";
import {TestHelpers} from "./TestHelpers.sol";

abstract contract SignatureCheckerErrors {
    error BadSignatureS();
    error BadSignatureV(uint8 v);
    error InvalidSignatureERC1271();
    error InvalidSignatureEOA();
    error WrongSignatureLength(uint256 length);
}

abstract contract TestParameters is TestHelpers {
    // Generate two random private keys
    uint256 internal privateKeyUser1 = 0x00aaf;
    uint256 internal privateKeyUser2 = 0x00aabf;

    // Derive public keys
    address internal user1 = vm.addr(privateKeyUser1);
    address internal user2 = vm.addr(privateKeyUser2);

    function _signMessage(bytes32 message, uint256 _key) internal returns (bytes memory) {
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(_key, keccak256(abi.encodePacked(message)));
        return abi.encodePacked(r, s, v);
    }

    function _computeHash(bytes32 message) internal returns (bytes32) {
        return keccak256(abi.encodePacked(message));
    }
}

contract GreatSignatureChecker is SignatureChecker {
    function recoverEOASigner(bytes32 hash, bytes memory signature) external pure returns (address) {
        return _recoverEOASigner(hash, signature);
    }

    function verify(
        bytes32 hash,
        address signer,
        bytes memory signature
    ) external returns (bool) {
        // It reverts if wrong
        _verify(hash, signer, signature);
        return true;
    }
}

contract SignatureCheckerTest is TestHelpers, TestParameters, SignatureCheckerErrors {
    GreatSignatureChecker public signatureChecker;

    function setUp() public {
        signatureChecker = new GreatSignatureChecker();
    }

    function testSignEOA() public {
        bytes32 message = keccak256("Hello World");
        bytes memory signature = _signMessage(message, privateKeyUser1);
        bytes32 hashedMessage = _computeHash(message);

        assertEq(signatureChecker.recoverEOASigner(hashedMessage, signature), user1);
        assertTrue(signatureChecker.verify(hashedMessage, user1, signature));
    }
}
