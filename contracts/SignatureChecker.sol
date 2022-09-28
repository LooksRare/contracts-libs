// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import {IERC1271} from "./interfaces/generic/IERC1271.sol";
import {ISignatureChecker} from "./interfaces/ISignatureChecker.sol";

/**
 * @title SignatureChecker
 * @notice This contract is used to verify signatures for EOAs (with length of both 65 and 64 bytes) and contracts (ERC-1271).
 */
abstract contract SignatureChecker is ISignatureChecker {
    /**
     * @notice Split a signature into r,s,v outputs
     * @param signature A 64 or 65 bytes signature
     * @return r The r output of the signature
     * @return s The s output of the signature
     * @return v The recovery identifier, must be 27 or 28
     */
    function _splitSignature(bytes memory signature)
        internal
        pure
        returns (
            bytes32 r,
            bytes32 s,
            uint8 v
        )
    {
        if (signature.length == 64) {
            bytes32 vs;
            assembly {
                r := mload(add(signature, 0x20))
                vs := mload(add(signature, 0x40))
                s := and(vs, 0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff)
                v := add(shr(255, vs), 27)
            }
        } else if (signature.length == 65) {
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
        } else {
            revert WrongSignatureLength(signature.length);
        }

        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) revert BadSignatureS();

        if (v != 27 && v != 28) revert BadSignatureV(v);
    }

    /**
     * @notice Recover the signer of a signature (for EOA)
     * @param hash Hash of the signed message
     * @param signature Bytes containing the signature (64 or 65 bytes)
     */
    function _recoverEOASigner(bytes32 hash, bytes memory signature) internal pure returns (address signer) {
        (bytes32 r, bytes32 s, uint8 v) = _splitSignature(signature);

        // If the signature is valid (and not malleable), return the signer address
        signer = ecrecover(hash, v, r, s);

        if (signer == address(0)) revert NullSignerAddress();
    }

    /**
     * @notice Checks whether the signer is valid
     * @param hash Data hash
     * @param signer Signer address (to confirm message validity)
     * @param signature Signature parameters encoded (v, r, s)
     * @dev For EIP-712 signatures, the hash must be the digest (computed with signature hash and domain separator)
     */
    function _verify(
        bytes32 hash,
        address signer,
        bytes memory signature
    ) internal view {
        if (signer.code.length == 0) {
            if (_recoverEOASigner(hash, signature) != signer) revert InvalidSignatureEOA();
        } else {
            if (IERC1271(signer).isValidSignature(hash, signature) != 0x1626ba7e) revert InvalidSignatureERC1271();
        }
    }
}
