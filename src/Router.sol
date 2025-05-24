// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.23;

import {IRouter, Action} from "./interfaces/IRouter.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {Address} from "@openzeppelin/contracts/utils/Address.sol";
import {TeleporterRegistryOwnableApp} from "@teleporter/registry/TeleporterRegistryOwnableApp.sol";
import {SendTokensInput} from "@transferrer/interfaces/ITokenTransferrer.sol";
import {IWarpMessenger} from "@subnet-evm/contracts/interfaces/IWarpMessenger.sol";
import {Instructions, Hop, CellPayload} from "./interfaces/IRouter.sol";
import {IERC20TokenTransferrer} from "@transferrer/interfaces/IERC20TokenTransferrer.sol";
import {IJoeRouter01} from "trader-joe/interfaces/IJoeRouter02.sol";

contract Router is IRouter, TeleporterRegistryOwnableApp {
    using SafeERC20 for IERC20;
    using Address for address payable;

    address public feeCollector;

    // 1% fee (100 basis points)
    uint256 private constant FEE_BASIS_POINTS = 100;
    uint256 private constant BASIS_POINTS_DENOMINATOR = 10000;

    error InvalidPath();

    IJoeRouter01 router =
        IJoeRouter01(0x60aE616a2155Ee3d9A68541Ba4544862310933d4);

    constructor(
        address owner,
        address teleporterRegistry,
        uint256 minTeleporterVersion
    )
        TeleporterRegistryOwnableApp(
            teleporterRegistry,
            owner,
            minTeleporterVersion
        )
    {
        if (owner == address(0)) {
            revert InvalidArgument();
        }
        feeCollector = owner;
    }

    function start(
        address token,
        uint256 amount,
        Instructions calldata instructions,
        address receiver
    ) public payable override {
        if (amount == 0 && msg.value == 0) {
            revert InvalidAmount();
        }

        if (instructions.hops.length == 0) {
            revert InvalidInstructions();
        }

        IERC20(token).safeTransferFrom(msg.sender, address(this), amount);

        // Calculate and distribute fees
        uint256 feeAmount = calculateAndDistributeFees(token, amount, receiver);
        uint256 amountAfterFees = amount - feeAmount;

        CellPayload memory payload = CellPayload({instructions: instructions});

        Hop memory hop = instructions.hops[0];

        // Decode trade parameters
        (
            uint256 amountIn,
            uint256 amountOutMin,
            address[] memory path,
            address to,
            uint256 deadline
        ) = abi.decode(
                hop.trade,
                (uint256, uint256, address[], address, uint256)
            );

        IERC20(token).approve(address(router), amountAfterFees);

        // Execute swap through TraderJoe router
        uint256[] memory amounts = router.swapExactTokensForTokens(
            amountAfterFees,
            amountOutMin,
            path,
            address(this),
            deadline
        );

        IERC20(path[1]).approve(hop.bridgePath.bridgeSourceChain, amounts[1]);

        SendTokensInput memory input = SendTokensInput({
            destinationBlockchainID: hop.bridgePath.destinationBlockchainID,
            destinationTokenTransferrerAddress: hop
                .bridgePath
                .bridgeDestinationChain,
            recipient: payload.instructions.receiver,
            primaryFeeTokenAddress: address(0),
            primaryFee: 0,
            secondaryFee: 0,
            requiredGasLimit: hop.requiredGasLimit,
            multiHopFallback: address(0)
        });

        IERC20TokenTransferrer(hop.bridgePath.bridgeSourceChain).send(
            input,
            amounts[1]
        );
    }

    function calculateAndDistributeFees(
        address token,
        uint256 amountIn,
        address receiver
    ) private returns (uint256 feeAmount) {
        // Calculate 1% fee
        feeAmount = (amountIn * FEE_BASIS_POINTS) / BASIS_POINTS_DENOMINATOR;

        if (feeAmount == 0) {
            return 0;
        }

        if (receiver == address(0)) {
            // If no receiver specified, send entire fee to fee collector
            IERC20(token).safeTransferFrom(
                address(this),
                feeCollector,
                feeAmount
            );
        } else {
            // Split fee 50-50 between fee collector and receiver
            uint256 halfFee = feeAmount / 2;
            IERC20(token).safeTransferFrom(
                address(this),
                feeCollector,
                halfFee
            );
            IERC20(token).safeTransferFrom(
                address(this),
                receiver,
                feeAmount - halfFee
            );
        }

        return feeAmount;
    }

    function _updatePayload(
        CellPayload memory payload
    ) internal pure returns (CellPayload memory) {
        Hop[] memory hops = new Hop[](payload.instructions.hops.length - 1);
        for (uint256 i = 0; i < payload.instructions.hops.length - 1; i++) {
            hops[i] = payload.instructions.hops[i + 1];
        }
        payload.instructions.hops = hops;
        return payload;
    }

    function _receiveTeleporterMessage(
        bytes32 sourceBlockchainID,
        address originSenderAddress,
        bytes memory message
    ) internal virtual override {}
}
