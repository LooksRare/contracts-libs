// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {BlastNativeYield} from "./BlastNativeYield.sol";
import {IERC20Rebasing, YieldMode} from "./interfaces/IERC20Rebasing.sol";

/**
 * @title BlastERC20RebasingYield
 * @notice This contract is a base contract for inheriting functions to claim Blast WETH or USDB yield
 * @author LooksRare protocol team (👀,💎)
 */
contract BlastERC20RebasingYield is BlastNativeYield {
    address public immutable WETH;
    address public immutable USDB;

    /**
     * @param _blast Blast precompile
     * @param _blastPoints Blast points
     * @param _blastPointsOperator Blast points operator
     * @param _governor The address that’s allowed to claim the contract’s yield and gas
     * @param _usdb USDB address
     * @param _weth WETH address
     */
    constructor(
        address _blast,
        address _blastPoints,
        address _blastPointsOperator,
        address _governor,
        address _usdb,
        address _weth
    ) BlastNativeYield(_blast, _blastPoints, _blastPointsOperator, _governor) {
        WETH = _weth;
        USDB = _usdb;

        IERC20Rebasing(_weth).configure(YieldMode.CLAIMABLE);
        IERC20Rebasing(_usdb).configure(YieldMode.CLAIMABLE);
    }

    /**
     * @notice Claim Blast yield. Guarding of the function is dependent on the inherited contract.
     *         Inheriting does not allow claiming by default.
     *         A public or external function is required in the child contract to access the _claim function.
     * @param wethReceiver The receiver of WETH.
     * @param usdbReceiver The receiver of USDB.
     */
    function _claimERC20RebasingYield(address wethReceiver, address usdbReceiver) internal {
        uint256 claimableWETH = IERC20Rebasing(WETH).getClaimableAmount(address(this));
        if (claimableWETH != 0) {
            IERC20Rebasing(WETH).claim(wethReceiver, claimableWETH);
        }

        uint256 claimableUSDB = IERC20Rebasing(USDB).getClaimableAmount(address(this));
        if (claimableUSDB != 0) {
            IERC20Rebasing(USDB).claim(usdbReceiver, claimableUSDB);
        }
    }
}
