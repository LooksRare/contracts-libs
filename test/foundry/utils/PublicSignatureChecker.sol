// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {SignatureChecker} from "../../../contracts/SignatureChecker.sol";

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
