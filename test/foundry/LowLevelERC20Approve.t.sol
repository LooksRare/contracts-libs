// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {LowLevelERC20Approve} from "../../contracts/lowLevelCallers/LowLevelERC20Approve.sol";
import {NotAContract} from "../../contracts/errors/GenericErrors.sol";
import {ERC20ApprovalFail} from "../../contracts/errors/LowLevelErrors.sol";
import {MockERC20} from "../mock/MockERC20.sol";
import {MockERC1155} from "../mock/MockERC1155.sol";
import {TestHelpers} from "./utils/TestHelpers.sol";

contract ImplementedLowLevelERC20Approve is LowLevelERC20Approve {
    function approveERC20(
        address currency,
        address to,
        uint256 amount
    ) external {
        _executeERC20Approve(currency, to, amount);
    }
}

abstract contract TestParameters {
    address internal _sender = address(100);
    address internal _operator = address(102);
}

contract LowLevelERC20ApproveTest is TestHelpers, TestParameters {
    ImplementedLowLevelERC20Approve public lowLevelERC20Approve;
    MockERC20 public mockERC20;

    function setUp() external {
        lowLevelERC20Approve = new ImplementedLowLevelERC20Approve();
        mockERC20 = new MockERC20();
    }

    function testApproveERC20(uint256 amount) external {
        lowLevelERC20Approve.approveERC20(address(mockERC20), _operator, amount);
        assertEq(mockERC20.allowance(address(lowLevelERC20Approve), _operator), amount);
    }

    function testApproveERC20NotAContract(uint256 amount) external {
        vm.expectRevert(NotAContract.selector);
        lowLevelERC20Approve.approveERC20(address(0), _operator, amount);
    }

    function testApproveERC20WithERC1155Fails(uint256 amount) external {
        MockERC1155 mockERC1155 = new MockERC1155();
        vm.expectRevert(ERC20ApprovalFail.selector);
        lowLevelERC20Approve.approveERC20(address(mockERC1155), _operator, amount);
    }
}
