// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "../errors/ETHTransferFail.sol";

/**
 * @title LowLevelETHReturnETHIfAnyExceptOneWei
 * @notice This contract contains a function to return all ETH except 1 wei held in a contract
 * @author LooksRare protocol team (👀,💎)
 */
contract LowLevelETHReturnETHIfAnyExceptOneWei {
    /**
     * @notice Return ETH to the original sender if any is left in the payable call but leave 1 wei of ETH in the contract.
     * @dev It does not revert if self balance is equal to 1 or 0.
     */
    function _returnETHIfAnyWithOneWeiLeft() internal {
        bool status = true;

        assembly {
            let selfBalance := selfbalance()
            if gt(selfBalance, 1) {
                status := call(gas(), caller(), sub(selfBalance, 1), 0, 0, 0, 0)
            }
        }

        if (!status) revert ETHTransferFail();
    }
}
