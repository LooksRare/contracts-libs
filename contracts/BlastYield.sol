// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {IBlast, YieldMode as IBlast__YieldMode, GasMode as IBlast__GasMode} from "./interfaces/IBlast.sol";
import {IBlastPoints} from "./interfaces/IBlastPoints.sol";
import {IERC20Rebasing, YieldMode as IERC20Rebasing__YieldMode} from "./interfaces/IERC20Rebasing.sol";

/**
 * @title BlastYield
 * @notice This contract is a base contract for future contracts that wish to claim Blast WETH or USDB yield to inherit from.
 * @author LooksRare protocol team (👀,💎)
 */
contract BlastYield is AccessControl {
    address public immutable WETH;
    address public immutable USDB;

    /**
     * @param _blast Blast precompile
     * @param _blastPoints Blast points
     * @param _blastPointsOperator Blast points operator
     * @param _owner Owner of the contract
     * @param _usdb USDB address
     * @param _weth WETH address
     */
    constructor(
        address _blast,
        address _blastPoints,
        address _blastPointsOperator,
        address _owner,
        address _usdb,
        address _weth
    ) {
        _grantRole(DEFAULT_ADMIN_ROLE, _owner);

        WETH = _weth;
        USDB = _usdb;

        IBlast(_blast).configure(IBlast__YieldMode.CLAIMABLE, IBlast__GasMode.CLAIMABLE, _owner);
        IBlastPoints(_blastPoints).configurePointsOperator(_blastPointsOperator);
        IERC20Rebasing(_weth).configure(IERC20Rebasing__YieldMode.CLAIMABLE);
        IERC20Rebasing(_usdb).configure(IERC20Rebasing__YieldMode.CLAIMABLE);
    }

    /**
     * @notice Claim Blast yield. Only callable by contract owner.
     * @param wethReceiver The receiver of WETH.
     * @param usdbReceiver The receiver of USDB.
     */
    function claim(address wethReceiver, address usdbReceiver) external virtual onlyRole(DEFAULT_ADMIN_ROLE) {
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
