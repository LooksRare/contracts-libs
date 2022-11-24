// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {LowLevelERC20Transfer} from "../../contracts/lowLevelCallers/LowLevelERC20Transfer.sol";
import {NotAContract} from "../../contracts/Errors.sol";
import {MockERC20} from "../mock/MockERC20.sol";
import {TestHelpers} from "./utils/TestHelpers.sol";

contract ImplementedLowLevelERC20Transfer is LowLevelERC20Transfer {
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
}

contract LowLevelERC20TransferTest is TestHelpers, TestParameters {
    ImplementedLowLevelERC20Transfer public lowLevelERC20Transfer;
    MockERC20 public mockERC20;

    function setUp() external {
        lowLevelERC20Transfer = new ImplementedLowLevelERC20Transfer();
        mockERC20 = new MockERC20();
    }

    function testTransferFromERC20(uint256 amount) external asPrankedUser(_sender) {
        mockERC20.mint(_sender, amount);
        mockERC20.approve(address(lowLevelERC20Transfer), amount);
        lowLevelERC20Transfer.transferFromERC20(address(mockERC20), _sender, _recipient, amount);
        assertEq(mockERC20.balanceOf(_recipient), amount);
    }

    function testTransferERC20(uint256 amount) external asPrankedUser(_sender) {
        mockERC20.mint(address(lowLevelERC20Transfer), amount);
        lowLevelERC20Transfer.transferERC20(address(mockERC20), _recipient, amount);
        assertEq(mockERC20.balanceOf(_recipient), amount);
    }

    function testTransferFromERC20NotAContract(uint256 amount) external asPrankedUser(_sender) {
        vm.expectRevert(NotAContract.selector);
        lowLevelERC20Transfer.transferFromERC20(address(0), _sender, _recipient, amount);
    }

    function testTransferERC20NotAContract(uint256 amount) external asPrankedUser(_sender) {
        vm.expectRevert(NotAContract.selector);
        lowLevelERC20Transfer.transferERC20(address(0), _recipient, amount);
    }
}
