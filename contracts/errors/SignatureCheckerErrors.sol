// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

/**
 * @notice It is emitted if the signature is invalid due to S parameter.
 */
error BadSignatureS();

/**
 * @notice It is emitted if the signature is invalid due to V parameter.
 */
error BadSignatureV(uint8 v);

/**
 * @notice It is emitted if the signature is invalid for a ERC1271 contract signer.
 */
error InvalidSignatureERC1271();

/**
 * @notice It is emitted if the signature is invalid for an EOA (the address recovered is not the expected one).
 */
error InvalidSignatureEOA();

/**
 * @notice It is emitted if the signer is null.
 */
error NullSignerAddress();

/**
 * @notice It is emitted if the signature's length is not 64 or 65 bytes.
 */
error WrongSignatureLength(uint256 length);
