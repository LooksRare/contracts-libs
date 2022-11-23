// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {LowLevelERC721Transfer} from "../../contracts/lowLevelCallers/LowLevelERC721Transfer.sol";
import {NotAContract} from "../../contracts/Errors.sol";
import {MockERC721} from "../mock/MockERC721.sol";
import {TestHelpers} from "./utils/TestHelpers.sol";

contract ImplementedLowLevelERC721Transfer is LowLevelERC721Transfer {
    function transferERC721(
        address collection,
        address from,
        address to,
        uint256 tokenId
    ) external {
        _executeERC721TransferFrom(collection, from, to, tokenId);
    }
}

abstract contract TestParameters {
    address internal _sender = address(100);
    address internal _recipient = address(101);
}

contract LowLevelERC721TransferTest is TestParameters, TestHelpers {
    ImplementedLowLevelERC721Transfer public lowLevelERC721Transfer;
    MockERC721 public mockERC721;

    function setUp() external {
        lowLevelERC721Transfer = new ImplementedLowLevelERC721Transfer();
        mockERC721 = new MockERC721();
    }

    function testTransferFromERC721(uint256 tokenId) external asPrankedUser(_sender) {
        mockERC721.mint(_sender, tokenId);
        mockERC721.setApprovalForAll(address(lowLevelERC721Transfer), true);
        lowLevelERC721Transfer.transferERC721(address(mockERC721), _sender, _recipient, tokenId);
        assertEq(mockERC721.ownerOf(tokenId), _recipient);
    }

    function testTransferFromERC721NotAContract(uint256 tokenId) external asPrankedUser(_sender) {
        vm.expectRevert(NotAContract.selector);
        lowLevelERC721Transfer.transferERC721(address(0), _sender, _recipient, tokenId);
    }
}
