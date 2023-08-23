# @looksrare/contracts-libs

[![Tests](https://github.com/LooksRare/contracts-libs/actions/workflows/tests.yaml/badge.svg)](https://github.com/LooksRare/contracts-libs/actions/workflows/tests.yaml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

This repository contains a set of Solidity contracts that can be used across contracts for purposes such as verifying signatures, protecting contracts against reentrancy attacks, low-level call functions, and a library for managing the ownership of a contract.

It also contains generic contract interfaces (for EIP/ERC) that can be used.

## Installation

```shell
# Yarn
yarn add @looksrare/contracts-libs

# NPM
npm install @looksrare/contracts-libs
```

## NPM package

The NPM package contains the following:

- Solidity smart contracts (_".sol"_)
- ABIs (_".json"_)

## Current contracts

| Name                                  | Description                                                                                                                   | Type     | Latest version | Audited? |
| ------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------- | -------- | -------------- | -------- |
| OwnableTwoSteps                       | Contract for managing ownership of a smart contract. The transfer of ownership is done in a 2-step process.                   | Contract | 2.5.0          | Yes      |
| SignatureCheckerCalldata              | Contract for verifying the validity of a (calldata) signature for EOA (64-byte, 65-byte signatures) and EIP-1271.             | Contract | 3.0.0          | Yes      |
| SignatureCheckerMemory                | Contract for verifying the validity of a (memory) signature for EOA (64-byte, 65-byte signatures) and EIP-1271.               | Contract | 3.0.0          | Yes      |
| ReentrancyGuard                       | Contract with a modifier to prevent reentrancy calls.                                                                         | Contract | 2.4.4          | Yes      |
| PackedReentrancyGuard                 | Contract with a modifier to prevent reentrancy calls. Adapted from ReentrancyGuard.                                           | Contract | 2.5.1          | Yes      |
| LowLevelETHTransfer                   | Low-level call function to transfer ETH                                                                                       | Contract | 2.4.4          | Yes      |
| LowLevelETHReturnETHIfAny             | Low-level call function to return all ETH left                                                                                | Contract | 2.4.4          | Yes      |
| LowLevelETHReturnETHIfAnyExceptOneWei | Low-level call function to return all ETH left except one wei                                                                 | Contract | 2.4.4          | Yes      |
| LowLevelWETH                          | Low-level call functions to transfer ETH with an option to wrap to WETH if the original ETH transfer fails within a gas limit | Contract | 2.4.4          | Yes      |
| LowLevelERC20Approve                  | Low-level call functions for ERC20 approve functions                                                                          | Contract | 2.4.4          | Yes      |
| LowLevelERC20Transfer                 | Low-level call functions for ERC20 transfer functions                                                                         | Contract | 2.4.4          | Yes      |
| LowLevelERC721Transfer                | Low-level call functions for ERC721 functions                                                                                 | Contract | 2.4.4          | Yes      |
| LowLevelERC1155Transfer               | Low-level call functions for ERC1155 functions                                                                                | Contract | 2.4.4          | Yes      |
| ProtocolFee                           | Contract for defining protocol fee recipient and basis points                                                                 | Contract | 3.2.0          | No       |

## About this repo

### Structure

It is a hybrid [Hardhat](https://hardhat.org/) repo that also requires [Foundry](https://book.getfoundry.sh/index.html) to run Solidity tests powered by the [ds-test library](https://github.com/dapphub/ds-test/).

> To install Foundry, please follow the instructions [here](https://book.getfoundry.sh/getting-started/installation.html).

### Run tests

- Solidity tests are included in the `foundry` folder in the `test` folder.

### Example of Foundry/Forge commands

```shell
forge build
forge test
forge test -vv
forge tree
```

### Example of other commands

```shell
npx eslint '**/*.{js,ts}'
npx eslint '**/*.{js,ts}' --fix
npx prettier '**/*.{json,sol,md}' --check
npx prettier '**/*.{json,sol,md}' --write
npx solhint 'contracts/**/*.sol'
npx solhint 'contracts/**/*.sol' --fix
```

### Coverage

It is required to install lcov.

```shell
brew install lcov
```

To run the coverage report, the below command can be executed.

```
forge coverage --report lcov
LCOV_EXCLUDE=("test/*" "contracts/interfaces/*" "contracts/errors/*.sol")
echo $LCOV_EXCLUDE | xargs lcov --output-file lcov-filtered.info --remove lcov.info
genhtml lcov-filtered.info --output-directory out
open out/index.html
```
