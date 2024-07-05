// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {IBlast, YieldMode as IBlast__YieldMode, GasMode as IBlast__GasMode} from "./interfaces/IBlast.sol";
import {BlastPoints} from "./BlastPoints.sol";
/**
 * @title BlastNativeYield
 * @notice This contract is a base contract for future contracts that wish to claim native yield and Blast points to inherit from
 * @author LooksRare protocol team (👀,💎)
 */
contract BlastNativeYield is BlastPoints {
    /**
     * @param _blast Blast precompile
     * @param _blastPoints Blast points
     * @param _blastPointsOperator Blast points operator
     * @param _governor The address that’s allowed to claim the contract’s yield and gas
     */
    constructor(
        address _blast,
        address _blastPoints,
        address _blastPointsOperator,
        address _governor
    ) BlastPoints(_blastPoints, _blastPointsOperator) {
        IBlast(_blast).configure(IBlast__YieldMode.CLAIMABLE, IBlast__GasMode.CLAIMABLE, _governor);
    }
}
