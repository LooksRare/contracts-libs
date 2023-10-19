// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

library UnsafeMathUint256 {
  function unsafeAdd(uint256 a, uint256 b) internal pure returns (uint256) {
      unchecked {
          return a + b;
      }
  }

  function unsafeSubtract(uint256 a, uint256 b) internal pure returns (uint256) {
      unchecked {
          return a - b;
      }
  }

  function unsafeMultiply(uint256 a, uint256 b) internal pure returns (uint256) {
      unchecked {
          return a * b;
      }
  }

  function unsafeDivide(uint256 a, uint256 b) internal pure returns (uint256) {
      unchecked {
          return a / b;
      }
  }
}
