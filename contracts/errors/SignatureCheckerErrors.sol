// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

error BadSignatureS();
error BadSignatureV(uint8 v);
error InvalidSignatureERC1271();
error InvalidSignatureEOA();
error NullSignerAddress();
error WrongSignatureLength(uint256 length);
