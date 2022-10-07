// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import {IERC20} from "../interfaces/generic/IERC20.sol";

/**
 * @title LowLevelERC20Approve
 * @notice This contract contains low-level calls to transfer ERC20 tokens.
 * @author LooksRare protocol team (👀,💎)
 */
contract LowLevelERC20Approve {
    error ERC20ApprovalFail();

    /**
     * @notice Execute ERC20 approve
     * @param currency Currency address
     * @param to Operator address
     * @param amount Amount to approve
     */
    function _executeERC20Approve(
        address currency,
        address to,
        uint256 amount
    ) internal {
        (bool status, bytes memory data) = currency.call(abi.encodeWithSelector(IERC20.approve.selector, to, amount));

        if (!status) revert ERC20ApprovalFail();
        if (data.length > 0) {
            if (!abi.decode(data, (bool))) revert ERC20ApprovalFail();
        }
    }
}
