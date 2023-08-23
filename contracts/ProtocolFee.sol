// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

/**
 * @title ProtocolFee
 * @notice This contract makes it possible for a contract to charge a protocol fee.
 * @author LooksRare protocol team (👀,💎)
 */
abstract contract ProtocolFee {
    /**
     * @dev Emitted when the protocol fee basis points is updated.
     */
    event ProtocolFeeBpUpdated(uint16 protocolFeeBp);

    /**
     * @dev Emitted when the protocol fee recipient is updated.
     */
    event ProtocolFeeRecipientUpdated(address protocolFeeRecipient);

    /**
     * @dev This error is used when the protocol fee basis points is too high
     *      or when the protocol fee recipient is a zero address.
     */
    error ProtocolFee__InvalidValue();

    /**
     * @notice The maximum protocol fee in basis points, which is 25%.
     */
    uint16 public constant MAXIMUM_PROTOCOL_FEE_BP = 2_500;

    /**
     * @notice The address of the protocol fee recipient.
     */
    address public protocolFeeRecipient;

    /**
     * @notice The protocol fee basis points.
     */
    uint16 public protocolFeeBp;

    /**
     * @dev This function is used to update the protocol fee recipient. It should be overridden
     *      by the contract that inherits from this contract. The function should be guarded
     *      by an access control mechanism to prevent unauthorized users from calling it.
     * @param _protocolFeeRecipient The address of the protocol fee recipient
     */
    function updateProtocolFeeRecipient(address _protocolFeeRecipient) external virtual;

    /**
     * @dev This function is used to update the protocol fee basis points. It should be overridden
     *      by the contract that inherits from this contract. The function should be guarded
     *      by an access control mechanism to prevent unauthorized users from calling it.
     * @param _protocolFeeBp The protocol fee basis points
     */
    function updateProtocolFeeBp(uint16 _protocolFeeBp) external virtual;

    /**
     * @param _protocolFeeRecipient The new protocol fee recipient address
     */
    function _updateProtocolFeeRecipient(address _protocolFeeRecipient) internal {
        if (_protocolFeeRecipient == address(0)) {
            revert ProtocolFee__InvalidValue();
        }
        protocolFeeRecipient = _protocolFeeRecipient;
        emit ProtocolFeeRecipientUpdated(_protocolFeeRecipient);
    }

    /**
     * @param _protocolFeeBp The new protocol fee in basis points
     */
    function _updateProtocolFeeBp(uint16 _protocolFeeBp) internal {
        if (_protocolFeeBp > MAXIMUM_PROTOCOL_FEE_BP) {
            revert ProtocolFee__InvalidValue();
        }
        protocolFeeBp = _protocolFeeBp;
        emit ProtocolFeeBpUpdated(_protocolFeeBp);
    }
}
