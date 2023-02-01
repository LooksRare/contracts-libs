// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {ERC1271_MAGIC_VALUE} from "../../../contracts/constants/StandardConstants.sol";
import {IERC1271} from "../../../contracts/interfaces/generic/IERC1271.sol";

contract ERC1271Contract is IERC1271 {
    // Custom errors
    error SignatureParameterSInvalid();
    error SignatureParameterVInvalid(uint8 v);
    error SignatureLengthInvalid(uint256 length);

    address public owner;

    constructor(address _owner) {
        owner = _owner;
    }

    /**
     * @notice Verifies that the signer is the owner of the signing contract.
     */
    function isValidSignature(bytes32 hash, bytes calldata signature) external view override returns (bytes4) {
        uint8 v;
        bytes32 r;
        bytes32 s;

        if (signature.length == 64) {
            bytes32 vs;
            assembly {
                r := calldataload(signature.offset)
                vs := calldataload(add(signature.offset, 0x20))
                s := and(vs, 0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff)
                v := add(shr(255, vs), 27)
            }
        } else if (signature.length == 65) {
            assembly {
                r := calldataload(signature.offset)
                s := calldataload(add(signature.offset, 0x20))
                v := byte(0, calldataload(add(signature.offset, 0x40)))
            }
        } else {
            revert SignatureLengthInvalid(signature.length);
        }

        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            revert SignatureParameterSInvalid();
        }

        if (v != 27 && v != 28) {
            revert SignatureParameterVInvalid(v);
        }

        address signer = ecrecover(hash, v, r, s);

        if (signer == owner) {
            return ERC1271_MAGIC_VALUE;
        } else {
            return 0xffffffff;
        }
    }
}
