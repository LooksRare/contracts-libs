// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {ProtocolFee} from "../../contracts/ProtocolFee.sol";
import {TestHelpers} from "./utils/TestHelpers.sol";

contract ProtocolFeeContract is ProtocolFee {
    function updateProtocolFeeRecipient(address _protocolFeeRecipient) external override {
        _updateProtocolFeeRecipient(_protocolFeeRecipient);
    }

    function updateProtocolFeeBp(uint16 _protocolFeeBp) external override {
        _updateProtocolFeeBp(_protocolFeeBp);
    }
}

contract ProtocolFeeTest is TestHelpers {
    ProtocolFeeContract private protocolFee;

    event ProtocolFeeBpUpdated(uint16 protocolFeeBp);
    event ProtocolFeeRecipientUpdated(address protocolFeeRecipient);

    function setUp() public {
        protocolFee = new ProtocolFeeContract();
    }

    function test_setUpState() public {
        assertEq(protocolFee.protocolFeeRecipient(), address(0));
        assertEq(protocolFee.protocolFeeBp(), 0);
    }

    function test_updateProtocolFeeRecipient() public {
        vm.expectEmit({checkTopic1: true, checkTopic2: true, checkTopic3: true, checkData: true});
        emit ProtocolFeeRecipientUpdated(address(0x1));

        protocolFee.updateProtocolFeeRecipient(address(0x1));
        assertEq(protocolFee.protocolFeeRecipient(), address(0x1));
    }

    function test_updateProtocolFeeRecipient_RevertIf_InvalidValue() public {
        protocolFee.updateProtocolFeeRecipient(address(0x1));

        vm.expectRevert(ProtocolFee.ProtocolFee__InvalidValue.selector);
        protocolFee.updateProtocolFeeRecipient(address(0));
    }

    function test_updateProtocolFeeBp() public {
        vm.expectEmit({checkTopic1: true, checkTopic2: true, checkTopic3: true, checkData: true});
        emit ProtocolFeeBpUpdated(2_500);

        protocolFee.updateProtocolFeeBp(2_500);
        assertEq(protocolFee.protocolFeeBp(), 2_500);
    }

    function test_updateProtocolFeeBp_RevertIf_InvalidValue() public {
        vm.expectRevert(ProtocolFee.ProtocolFee__InvalidValue.selector);
        protocolFee.updateProtocolFeeBp(2_501);
    }
}
