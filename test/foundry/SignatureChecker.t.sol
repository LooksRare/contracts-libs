// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import {SignatureChecker} from "../../contracts/SignatureChecker.sol";
import {ERC1271Contract} from "./utils/ERC1271Contract.sol";
import {TestHelpers} from "./utils/TestHelpers.sol";
import "../../contracts/errors/SignatureCheckerErrors.sol";

contract PublicSignatureChecker {
    function verify(
        bytes32 hash,
        address signer,
        bytes calldata signature
    ) external view returns (bool) {
        // It will revert if it is wrong
        SignatureChecker.verify(hash, signer, signature);
        return true;
    }
}

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
