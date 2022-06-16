// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import {IERC1271} from "./interfaces/IERC1271.sol";

/**
 * @title SignatureChecker
 * @notice This contract is used to verify signatures for EOAs (with length of both 65 and 64 bytes) and contracts (ERC-1271).
 */
abstract contract SignatureChecker {
    // Custom errors
    error BadSignatureS();
    error BadSignatureV(uint8 v);
    error InvalidSignatureERC1271();
    error InvalidSignatureEOA();
    error NullSignerAddress();
    error WrongSignatureLength(uint256 length);

    /**
     * @notice Recover the signer of a signature (for EOA)
     * @param hash the hash of the signed message
     * @param signature bytes containing the signature (64 or 65 bytes)
     */
    function _recoverEOASigner(bytes32 hash, bytes memory signature) internal pure returns (address) {
        uint8 v;
        bytes32 r;
        bytes32 s;

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

        // https://ethereum.stackexchange.com/questions/83174/is-it-best-practice-to-check-signature-malleability-in-ecrecover
        // https://crypto.iacr.org/2019/affevents/wac/medias/Heninger-BiasedNonceSense.pdf
        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            revert BadSignatureS();
        }

        if (v != 27 && v != 28) {
            revert BadSignatureV(v);
        }

        // If the signature is valid (and not malleable), return the signer address
        address signer = ecrecover(hash, v, r, s);

        if (signer == address(0)) {
            revert NullSignerAddress();
        }

        return signer;
    }

    /**
     * @notice Checks whether the signer is valid
     * @param hash data hash
     * @param signer the signer address (to confirm message validity)
     * @param signature signature parameters encoded (v, r, s)
     * @dev For EIP-712 signatures, the hash must be the digest (computed with signature hash and domain separator)
     */
    function _verify(
        bytes32 hash,
        address signer,
        bytes memory signature
    ) internal view {
        if (signer.code.length == 0) {
            if (_recoverEOASigner(hash, signature) != signer) {
                revert InvalidSignatureEOA();
            }
        } else {
            if (IERC1271(signer).isValidSignature(hash, signature) != 0x1626ba7e) {
                revert InvalidSignatureERC1271();
            }
        }
    }
}
