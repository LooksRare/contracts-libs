// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {Faucet} from "./Faucet.sol";

contract ReentrancyCaller {
    uint256 private _counter;
    Faucet public faucet;

    constructor(address _faucet) {
        faucet = Faucet(_faucet);
    }

    receive() external payable {
        if (_counter++ < 5) {
            faucet.claim();
        }
    }

    function claim() external {
        faucet.claim();
        // reset counter
        _counter = 0;
    }
}
