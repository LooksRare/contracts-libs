# @looksrare/contracts-libs

This repository contains a set of Solidity contracts that can be used across contracts for purposes such as verifying signatures, protecting contracts against reentrancy attacks, and a library for managing the ownership of a contract.

It also contains contract interfaces that can be used.

## Current contracts

| Name             | Description                                                                                                 | Type      | Latest version |
| ---------------- | ----------------------------------------------------------------------------------------------------------- | --------- | -------------- |
| OwnableTwoSteps  | Contract for managing ownership of a smart contract. The transfer of ownership is done in a 2-step process. | Contract  | 1.0.0          |
| SignatureChecker | Contract for verifying the validity of a signature for EOA (64-byte, 65-byte signatures) and EIP-1271.      | Contract  | 1.0.0          |
| ReentrancyGuard  | Contract with a modifier to prevent reentrancy calls.                                                       | Contract  | 1.0.0          |
| IERC165          | -                                                                                                           | Interface | 1.0.0          |
| IERC1271         | -                                                                                                           | Interface | 1.0.0          |
| IERC2981         | -                                                                                                           | Interface | 1.0.0          |

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

### Example of Hardhat commands

```shell
npx hardhat accounts
npx hardhat compile
npx hardhat clean
npx hardhat test
npx hardhat node
npx hardhat help
REPORT_GAS=true npx hardhat test
npx hardhat coverage
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
