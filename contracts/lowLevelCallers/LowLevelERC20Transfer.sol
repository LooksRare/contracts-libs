// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {IERC20} from "../interfaces/generic/IERC20.sol";
import {NotAContract} from "../errors/GenericErrors.sol";

/**
 * @title LowLevelERC20Transfer
 * @notice This contract contains low-level calls to transfer ERC20 tokens.
 * @author LooksRare protocol team (👀,💎)
 */
contract LowLevelERC20Transfer {
    error ERC20TransferFail();
    error ERC20TransferFromFail();

    /**
     * @notice Execute ERC20 transferFrom
     * @param currency Currency address
     * @param from Sender address
     * @param to Recipient address
     * @param amount Amount to transfer
     */
    function _executeERC20TransferFrom(
        address currency,
        address from,
        address to,
        uint256 amount
    ) internal {
        if (currency.code.length == 0) revert NotAContract();

        (bool status, bytes memory data) = currency.call(
            abi.encodeWithSelector(IERC20.transferFrom.selector, from, to, amount)
        );

        if (!status) revert ERC20TransferFromFail();
        if (data.length > 0) {
            if (!abi.decode(data, (bool))) revert ERC20TransferFromFail();
        }
    }

    /**
     * @notice Execute ERC20 (direct) transfer
     * @param currency Currency address
     * @param to Recipient address
     * @param amount Amount to transfer
     */
    function _executeERC20DirectTransfer(
        address currency,
        address to,
        uint256 amount
    ) internal {
        if (currency.code.length == 0) revert NotAContract();

        (bool status, bytes memory data) = currency.call(abi.encodeWithSelector(IERC20.transfer.selector, to, amount));

        if (!status) revert ERC20TransferFail();
        if (data.length > 0) {
            if (!abi.decode(data, (bool))) revert ERC20TransferFail();
        }
    }
}
