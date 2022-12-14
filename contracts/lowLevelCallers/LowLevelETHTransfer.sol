// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "../errors/ETHTransferFail.sol";

/**
 * @title LowLevelETHTransfer
 * @notice This contract contains a low-level transfer function for ETH.
 * @author LooksRare protocol team (👀,💎)
 */
contract LowLevelETHTransfer {
    /**
     * @notice Transfer ETH to a recipient address
     * @param _to Recipient address
     * @param _amount Amount to transfer
     * @dev It reverts if amount is equal to 0.
     */
    function _transferETH(address _to, uint256 _amount) internal {
        bool status;

        assembly {
            status := call(gas(), _to, _amount, 0, 0, 0, 0)
        }

        if (!status) revert ETHTransferFail();
    }
}
