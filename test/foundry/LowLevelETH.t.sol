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

contract AlwaysReject {
    ImplementedLowLevelETH lowLevelETH;

    error NoMeGustaDinero();

    constructor(ImplementedLowLevelETH _lowLevelETH) {
        lowLevelETH = _lowLevelETH;
    }

    function transferETHAndReturnFunds() external payable {
        lowLevelETH.transferETHAndReturnFunds{value: msg.value}();
    }

    function transferETHAndReturnFundsExceptOneWei() external payable {
        lowLevelETH.transferETHAndReturnFundsExceptOneWei{value: msg.value}();
    }

    receive() external payable {
        revert NoMeGustaDinero();
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

    function testTransferETH(address randomSender, uint112 amount) external {
        vm.assume(amount > 0);
        vm.deal(randomSender, amount);
        vm.prank(randomSender);
        lowLevelETH.transferETH{value: amount}(_recipient);
        assertEq(_recipient.balance, amount);
    }

    function testTransferETHFail(address randomSender, uint112 amount) external {
        // The test starts failing with OutOfFund when amount == 79228162514264337593543950336,
        // some truncation issues.
        vm.assume(amount < 79228162514264337593543950336);
        vm.deal(randomSender, amount);
        vm.prank(randomSender);
        AlwaysReject alwaysReject = new AlwaysReject(lowLevelETH);
        vm.expectRevert(LowLevelETH.ETHTransferFail.selector);
        lowLevelETH.transferETH{value: amount}(address(alwaysReject));
    }

    function testTransferETHAndReturnFunds(uint112 amount) external asPrankedUser(_sender) {
        vm.assume(amount > 0);
        vm.deal(_sender, amount);
        lowLevelETH.transferETHAndReturnFunds{value: amount}();
        assertEq(_sender.balance, amount);
    }

    function testTransferETHAndReturnFundsFail(uint112 amount) external asPrankedUser(_sender) {
        vm.deal(_sender, amount);
        AlwaysReject alwaysReject = new AlwaysReject(lowLevelETH);
        vm.expectRevert(LowLevelETH.ETHTransferFail.selector);
        alwaysReject.transferETHAndReturnFunds{value: amount}();
    }

    function testTransferETHAndReturnFundsToSpecificAddress(uint112 amount) external asPrankedUser(_sender) {
        vm.assume(amount > 0);
        vm.deal(_sender, amount);
        assertEq(_recipient.balance, 0);
        lowLevelETH.transferETHAndReturnFundsToSpecificAddress{value: amount}(_recipient);
        assertEq(_recipient.balance, amount);
    }

    function testTransferETHAndReturnFundsToSpecificAddressFail(uint112 amount) external asPrankedUser(_sender) {
        vm.deal(_sender, amount);
        AlwaysReject alwaysReject = new AlwaysReject(lowLevelETH);
        vm.expectRevert(LowLevelETH.ETHTransferFail.selector);
        lowLevelETH.transferETHAndReturnFundsToSpecificAddress{value: amount}(address(alwaysReject));
    }

    function testTransferETHAndReturnFundsExceptOneWei(uint112 amount) external asPrankedUser(_sender) {
        vm.deal(_sender, amount);

        if (amount > 1) {
            lowLevelETH.transferETHAndReturnFundsExceptOneWei{value: amount}();
            assertEq(_sender.balance, amount - 1);
            assertEq(address(lowLevelETH).balance, 1);
        } else {
            vm.expectRevert(LowLevelETH.ETHTransferFail.selector);
            lowLevelETH.transferETHAndReturnFundsExceptOneWei{value: amount}();
        }
    }

    function testTransferETHAndReturnFundsExceptOneWeiFail(uint112 amount) external asPrankedUser(_sender) {
        vm.assume(amount > 1);
        vm.deal(_sender, amount);
        AlwaysReject alwaysReject = new AlwaysReject(lowLevelETH);
        vm.expectRevert(LowLevelETH.ETHTransferFail.selector);
        alwaysReject.transferETHAndReturnFundsExceptOneWei{value: amount}();
    }

    function testTransferETHAndReturnFundsExceptOneWeiToSpecificAddress(uint112 amount)
        external
        asPrankedUser(_sender)
    {
        vm.deal(_sender, amount);

        if (amount > 1) {
            lowLevelETH.transferETHAndReturnFundsExceptOneWeiToSpecificAddress{value: amount}(_recipient);
            assertEq(_recipient.balance, amount - 1);
            assertEq(address(lowLevelETH).balance, 1);
        } else {
            vm.expectRevert(LowLevelETH.ETHTransferFail.selector);
            lowLevelETH.transferETHAndReturnFundsExceptOneWeiToSpecificAddress{value: amount}(_recipient);
        }
    }

    function testTransferETHAndReturnFundsExceptOneWeiToSpecificAddressFail(uint112 amount)
        external
        asPrankedUser(_sender)
    {
        vm.assume(amount > 1);
        vm.deal(_sender, amount);
        AlwaysReject alwaysReject = new AlwaysReject(lowLevelETH);
        vm.expectRevert(LowLevelETH.ETHTransferFail.selector);
        lowLevelETH.transferETHAndReturnFundsExceptOneWeiToSpecificAddress{value: amount}(address(alwaysReject));
    }
}
