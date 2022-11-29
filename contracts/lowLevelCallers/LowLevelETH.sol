// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

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
     * @dev It reverts if amount is equal to 0.
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
