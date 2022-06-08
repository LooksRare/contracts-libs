// SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

import {IERC1271} from "../../../contracts/interfaces/IERC1271.sol";

contract ERC1271Contract is IERC1271 {
    // Custom errors
    error BadSignatureS();
    error BadSignatureV(uint8 v);
    error WrongSignatureLength(uint256 length);

    address public owner;

    // bytes4(keccak256("isValidSignature(bytes32,bytes)")
    bytes4 internal constant MAGICVALUE = 0x1626ba7e;

    constructor(address _owner) {
        owner = _owner;
    }

    /**
     * @notice Verifies that the signer is the owner of the signing contract.
     */
    function isValidSignature(bytes32 hash, bytes memory signature) external view override returns (bytes4) {
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

        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            revert BadSignatureS();
        }

        if (v != 27 && v != 28) {
            revert BadSignatureV(v);
        }

        address signer = ecrecover(hash, v, r, s);

        if (signer == owner) {
            return MAGICVALUE;
        } else {
            return 0xffffffff;
        }
    }
}
