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

    // Random message signed across tests
    bytes32 internal _message = keccak256("Hello World");
}

contract SignatureCheckerTest is TestHelpers, TestParameters {
    PublicSignatureChecker public signatureChecker;

    function setUp() public {
        signatureChecker = new PublicSignatureChecker();
    }

    function testSignEOA() public {
        bytes memory signature = _signMessage(_message, privateKeyUser1);
        bytes32 hashedMessage = _computeHash(_message);

        assertTrue(signatureChecker.verify(hashedMessage, user1, signature));
    }

    function testSignEOAEIP2098() public {
        bytes memory signature = _eip2098Signature(_signMessage(_message, privateKeyUser1));
        bytes32 hashedMessage = _computeHash(_message);

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

    function testCannotSignIfWrongVParameter(uint8 v) public {
        vm.assume(v != 27 && v != 28);
        (, bytes32 r, bytes32 s) = vm.sign(privateKeyUser1, keccak256(abi.encodePacked(_message)));

        // Encode the signature
        bytes memory signature = abi.encodePacked(r, s, v);
        bytes32 hashedMessage = _computeHash(_message);

        vm.expectRevert(abi.encodeWithSelector(BadSignatureV.selector, v));
        signatureChecker.verify(hashedMessage, user1, signature);
    }

    function testCannotSignIfWrongSParameter(bytes32 s) public {
        vm.assume(uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0);

        (uint8 v, bytes32 r, ) = vm.sign(privateKeyUser1, keccak256(abi.encodePacked(_message)));

        // Encode the signature with the fuzzed s
        bytes memory signature = abi.encodePacked(r, s, v);
        bytes32 hashedMessage = _computeHash(_message);

        vm.expectRevert(abi.encodeWithSelector(BadSignatureS.selector));
        signatureChecker.verify(hashedMessage, user1, signature);
    }

    function testCannotSignIfWrongSignatureLength(uint256 length) public {
        // Getting OutOfGas starting from 16,776,985, probably due to memory cost
        vm.assume(length != 64 && length != 65 && length < 16_776_985);
        bytes memory signature = new bytes(length);

        bytes32 hashedMessage = _computeHash(_message);
        vm.expectRevert(abi.encodeWithSelector(WrongSignatureLength.selector, length));
        signatureChecker.verify(hashedMessage, user1, signature);
    }
}
