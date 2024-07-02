// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {YieldMode, GasMode} from "../../../contracts/interfaces/IBlast.sol";

contract MockYield {
    struct Config {
        YieldMode yieldMode;
        GasMode gasMode;
        address governor;
    }

    mapping(address => Config) public config;

    function configure(YieldMode _yield, GasMode _gasMode, address _governor) external {
        config[msg.sender] = Config(_yield, _gasMode, _governor);
    }
}
