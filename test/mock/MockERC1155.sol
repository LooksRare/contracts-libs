// SPDX-License-Identifier: MIT
pragma solidity >=0.8.7;

import {ERC1155} from "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

contract MockERC1155 is ERC1155("MockURI") {
    function uri(uint256) public pure override returns (string memory) {
        return "uri";
    }

    function mint(address to, uint256 tokenId, uint256 amount) public {
        _mint(to, tokenId, amount, "");
    }
}
