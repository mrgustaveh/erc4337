// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {Upgrades} from "openzeppelin-foundry-upgrades/Upgrades.sol";
import {SimpleAccount} from "../src/Account.sol";

/**
 * @title AccountScript
 * @dev Deployment script for ERC-4337 Account contract using UUPS proxy pattern
 *
 * Usage:
 *   forge script script/Account.s.sol:AccountScript \
 *     --rpc-url <RPC_URL> \
 *     --private-key <PRIVATE_KEY> \
 *     --broadcast
 *
 * Environment Variables:
 *   SIGNER_ADDRESS: Address authorized to sign for this account (defaults to deployer)
 */
contract AccountScript is Script {
    address private signer;

    function setUp() public {
        try vm.envString("SIGNER_ADDRESS") returns (string memory signerEnv) {
            signer = vm.parseAddress(signerEnv);
        } catch {
            signer = msg.sender;
        }
    }

    function run() public {
        require(signer != address(0), "SIGNER_ADDRESS invalid");

        vm.startBroadcast();

        // Deploy SimpleAccount implementation and UUPS proxy via Upgrades library
        address proxy =
            Upgrades.deployUUPSProxy("SimpleAccount.sol", abi.encodeCall(SimpleAccount.initialize, (signer)));

        vm.stopBroadcast();

        // Log deployment info
        console.log("Account proxy deployed at:", proxy);
        console.log("Account signer:", signer);
    }
}
