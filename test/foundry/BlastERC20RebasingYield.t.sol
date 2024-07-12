// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {IOwnableTwoSteps} from "../../contracts/interfaces/IOwnableTwoSteps.sol";
import {OwnableTwoSteps} from "../../contracts/OwnableTwoSteps.sol";
import {BlastERC20RebasingYield} from "../../contracts/BlastERC20RebasingYield.sol";
import {TestHelpers} from "./utils/TestHelpers.sol";
import {YieldMode} from "../../contracts/interfaces/IERC20Rebasing.sol";

import {MockBlastERC20} from "../mock/MockBlastERC20.sol";
import {MockBlastPoints} from "../mock/MockBlastPoints.sol";
import {MockBlastWETH} from "../mock/MockBlastWETH.sol";
import {MockBlastYield} from "../mock/MockBlastYield.sol";

contract BlastERC20RebasingYieldGuarded is BlastERC20RebasingYield, OwnableTwoSteps {
    constructor(
        address _blast,
        address _blastPoints,
        address _blastPointsOperator,
        address _owner,
        address _usdb,
        address _weth
    )
        BlastERC20RebasingYield(_blast, _blastPoints, _blastPointsOperator, _owner, _usdb, _weth)
        OwnableTwoSteps(_owner)
    {}

    function claim(address wethReceiver, address usdbReceiver) public onlyOwner {
        _claimERC20RebasingYield(wethReceiver, usdbReceiver);
    }
}

contract BlastERC20RebasingYield_Test is TestHelpers {
    MockBlastWETH private weth;
    MockBlastERC20 private usdb;
    MockBlastYield private mockBlastYield;
    MockBlastPoints private mockBlastPoints;
    BlastERC20RebasingYieldGuarded private blastERC20RebasingYieldGuarded;

    address public owner = address(69);
    address public operator = address(420);
    address public user1 = address(1);
    address private constant TREASURY = address(69420);

    function setUp() public {
        weth = new MockBlastWETH();
        usdb = new MockBlastERC20("USDB", "USDB");
        mockBlastYield = new MockBlastYield();
        mockBlastPoints = new MockBlastPoints();
        blastERC20RebasingYieldGuarded = new BlastERC20RebasingYieldGuarded(
            address(mockBlastYield),
            address(mockBlastPoints),
            operator,
            owner,
            address(usdb),
            address(weth)
        );
    }

    function test_setUpState() public {
        assertEq(blastERC20RebasingYieldGuarded.WETH(), address(weth));
        assertEq(blastERC20RebasingYieldGuarded.USDB(), address(usdb));

        YieldMode wethYieldMode = weth.yieldMode(address(blastERC20RebasingYieldGuarded));
        assertEq(uint8(wethYieldMode), uint8(YieldMode.CLAIMABLE));

        YieldMode usdbYieldMode = usdb.yieldMode(address(blastERC20RebasingYieldGuarded));
        assertEq(uint8(usdbYieldMode), uint8(YieldMode.CLAIMABLE));
    }

    function test_claim() public asPrankedUser(owner) {
        blastERC20RebasingYieldGuarded.claim(TREASURY, TREASURY);

        assertEq(weth.balanceOf(address(blastERC20RebasingYieldGuarded)), 0);
        assertEq(usdb.balanceOf(address(blastERC20RebasingYieldGuarded)), 0);
        assertEq(weth.balanceOf(TREASURY), 1 ether);
        assertEq(usdb.balanceOf(TREASURY), 1 ether);
    }

    function test_claim_RevertIf_NotOwner() public asPrankedUser(user1) {
        vm.expectRevert(IOwnableTwoSteps.NotOwner.selector);
        blastERC20RebasingYieldGuarded.claim(TREASURY, TREASURY);
    }
}
