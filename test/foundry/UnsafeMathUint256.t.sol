// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {UnsafeMathUint256} from "../../contracts/libraries/UnsafeMathUint256.sol";
import {TestHelpers} from "./utils/TestHelpers.sol";

contract UnsafeMathUint256Test is TestHelpers {
    using UnsafeMathUint256 for uint256;

    function testFuzz_unsafeAdd(uint256 number) public {
        vm.assume(number < type(uint256).max);
        assertEq(number.unsafeAdd(1), number + 1);
    }

    function test_unsafeAdd_NumberIsUint256Max() public {
        assertEq(type(uint256).max.unsafeAdd(1), 0);
    }

    function testFuzz_unsafeSubtract(uint256 number) public {
        vm.assume(number > 0);
        assertEq(number.unsafeSubtract(1), number - 1);
    }

    function test_unsafeSubtract_NumberIs0() public {
        assertEq(uint256(0).unsafeSubtract(1), type(uint256).max);
    }

    function testFuzz_unsafeMultiply(uint256 a, uint256 b) public {
        vm.assume(a <= type(uint128).max && b <= type(uint128).max);
        assertEq(a.unsafeMultiply(b), a * b);
    }

    function test_unsafeMultiply_NumbersAreGreaterThanUint128() public {
        uint256 number = uint256(type(uint128).max) + 1;
        assertEq(number.unsafeMultiply(number), 0);
    }

    function testFuzz_unsafeDivide(uint256 a, uint256 b) public {
        vm.assume(b != 0);
        assertEq(a.unsafeDivide(b), a / b);
    }
}
