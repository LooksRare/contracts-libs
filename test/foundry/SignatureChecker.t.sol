// SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

import {SignatureChecker} from "../../contracts/SignatureChecker.sol";
import {TestHelpers} from "./TestHelpers.sol";
import {ERC1271Contract} from "./utils/ERC1271Contract.sol";

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

    // Random message signed
    bytes32 internal _message = keccak256("Hello World");

    function _signMessage(bytes32 message, uint256 _key) internal returns (bytes memory) {
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(_key, keccak256(abi.encodePacked(message)));
        return abi.encodePacked(r, s, v);
    }

    function _computeHash(bytes32 message) internal returns (bytes32) {
        return keccak256(abi.encodePacked(message));
    }
}

contract PublicSignatureChecker is SignatureChecker {
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
    PublicSignatureChecker public signatureChecker;

    function setUp() public {
        signatureChecker = new PublicSignatureChecker();
    }

    function testSignEOA() public {
        bytes memory signature = _signMessage(_message, privateKeyUser1);
        bytes32 hashedMessage = _computeHash(_message);

        assertEq(signatureChecker.recoverEOASigner(hashedMessage, signature), user1);
        assertTrue(signatureChecker.verify(hashedMessage, user1, signature));
    }

    function testSignERC1271() public {
        ERC1271Contract erc1271Contract = new ERC1271Contract(user1);
        bytes memory signature = _signMessage(_message, privateKeyUser1);
        bytes32 hashedMessage = _computeHash(_message);
        assertTrue(signatureChecker.verify(hashedMessage, address(erc1271Contract), signature));
    }

    function testCannotSignIfWrongSignatureERC1271() public {
        ERC1271Contract erc1271Contract = new ERC1271Contract(user1);
        bytes memory signature = _signMessage(_message, privateKeyUser2);
        bytes32 hashedMessage = _computeHash(_message);
        vm.expectRevert(InvalidSignatureERC1271.selector);
        signatureChecker.verify(hashedMessage, address(erc1271Contract), signature);
    }

    function testCannotSignIfWrongSignatureEOA() public {
        bytes memory signature = _signMessage(_message, privateKeyUser2);
        bytes32 hashedMessage = _computeHash(_message);
        vm.expectRevert(InvalidSignatureEOA.selector);
        signatureChecker.verify(hashedMessage, user1, signature);
    }
}
