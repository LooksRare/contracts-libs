// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Greeter} from "../../contracts/Greeter.sol";
import {TestHelpers} from "./TestHelpers.sol";

abstract contract TestParameters {
    string internal _INITIAL_MESSAGE = "Hello, world!";
}

contract GreeterTest is TestParameters, TestHelpers {
    Greeter public greeter;

    function setUp() public {
        greeter = new Greeter(_INITIAL_MESSAGE);
    }

    function testConstructor() public {
        assertEq(greeter.greet(), _INITIAL_MESSAGE);
    }

    function testNewGreeting() public {
        string memory newMessage = "Hola, mundo!";
        greeter.setGreeting(newMessage);
        assertEq(greeter.greet(), newMessage);
    }
}
