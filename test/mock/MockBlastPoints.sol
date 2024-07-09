// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MockBlastPoints {
    mapping(address _contract => address operator) public contractOperators;

    function configurePointsOperator(address operator) external {
        contractOperators[msg.sender] = operator;
    }
}
