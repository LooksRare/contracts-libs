// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import {IWETH} from "../interfaces/generic/IWETH.sol";

/**
 * @title LowLevelETH
 * @notice This contract contains low-level calls to transfer ETH.
 * @author LooksRare protocol team (👀,💎)
 */
contract LowLevelETH {
    error ETHTransferFail();

    /**
     * @notice Transfer ETH to a recipient address
     * @param _to Recipient address
     * @param _amount Amount to transfer
     */
    function _transferETH(address _to, uint256 _amount) internal {
        bool status;

        assembly {
            status := call(gas(), _to, _amount, 0, 0, 0, 0)
        }

        if (!status) revert ETHTransferFail();
    }

    /**
     * @notice Return ETH back to the original sender if any ETH is left in the payable call.
     */
    function _returnETHIfAny() internal {
        bool status;

        assembly {
            if gt(selfbalance(), 0) {
                status := call(gas(), caller(), selfbalance(), 0, 0, 0, 0)
            }
        }

        if (!status) revert ETHTransferFail();
    }

    /**
     * @notice Return ETH back to the designated recipient if any ETH is left in the payable call.
     */
    function _returnETHIfAny(address recipient) internal {
        bool status;

        assembly {
            if gt(selfbalance(), 0) {
                status := call(gas(), recipient, selfbalance(), 0, 0, 0, 0)
            }
        }

        if (!status) revert ETHTransferFail();
    }

    /**
     * @notice Return ETH to the original sender if any is left in the payable call but leave 1 wei of ETH in the contract.
     */
    function _returnETHIfAnyWithOneWeiLeft() internal {
        bool status;

        assembly {
            if gt(selfbalance(), 1) {
                status := call(gas(), caller(), sub(selfbalance(), 1), 0, 0, 0, 0)
            }
        }

        if (!status) revert ETHTransferFail();
    }

    /**
     * @notice Return ETH to the designated recipient if any is left in the payable call but leave 1 wei of ETH in the contract.
     */
    function _returnETHIfAnyWithOneWeiLeft(address recipient) internal {
        bool status;

        assembly {
            if gt(selfbalance(), 1) {
                status := call(gas(), recipient, sub(selfbalance(), 1), 0, 0, 0, 0)
            }
        }

        if (!status) revert ETHTransferFail();
    }
}
