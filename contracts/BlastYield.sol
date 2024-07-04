// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {IBlast, YieldMode as IBlast__YieldMode, GasMode as IBlast__GasMode} from "./interfaces/IBlast.sol";
import {IBlastPoints} from "./interfaces/IBlastPoints.sol";
import {IERC20Rebasing, YieldMode as IERC20Rebasing__YieldMode} from "./interfaces/IERC20Rebasing.sol";

/**
 * @title BlastYield
 * @notice This contract is a base contract for future contracts that wish to claim Blast WETH or USDB yield to inherit from.
 * @author LooksRare protocol team (👀,💎)
 */
contract BlastYield {
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
    ) {
        WETH = _weth;
        USDB = _usdb;

        IBlast(_blast).configure(IBlast__YieldMode.CLAIMABLE, IBlast__GasMode.CLAIMABLE, _governor);
        IBlastPoints(_blastPoints).configurePointsOperator(_blastPointsOperator);
        IERC20Rebasing(_weth).configure(IERC20Rebasing__YieldMode.CLAIMABLE);
        IERC20Rebasing(_usdb).configure(IERC20Rebasing__YieldMode.CLAIMABLE);
    }

    /**
     * @notice Claim Blast yield. Guarding of the function is dependent on the inherited contract.
     * @param wethReceiver The receiver of WETH.
     * @param usdbReceiver The receiver of USDB.
     */
    function _claim(address wethReceiver, address usdbReceiver) internal {
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
