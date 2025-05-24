// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.23;

import "forge-std/console2.sol";
import "forge-std/Script.sol";

import {ITokenTransferrer} from "@transferrer/interfaces/ITokenTransferrer.sol";
import {IERC20TokenTransferrer, SendTokensInput} from "@transferrer/interfaces/IERC20TokenTransferrer.sol";
import {IWrappedNativeToken} from "@transferrer/WrappedNativeToken.sol";
import "@teleporter/registry/TeleporterRegistry.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IRouter, Hop, Instructions} from "../src/Router.sol";
import {BridgePath, Action} from "../src/interfaces/IRouter.sol";

contract TestIBC is Script {
    address TOKEN_HOME = 0x97bBA61F61f2b0eEF60428947b990457f8eCb3a3;
    address TOKEN_REMOTE = 0x00396774d1E5b1C2B175B0F0562f921887678771;

    address teleporter = 0x7C43605E14F391720e1b37E49C78C4b03A488d98;

    address WAVAX = 0xB31f66AA3C1e785363F0875A1B74E27b85FD66c7;
    address USDC = 0xB97EF9Ef8734C71904D8002F8b6Bc66Dd9c48a6E;

    IWrappedNativeToken wrapped = IWrappedNativeToken(WAVAX);
    IRouter router = IRouter(0x681Bf6Fbc98C779b534925426929BD7cAe87C054);

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);
        vm.startBroadcast(deployerPrivateKey);

        uint256 amountIn = 1e16;

        wrapped.deposit{value: amountIn}();

        IERC20(WAVAX).approve(address(router), amountIn);

        Hop[] memory hops = new Hop[](1);
        address[] memory path = new address[](2);
        path[0] = WAVAX;
        path[1] = USDC;

        hops[0] = Hop({
            action: Action.Swap,
            requiredGasLimit: 500000,
            recipientGasLimit: 100000,
            trade: abi.encode(
                uint256(amountIn), // amountIn
                uint256(0), // amountOutMin
                path, // path [TOKEN_HOME, TOKEN_REMOTE]
                deployer, // to
                block.timestamp + 3600 // deadline
            ),
            bridgePath: BridgePath({
                bridgeSourceChain: TOKEN_HOME,
                sourceBridgeIsNative: false,
                bridgeDestinationChain: TOKEN_REMOTE,
                cellDestinationChain: address(0),
                destinationBlockchainID: hex"898b8aa8353f2b79ee1de07c36474fcee339003d90fa06ea3a90d9e88b7d7c33",
                teleporterFee: 0,
                secondaryTeleporterFee: 0
            })
        });

        Instructions memory instructions = Instructions({
            receiver: deployer,
            hops: hops
        });

        router.start(WAVAX, amountIn, instructions, address(0));
    }
}
