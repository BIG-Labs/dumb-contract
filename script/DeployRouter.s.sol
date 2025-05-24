// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.23;

import {Script} from "forge-std/Script.sol";
import {console2} from "forge-std/console2.sol";
import {Router} from "../src/Router.sol";

contract DeployRouter is Script {
    // Constants for deployment
    address constant TELEPORTER_REGISTRY =
        0x7C43605E14F391720e1b37E49C78C4b03A488d98;
    uint256 constant MIN_TELEPORTER_VERSION = 1;

    function run() public {
        // Get private key from environment
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        // Start broadcasting transactions
        vm.startBroadcast(deployerPrivateKey);

        // Deploy Router contract
        Router router = new Router(
            msg.sender, // owner
            TELEPORTER_REGISTRY,
            MIN_TELEPORTER_VERSION
        );

        // Stop broadcasting
        vm.stopBroadcast();

        // Log deployment information
        console2.log("Router deployed to:", address(router));
        console2.log("Owner:", msg.sender);
        console2.log("Teleporter Registry:", TELEPORTER_REGISTRY);
        console2.log("Min Teleporter Version:", MIN_TELEPORTER_VERSION);
    }
}
