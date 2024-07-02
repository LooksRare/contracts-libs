// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {BlastYield} from "../../contracts/BlastYield.sol";
import {Test} from "../../lib/forge-std/src/Test.sol";
import {YieldMode as IBlast__YieldMode, GasMode as IBlast__GasMode} from "../../contracts/interfaces/IBlast.sol";
import {YieldMode as IERC20Rebasing__YieldMode} from "../../contracts/interfaces/IERC20Rebasing.sol";

import {MockERC20} from "../mock/MockBlastERC20.sol";
import {MockPoints} from "../mock/MockBlastPoints.sol";
import {MockWETH} from "../mock/MockBlastWETH.sol";
import {MockYield} from "../mock/MockBlastYield.sol";

contract BlastYield_Test is Test {
    MockWETH private weth;
    MockERC20 private usdb;
    MockYield private mockYield;
    MockPoints private mockPoints;
    BlastYield private blastYield;

    address public owner = address(69);
    address public operator = address(420);
    address private constant TREASURY = address(69420);
    address internal constant BLAST = 0x4300000000000000000000000000000000000002;
    address internal constant BLAST_POINTS = 0x2536FE9ab3F511540F2f9e2eC2A805005C3Dd800;

    function setUp() public {
        vm.etch(BLAST, address(new MockYield()).code);
        vm.etch(BLAST_POINTS, address(new MockPoints()).code);
        weth = new MockWETH();
        usdb = new MockERC20("USDB", "USDB");
        blastYield = new BlastYield(BLAST, BLAST_POINTS, operator, owner, address(usdb), address(weth));
    }

    function test_setUpState() public {
        assertEq(blastYield.WETH(), address(weth));
        assertEq(blastYield.USDB(), address(usdb));
        assertTrue(blastYield.hasRole(bytes32(0), owner));
        assertTrue(blastYield.hasRole(keccak256("OPERATOR_ROLE"), owner));
        assertTrue(blastYield.hasRole(keccak256("OPERATOR_ROLE"), operator));

        (IBlast__YieldMode yieldMode, IBlast__GasMode gasMode, address governor) = mockYield.config(
            address(blastYield)
        );
        assertEq(uint8(yieldMode), uint8(IBlast__YieldMode.CLAIMABLE));
        assertEq(uint8(gasMode), uint8(IBlast__GasMode.CLAIMABLE));
        assertEq(governor, owner);

        IERC20Rebasing__YieldMode wethYieldMode = weth.yieldMode(address(blastYield));
        assertEq(uint8(wethYieldMode), uint8(IERC20Rebasing__YieldMode.CLAIMABLE));

        IERC20Rebasing__YieldMode usdbYieldMode = usdb.yieldMode(address(blastYield));
        assertEq(uint8(usdbYieldMode), uint8(IERC20Rebasing__YieldMode.CLAIMABLE));
    }

    function test_claim() public {
        vm.startPrank(owner);
        blastYield.claim(TREASURY, TREASURY);

        vm.stopPrank();

        assertEq(weth.balanceOf(address(blastYield)), 0);
        assertEq(usdb.balanceOf(address(blastYield)), 0);
        assertEq(weth.balanceOf(TREASURY), 1 ether);
        assertEq(usdb.balanceOf(TREASURY), 1 ether);
    }

    function test_claim_RevertIf_NotOwner() public {
        vm.expectRevert(
            abi.encodePacked(
                "AccessControl: account 0xb4c79dab8f259c7aee6e5b2aa729821864227e84 is missing role 0x0000000000000000000000000000000000000000000000000000000000000000"
            )
        );
        blastYield.claim(TREASURY, TREASURY);
    }
}
