// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {LowLevelERC20} from "../../contracts/lowLevelCallers/LowLevelERC20.sol";
import {TestHelpers} from "./utils/TestHelpers.sol";

contract ImplementedLowLevelERC20 is LowLevelERC20 {
    function transferERC20(
        address currency,
        address to,
        uint256 amount
    ) external {
        _executeERC20DirectTransfer(currency, to, amount);
    }

    function transferFromERC20(
        address currency,
        address from,
        address to,
        uint256 amount
    ) external {
        _executeERC20TransferFrom(currency, from, to, amount);
    }
}

abstract contract TestParameters {
    address internal _usdt = 0xdAC17F958D2ee523a2206206994597C13D831ec7; // Mainnet USDT address
    address internal _tetherTreasury = 0x5754284f345afc66a98fbB0a0Afe71e0F007B949; // Mainnet Tether treasury
    address internal _sender = _tetherTreasury;
    address internal _recipient = address(250);
    uint256 internal _amount = 10_000 * (10**6); // USDT has 6 decimals

    // Ankr RPC endpoint is public
    string internal _MAINNET_RPC_URL = "https://rpc.ankr.com/eth";
}

interface IUSDT {
    function approve(address _spender, uint256 _value) external;

    function transfer(address _to, uint256 _value) external;

    function balanceOf(address who) external view returns (uint256);

    function owner() external view returns (address);
}

contract USDTLowLevelERC20Test is TestHelpers, TestParameters {
    ImplementedLowLevelERC20 public lowLevelERC20;

    uint256 internal _mainnetFork;

    function setUp() external {
        _mainnetFork = vm.createFork(_MAINNET_RPC_URL);
        vm.selectFork(_mainnetFork);
        lowLevelERC20 = new ImplementedLowLevelERC20();
    }

    function testTransferFromUSDT() external asPrankedUser(_sender) {
        IUSDT(_usdt).approve(address(lowLevelERC20), _amount);
        lowLevelERC20.transferFromERC20(_usdt, _sender, _recipient, _amount);
        assertEq(IUSDT(_usdt).balanceOf(_recipient), _amount);
    }

    function testTransferUSDT() external asPrankedUser(_sender) {
        IUSDT(_usdt).transfer(address(lowLevelERC20), _amount);
        lowLevelERC20.transferERC20(_usdt, _recipient, _amount);
        assertEq(IUSDT(_usdt).balanceOf(_recipient), _amount);
    }
}
