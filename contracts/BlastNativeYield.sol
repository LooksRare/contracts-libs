// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {IBlast, YieldMode, GasMode} from "./interfaces/IBlast.sol";
import {BlastPoints} from "./BlastPoints.sol";

/**
 * @title BlastNativeYield
 * @notice This contract is a base contract for inheriting functions to claim native yield and for those that wish to recieve Blast points
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
        IBlast(_blast).configure(YieldMode.CLAIMABLE, GasMode.CLAIMABLE, _governor);
    }
}
