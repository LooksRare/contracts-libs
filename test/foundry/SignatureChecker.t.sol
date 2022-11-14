// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import {SignatureChecker, ISignatureChecker} from "../../contracts/SignatureChecker.sol";
import {ERC1271Contract} from "./utils/ERC1271Contract.sol";
import {TestHelpers} from "./utils/TestHelpers.sol";

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

contract PublicSignatureChecker is SignatureChecker {
    function recoverEOASigner(bytes32 hash, bytes calldata signature) external pure returns (address) {
        return _recoverEOASigner(hash, signature);
    }

    function splitSignature(bytes calldata signature)
        external
        pure
        returns (
            bytes32 r,
            bytes32 s,
            uint8 v
        )
    {
        return _splitSignature(signature);
    }

    function verify(
        bytes32 hash,
        address signer,
        bytes calldata signature
    ) external view returns (bool) {
        // It reverts if wrong
        _verify(hash, signer, signature);
        return true;
    }
}

contract SignatureCheckerTest is TestHelpers, TestParameters, ISignatureChecker {
    PublicSignatureChecker public signatureChecker;

    function setUp() public {
        signatureChecker = new PublicSignatureChecker();
    }

    function testSignEOA() public {
        bytes memory signature = _signMessage(_message, privateKeyUser1);

        (bytes32 r, bytes32 s, uint8 v) = signatureChecker.splitSignature(signature);
        assertEq(r, 0xc8615728c761050d02b9aab90e280d1306dd00c90c8903750d0d9f20b5ad8788);
        assertEq(s, 0x10a942f95b476b979996eb66a41a00e57c08c0b0c683de35753e88b4efc663e7);
        assertEq(v, 28);

        bytes32 hashedMessage = _computeHash(_message);

        assertEq(signatureChecker.recoverEOASigner(hashedMessage, signature), user1);
        assertTrue(signatureChecker.verify(hashedMessage, user1, signature));
    }

    function testSignERC1271() public {
        ERC1271Contract erc1271Contract = new ERC1271Contract(user1);
        bytes memory signature = _signMessage(_message, privateKeyUser1);

        (bytes32 r, bytes32 s, uint8 v) = signatureChecker.splitSignature(signature);
        assertEq(r, 0xc8615728c761050d02b9aab90e280d1306dd00c90c8903750d0d9f20b5ad8788);
        assertEq(s, 0x10a942f95b476b979996eb66a41a00e57c08c0b0c683de35753e88b4efc663e7);
        assertEq(v, 28);

        bytes32 hashedMessage = _computeHash(_message);
        assertTrue(signatureChecker.verify(hashedMessage, address(erc1271Contract), signature));
    }

    function testCannotSignIfWrongSignatureERC1271() public {
        ERC1271Contract erc1271Contract = new ERC1271Contract(user1);
        bytes memory signature = _signMessage(_message, privateKeyUser2);

        (bytes32 r, bytes32 s, uint8 v) = signatureChecker.splitSignature(signature);
        assertEq(r, 0x840c4d37ffb6c9be50b07bdd169aab62445cb37cd34b5ade4ce72ddaf0dce8af);
        assertEq(s, 0x5eed80b50bbd12d2c6da920150d7ef7fabc496531e340acbfbeb9206159c8878);
        assertEq(v, 27);

        bytes32 hashedMessage = _computeHash(_message);
        vm.expectRevert(InvalidSignatureERC1271.selector);
        signatureChecker.verify(hashedMessage, address(erc1271Contract), signature);
    }

    function testCannotSignIfWrongSignatureEOA() public {
        bytes memory signature = _signMessage(_message, privateKeyUser2);

        (bytes32 r, bytes32 s, uint8 v) = signatureChecker.splitSignature(signature);
        assertEq(r, 0x840c4d37ffb6c9be50b07bdd169aab62445cb37cd34b5ade4ce72ddaf0dce8af);
        assertEq(s, 0x5eed80b50bbd12d2c6da920150d7ef7fabc496531e340acbfbeb9206159c8878);
        assertEq(v, 27);

        bytes32 hashedMessage = _computeHash(_message);
        vm.expectRevert(InvalidSignatureEOA.selector);
        signatureChecker.verify(hashedMessage, user1, signature);
    }
}
