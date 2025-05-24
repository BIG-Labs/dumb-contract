// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.23;

import "forge-std/console2.sol";
import "forge-std/Script.sol";

import {ITokenTransferrer} from "@transferrer/interfaces/ITokenTransferrer.sol";
import {IERC20TokenTransferrer, SendTokensInput} from "@transferrer/interfaces/IERC20TokenTransferrer.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract TestIBC is Script {
    address TOKEN_HOME = 0x698044F6CC7186D1e2dbEF130d20Dc6dfbA9ecC5;
    address TOKEN_REMOTE = 0x1BB241dF1B33a9A5CABB63d81Ef0485c17aa0EB3;

    address USDC = 0xB97EF9Ef8734C71904D8002F8b6Bc66Dd9c48a6E;

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);
        vm.startBroadcast(deployerPrivateKey);

        uint256 amountIn = 1e5;

        IERC20(USDC).approve(TOKEN_HOME, amountIn);

        SendTokensInput memory input = SendTokensInput({
            destinationBlockchainID: 0x898b8aa8353f2b79ee1de07c36474fcee339003d90fa06ea3a90d9e88b7d7c33,
            destinationTokenTransferrerAddress: TOKEN_REMOTE,
            recipient: deployer,
            primaryFeeTokenAddress: address(0),
            primaryFee: 0,
            secondaryFee: 0,
            requiredGasLimit: 250000,
            multiHopFallback: address(0)
        });

        IERC20TokenTransferrer(TOKEN_HOME).send(input, amountIn);
    }
}
