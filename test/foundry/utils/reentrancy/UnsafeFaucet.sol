// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {Faucet} from "./Faucet.sol";

contract UnsafeFaucet is Faucet {
    function claim() external override {
        _claim();
    }
}
