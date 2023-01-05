// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

abstract contract Faucet {
    error AlreadyClaimed();

    mapping(address => bool) internal _hasClaimed;

    function claim() external virtual;

    function _claim() internal {
        if (_hasClaimed[msg.sender]) {
            revert AlreadyClaimed();
        }

        bool status;
        address to = msg.sender;
        uint256 amount = 0.01 ether;

        assembly {
            status := call(gas(), to, amount, 0, 0, 0, 0)
            // returndatacopy(t, f, s)
            // copy s bytes from returndata at position f to mem at position t
            returndatacopy(0, 0, returndatasize())
            switch status
            case 0 {
                // revert(p, s)
                // end execution, revert state changes, return data mem[p…(p+s))
                revert(0, returndatasize())
            }
        }

        _hasClaimed[msg.sender] = true;
    }
}
