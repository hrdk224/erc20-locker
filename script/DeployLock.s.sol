//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {LockToken} from "../src/LockToken.sol";
import {MockERC20} from "../src/MockERC20.sol";

contract DeployLockToken is Script {
    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        uint256 initialSupply = 1_000_000 * 1e18;

        MockERC20 usdc = new MockERC20(initialSupply);

        LockToken lockToken = new LockToken();

        console.log("MockUSDC deployed at:", address(usdc));
        console.log("LockToken deployed at:", address(lockToken));
        vm.stopBroadcast();
    }
}
