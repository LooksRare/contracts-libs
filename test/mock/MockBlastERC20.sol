// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import {YieldMode} from "../../contracts/interfaces/IERC20Rebasing.sol";

contract MockBlastERC20 is ERC20 {
    mapping(address _contract => YieldMode) public yieldMode;

    constructor(string memory _name, string memory _symbol) ERC20(_name, _symbol) {}

    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }

    function configure(YieldMode _yieldMode) external returns (uint256) {
        yieldMode[msg.sender] = _yieldMode;
        return uint256(_yieldMode);
    }

    function getClaimableAmount(address) external pure returns (uint256) {
        return 1 ether;
    }

    function claim(address receiver, uint256 amount) external returns (uint256) {
        _mint(receiver, amount);
        return amount;
    }
}
