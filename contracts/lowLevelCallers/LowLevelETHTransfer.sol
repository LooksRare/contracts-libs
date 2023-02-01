// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

// Assembly constants
import {ETHTransferFail_error_selector, ETHTransferFail_error_length, Error_selector_offset} from "../constants/AssemblyConstants.sol";

/**
 * @title LowLevelETHTransfer
 * @notice This contract contains a low-level transfer function for ETH.
 * @author LooksRare protocol team (👀,💎)
 */
contract LowLevelETHTransfer {
    /**
     * @notice It transfers ETH to a recipient address.
     * @param _to Recipient address
     * @param _amount Amount to transfer
     * @dev It reverts if amount is equal to 0.
     */
    function _transferETH(address _to, uint256 _amount) internal {
        assembly {
            let status := call(gas(), _to, _amount, 0, 0, 0, 0)

            if iszero(status) {
                mstore(0x00, ETHTransferFail_error_selector)
                revert(Error_selector_offset, ETHTransferFail_error_length)
            }
        }
    }
}
