// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {IBlastPoints} from "./interfaces/IBlastPoints.sol";

/**
 * @title BlastPoints
 * @notice This contract is a base contract for future contracts that wish to claim Blast points to inherit from
 * @author LooksRare protocol team (👀,💎)
 */
contract BlastPoints {
    /**
     * @param _blastPoints Blast points
     * @param _blastPointsOperator Blast points operator
     */
    constructor(address _blastPoints, address _blastPointsOperator) {
        IBlastPoints(_blastPoints).configurePointsOperator(_blastPointsOperator);
    }
}
