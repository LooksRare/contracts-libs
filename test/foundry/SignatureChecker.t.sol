// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {ERC1271Contract} from "./utils/ERC1271Contract.sol";
import {PublicSignatureChecker} from "./utils/PublicSignatureChecker.sol";
import {TestHelpers} from "./utils/TestHelpers.sol";
import "../../contracts/errors/SignatureCheckerErrors.sol";

abstract contract TestParameters is TestHelpers {
    // Generate two random private keys
    uint256 internal privateKeyUser1 = 0x00aaf;
    uint256 internal privateKeyUser2 = 0x00aabf;

    // Derive two public keys from private keys
    address internal user1 = vm.addr(privateKeyUser1);
    address internal user2 = vm.addr(privateKeyUser2);
}

contract SignatureCheckerTest is TestHelpers, TestParameters {
    PublicSignatureChecker public signatureChecker;

    function setUp() public {
        signatureChecker = new PublicSignatureChecker();
    }

    function testSignEOA(bytes32 randomMessage) public {
        bytes memory signature = _signMessage(randomMessage, privateKeyUser1);
        bytes32 hashedMessage = _computeHash(randomMessage);

        assertTrue(signatureChecker.verify(hashedMessage, user1, signature));
    }

    function testSignEOAEIP2098(bytes32 randomMessage) public {
        bytes memory signature = _eip2098Signature(_signMessage(randomMessage, privateKeyUser1));
        bytes32 hashedMessage = _computeHash(randomMessage);

        assertTrue(signatureChecker.verify(hashedMessage, user1, signature));
    }

    function testSignERC1271(bytes32 randomMessage) public {
        ERC1271Contract erc1271Contract = new ERC1271Contract(user1);
        bytes memory signature = _signMessage(randomMessage, privateKeyUser1);

        bytes32 hashedMessage = _computeHash(randomMessage);
        assertTrue(signatureChecker.verify(hashedMessage, address(erc1271Contract), signature));
    }

    function testRevertIfWrongSignatureERC1271(bytes32 randomMessage) public {
        ERC1271Contract erc1271Contract = new ERC1271Contract(user1);
        bytes memory signature = _signMessage(randomMessage, privateKeyUser2);

        bytes32 hashedMessage = _computeHash(randomMessage);
        vm.expectRevert(InvalidSignatureERC1271.selector);
        signatureChecker.verify(hashedMessage, address(erc1271Contract), signature);
    }

    function testRevertIfWrongSignatureEOA(bytes32 randomMessage) public {
        bytes memory signature = _signMessage(randomMessage, privateKeyUser2);

        bytes32 hashedMessage = _computeHash(randomMessage);
        vm.expectRevert(InvalidSignatureEOA.selector);
        signatureChecker.verify(hashedMessage, user1, signature);
    }

    function testRevertIfWrongVParameter(bytes32 randomMessage, uint8 v) public {
        vm.assume(v != 27 && v != 28);
        (, bytes32 r, bytes32 s) = vm.sign(privateKeyUser1, keccak256(abi.encodePacked(randomMessage)));

        // Encode the signature
        bytes memory signature = abi.encodePacked(r, s, v);
        bytes32 hashedMessage = _computeHash(randomMessage);

        vm.expectRevert(abi.encodeWithSelector(BadSignatureV.selector, v));
        signatureChecker.verify(hashedMessage, user1, signature);
    }

    function testRevertIfWrongSParameter(bytes32 randomMessage, bytes32 s) public {
        vm.assume(uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0);

        (uint8 v, bytes32 r, ) = vm.sign(privateKeyUser1, keccak256(abi.encodePacked(randomMessage)));

        // Encode the signature with the fuzzed s
        bytes memory signature = abi.encodePacked(r, s, v);
        bytes32 hashedMessage = _computeHash(randomMessage);

        vm.expectRevert(abi.encodeWithSelector(BadSignatureS.selector));
        signatureChecker.verify(hashedMessage, user1, signature);
    }

    function testRevertIfRecoveredAddressIsNull(bytes32 randomMessage) public {
        (uint8 v, , bytes32 s) = vm.sign(privateKeyUser1, keccak256(abi.encodePacked(randomMessage)));

        // Encode the signature with empty bytes32 for r
        bytes32 r;
        bytes memory signature = abi.encodePacked(r, s, v);
        bytes32 hashedMessage = _computeHash(randomMessage);

        vm.expectRevert(abi.encodeWithSelector(NullSignerAddress.selector));
        signatureChecker.verify(hashedMessage, user1, signature);
    }

    function testRevertIfWrongSignatureLength(bytes32 randomMessage, uint256 length) public {
        // @dev Getting OutOfGas starting from 16,776,985, probably due to memory cost
        vm.assume(length != 64 && length != 65 && length < 16_776_985);
        bytes memory signature = new bytes(length);

        bytes32 hashedMessage = _computeHash(randomMessage);
        vm.expectRevert(abi.encodeWithSelector(WrongSignatureLength.selector, length));
        signatureChecker.verify(hashedMessage, user1, signature);
    }
}
