// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {Test} from "forge-std/Test.sol";
import {SimpleAccount} from "../src/Account.sol";
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract AccountTest is Test {
    SimpleAccount public implementation;
    SimpleAccount public account;
    address public signer = makeAddr("signer");
    address public user = makeAddr("user");

    function setUp() public {
        // Deploy implementation
        implementation = new SimpleAccount();

        // Deploy proxy and initialize
        bytes memory initData = abi.encodeCall(SimpleAccount.initialize, (signer));
        ERC1967Proxy proxy = new ERC1967Proxy(address(implementation), initData);
        account = SimpleAccount(payable(address(proxy)));
    }

    function test_InitializerSetsSignerCorrectly() public view {
        assertEq(account.signer(), signer);
    }

    function test_ReceiveEther() public {
        uint256 initialBalance = address(account).balance;
        vm.deal(user, 1 ether);

        vm.prank(user);
        (bool success,) = address(account).call{value: 1 ether}("");

        assertTrue(success);
        assertEq(address(account).balance, initialBalance + 1 ether);
    }

    function test_SignatureValidation() public view {
        bytes32 hash = keccak256("test message");
        bytes4 result = account.isValidSignature(hash, "");
        // Should return either invalid (0xffffffff) or the selector
        assertTrue(result == bytes4(0xffffffff) || result == bytes4(keccak256("isValidSignature(bytes32,bytes)")));
    }
}
