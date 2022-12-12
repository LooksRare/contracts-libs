// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "../errors/ETHTransferFail.sol";

/**
 * @title LowLevelETHReturnETHIfAny
 * @notice This contract contains a function to return all ETH held in a contract
 * @author LooksRare protocol team (👀,💎)
 */
contract LowLevelETHReturnETHIfAny {
    /**
     * @notice Return ETH back to the original sender if any ETH is left in the payable call.
     * @dev It does not revert if self balance is equal to 0.
     */
    function _returnETHIfAny() internal {
        bool status = true;

        assembly {
            let selfBalance := selfbalance()
            if gt(selfBalance, 0) {
                status := call(gas(), caller(), selfBalance, 0, 0, 0, 0)
            }
        }

        if (!status) revert ETHTransferFail();
    }
}
