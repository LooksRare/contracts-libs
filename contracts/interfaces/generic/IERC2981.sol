// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./IERC165.sol";

interface IERC2981 is IERC165 {
    function royaltyInfo(uint256 tokenId, uint256 salePrice)
        external
        view
        returns (address receiver, uint256 royaltyAmount);
}
