// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

// Assembly constants
import {ETHTransferFail_error_selector, ETHTransferFail_error_length, Error_selector_offset} from "../constants/AssemblyConstants.sol";

/**
 * @title LowLevelETHReturnETHIfAny
 * @notice This contract contains a function to return all ETH held in a contract.
 * @author LooksRare protocol team (👀,💎)
 */
contract LowLevelETHReturnETHIfAny {
    /**
     * @notice It returns ETH back to the original sender if any ETH is left in the payable call.
     * @dev It does not revert if self balance is equal to 0.
     */
    function _returnETHIfAny() internal {
        assembly {
            let selfBalance := selfbalance()
            if gt(selfBalance, 0) {
                let status := call(gas(), caller(), selfBalance, 0, 0, 0, 0)
                if iszero(status) {
                    mstore(0x00, ETHTransferFail_error_selector)
                    revert(Error_selector_offset, ETHTransferFail_error_length)
                }
            }
        }
    }
}
