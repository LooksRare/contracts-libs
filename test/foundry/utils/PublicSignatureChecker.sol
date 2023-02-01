// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {SignatureCheckerCalldata} from "../../../contracts/SignatureCheckerCalldata.sol";
import {SignatureCheckerMemory} from "../../../contracts/SignatureCheckerMemory.sol";

contract PublicSignatureChecker {
    function verifyCalldata(bytes32 hash, address signer, bytes calldata signature) external view returns (bool) {
        // It will revert if it is wrong
        SignatureCheckerCalldata.verify(hash, signer, signature);
        return true;
    }

    function verifyMemory(bytes32 hash, address signer, bytes memory signature) external view returns (bool) {
        // It will revert if it is wrong
        SignatureCheckerMemory.verify(hash, signer, signature);
        return true;
    }
}
