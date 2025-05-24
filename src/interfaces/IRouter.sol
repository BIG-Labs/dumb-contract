// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

enum Action {
    Swap
}

/**
 * @notice Defines the complete path for cross-chain token bridging
 * @dev Contains all necessary information for token movement between chains
 *
 * Fee Handling:
 * - Primary fee is in input token if no swap occurred, output token if swapped
 * - Secondary fee used for multi-hop scenarios
 *
 * @param bridgeSourceChain Address of bridge contract on source chain
 * @param sourceBridgeIsNative True if bridge handles native tokens
 * @param bridgeDestinationChain Address of bridge contract on destination chain
 * @param cellDestinationChain Address of Cell contract on destination chain
 * @param destinationBlockchainID Unique identifier of destination blockchain
 * @param teleporterFee Primary fee for Teleporter service
 * @param secondaryTeleporterFee Additional fee for multi-hop operations
 */
struct BridgePath {
    address bridgeSourceChain;
    bool sourceBridgeIsNative;
    address bridgeDestinationChain;
    address cellDestinationChain;
    bytes32 destinationBlockchainID;
    uint256 teleporterFee;
    uint256 secondaryTeleporterFee;
}

struct CellPayload {
    Instructions instructions;
}

/**
 * @notice Represents a single step in a cross-chain operation
 * @dev Each hop can involve a swap, transfer, or both, between chains
 * @param action Enum defining the type of operation for this hop
 * @param requiredGasLimit Gas limit for the whole operation (bridge + recipientGasLimit)
 * @param recipientGasLimit Gas limit for any recipient contract calls
 * @param trade Encoded trade data (interpretation depends on action type)
 * @param bridgePath Detailed path information for cross-chain token movement
 */
struct Hop {
    Action action;
    uint256 requiredGasLimit;
    uint256 recipientGasLimit;
    bytes trade;
    BridgePath bridgePath;
}

struct Instructions {
    address receiver;
    Hop[] hops;
}

interface IRouter {
    error InvalidArgument();
    error InvalidAmount();
    error InvalidInstructions();

    function start(
        address token,
        uint256 amount,
        Instructions calldata instructions,
        address receiver
    ) external payable;
}
