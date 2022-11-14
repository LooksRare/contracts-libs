// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {LowLevelETH} from "../../contracts/lowLevelCallers/LowLevelETH.sol";
import {TestHelpers} from "./utils/TestHelpers.sol";

contract ImplementedLowLevelETH is LowLevelETH {
    function transferETH(address _to) external payable {
        _transferETH(_to, msg.value);
    }

    function transferETHAndReturnFunds() external payable {
        _returnETHIfAny();
    }

    function transferETHAndReturnFundsToSpecificAddress(address recipient) external payable {
        _returnETHIfAny(recipient);
    }

    function transferETHAndReturnFundsExceptOneWei() external payable {
        _returnETHIfAnyWithOneWeiLeft();
    }

    function transferETHAndReturnFundsExceptOneWeiToSpecificAddress(address recipient) external payable {
        _returnETHIfAnyWithOneWeiLeft(recipient);
    }
}

abstract contract TestParameters {
    address internal _sender = address(100);
    address internal _recipient = address(101);
    uint256 internal _GAS_LIMIT = 10000;
}

contract LowLevelETHTest is TestParameters, TestHelpers {
    ImplementedLowLevelETH public lowLevelETH;

    function setUp() external {
        lowLevelETH = new ImplementedLowLevelETH();
    }

    function testTransferETH(address randomSender, uint112 amount) external payable {
        vm.deal(randomSender, amount);
        vm.prank(randomSender);
        lowLevelETH.transferETH{value: amount}(_recipient);
        assertEq(_recipient.balance, amount);
    }

    function testTransferETHAndReturnFunds(uint112 amount) external payable asPrankedUser(_sender) {
        vm.deal(_sender, amount);
        lowLevelETH.transferETHAndReturnFunds{value: amount}();
        assertEq(_sender.balance, amount);
    }

    function testTransferETHAndReturnFundsToSpecificAddress(uint112 amount) external payable asPrankedUser(_sender) {
        vm.deal(_sender, amount);
        assertEq(_recipient.balance, 0);
        lowLevelETH.transferETHAndReturnFundsToSpecificAddress{value: amount}(_recipient);
        assertEq(_recipient.balance, amount);
    }

    function testTransferETHAndReturnFundsExceptOneWei(uint112 amount) external payable asPrankedUser(_sender) {
        vm.deal(_sender, amount);
        lowLevelETH.transferETHAndReturnFundsExceptOneWei{value: amount}();

        if (amount > 1) {
            assertEq(_sender.balance, amount - 1);
            assertEq(address(lowLevelETH).balance, 1);
        } else {
            assertEq(_sender.balance, 0);
            assertEq(address(lowLevelETH).balance, amount);
        }
    }

    function testTransferETHAndReturnFundsExceptOneWeiToSpecificAddress(uint112 amount)
        external
        payable
        asPrankedUser(_sender)
    {
        vm.deal(_sender, amount);
        lowLevelETH.transferETHAndReturnFundsExceptOneWeiToSpecificAddress{value: amount}(_recipient);

        if (amount > 1) {
            assertEq(_recipient.balance, amount - 1);
            assertEq(address(lowLevelETH).balance, 1);
        } else {
            assertEq(_recipient.balance, 0);
            assertEq(address(lowLevelETH).balance, amount);
        }
    }
}
