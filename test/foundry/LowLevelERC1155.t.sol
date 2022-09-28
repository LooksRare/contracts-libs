// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {LowLevelERC1155} from "../../contracts/lowLevelCallers/LowLevelERC1155.sol";
import {MockERC1155} from "../mock/MockERC1155.sol";
import {TestHelpers} from "./utils/TestHelpers.sol";

contract ImplementedLowLevelERC1155 is LowLevelERC1155 {
    function safeTransferFromERC1155(
        address collection,
        address from,
        address to,
        uint256 tokenId,
        uint256 amount
    ) external {
        _executeERC1155SafeTransferFrom(collection, from, to, tokenId, amount);
    }

    function safeBatchTransferFromERC1155(
        address collection,
        address from,
        address to,
        uint256[] calldata tokenIds,
        uint256[] calldata amounts
    ) external {
        _executeERC1155SafeBatchTransferFrom(collection, from, to, tokenIds, amounts);
    }
}

abstract contract TestParameters {
    address internal _sender = address(100);
    address internal _recipient = address(101);
}

contract LowLevelERC1155Test is TestParameters, TestHelpers {
    ImplementedLowLevelERC1155 public lowLevelERC1155;
    MockERC1155 public mockERC1155;

    function setUp() external {
        lowLevelERC1155 = new ImplementedLowLevelERC1155();
        mockERC1155 = new MockERC1155();
    }

    function testSafeTransferFromERC1155(uint256 tokenId, uint256 amount) external asPrankedUser(_sender) {
        mockERC1155.mint(_sender, tokenId, amount);
        mockERC1155.setApprovalForAll(address(lowLevelERC1155), true);
        lowLevelERC1155.safeTransferFromERC1155(address(mockERC1155), _sender, _recipient, tokenId, amount);
        assertEq(mockERC1155.balanceOf(_recipient, tokenId), amount);
    }

    function testSafeBatchTransferFromERC1155(
        uint256 tokenId0,
        uint256 amount0,
        uint256 amount1
    ) external asPrankedUser(_sender) {
        vm.assume(tokenId0 < type(uint256).max);
        uint256 tokenId1 = tokenId0 + 1;
        mockERC1155.mint(_sender, tokenId0, amount0);
        mockERC1155.mint(_sender, tokenId1, amount1);
        mockERC1155.setApprovalForAll(address(lowLevelERC1155), true);

        uint256[] memory amounts = new uint256[](2);
        amounts[0] = amount0;
        amounts[1] = amount1;

        uint256[] memory tokenIds = new uint256[](2);
        tokenIds[0] = tokenId0;
        tokenIds[1] = tokenId1;

        lowLevelERC1155.safeBatchTransferFromERC1155(address(mockERC1155), _sender, _recipient, tokenIds, amounts);
        assertEq(mockERC1155.balanceOf(_recipient, tokenId0), amount0);
        assertEq(mockERC1155.balanceOf(_recipient, tokenId1), amount1);
    }
}
