//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {DeployLock} from "../script/DeployLock.s.sol";
import {Test} from "forge-std/Test.sol";
import {MockERC20} from "../src/MockERC20.sol";
import {LockToken} from "../src/LockToken.sol";

contract DeployLockTest is Test {
    function testDeploymentScript() public {
        DeployLock deployScript = new DeployLock();
        deployScript.run();

        assertTrue(address(deployScript.usdc()) != address(0));
        assertTrue(address(deployScript.lockToken()) != address(0));
        assertEq(deployScript.usdc().totalSupply(), 1_000_000 ether);
    }
}
