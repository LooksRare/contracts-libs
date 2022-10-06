// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {LowLevelERC20} from "../../contracts/lowLevelCallers/LowLevelERC20.sol";
import {MockERC20} from "../mock/MockERC20.sol";
import {TestHelpers} from "./utils/TestHelpers.sol";

contract ImplementedLowLevelERC20 is LowLevelERC20 {
    function approveERC20(
        address currency,
        address to,
        uint256 amount
    ) external {
        _executeERC20Approve(currency, to, amount);
    }

    function transferERC20(
        address currency,
        address to,
        uint256 amount
    ) external {
        _executeERC20DirectTransfer(currency, to, amount);
    }

    function transferFromERC20(
        address currency,
        address from,
        address to,
        uint256 amount
    ) external {
        _executeERC20TransferFrom(currency, from, to, amount);
    }
}

abstract contract TestParameters {
    address internal _sender = address(100);
    address internal _recipient = address(101);
    address internal _operator = address(102);
}

contract LowLevelERC20Test is TestHelpers, TestParameters {
    ImplementedLowLevelERC20 public lowLevelERC20;
    MockERC20 public mockERC20;

    function setUp() external {
        lowLevelERC20 = new ImplementedLowLevelERC20();
        mockERC20 = new MockERC20();
    }

    function testApproveERC20(uint256 amount) external {
        lowLevelERC20.approveERC20(address(mockERC20), _operator, amount);
        assertEq(mockERC20.allowance(address(lowLevelERC20), _operator), amount);
    }

    function testTransferFromERC20(uint256 amount) external asPrankedUser(_sender) {
        mockERC20.mint(_sender, amount);
        mockERC20.approve(address(lowLevelERC20), amount);
        lowLevelERC20.transferFromERC20(address(mockERC20), _sender, _recipient, amount);
        assertEq(mockERC20.balanceOf(_recipient), amount);
    }

    function testTransferERC20(uint256 amount) external asPrankedUser(_sender) {
        mockERC20.mint(address(lowLevelERC20), amount);
        lowLevelERC20.transferERC20(address(mockERC20), _recipient, amount);
        assertEq(mockERC20.balanceOf(_recipient), amount);
    }
}
