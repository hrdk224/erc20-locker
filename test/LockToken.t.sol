//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {LockToken} from "../src/LockToken.sol";
import {Test} from "forge-std/Test.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";

contract LockTokentest is Test {
    //contract declaration
    LockToken public lockToken;
    ERC20Mock public token;
    //dummy address
    address public constant USER = address(1);
    uint256 constant LOCK_AMOUNT = 100 ether;
    uint256 constant LOCK_TIME = 1 days;

    function setUp() public {
        //Deploy a MockERC20 token
        token = new ERC20Mock();

        //Deploy the lock contract
        lockToken = new LockToken();

        //Mint tokens to test contract
        token.mint(address(this), 1_000 ether);

        //Give user some tokens
        token.transfer(USER, 1000 ether);

        //prank user
        vm.startPrank(USER);

        //Approve the lock contract (Its like how you approve dapp to access your funds)
        token.approve(address(lockToken), 1000 ether);
    }

    function testLockTokens() public {
        lockToken.lockToken(address(token), LOCK_AMOUNT, LOCK_TIME);
        assertEq(lockToken.getLockCount(USER), 1);
    }

    function testCannotUnlockBeforeTime() public {
        vm.startPrank(USER);
        lockToken.lockToken(address(token), LOCK_AMOUNT, LOCK_TIME);
        vm.expectRevert(LockToken.LockNotYetExpired.selector);
        lockToken.withdrawTokens(0);
    }

    function testUnlockAfterTime() public {
        vm.startPrank(USER);
        lockToken.lockToken(address(token), LOCK_AMOUNT, LOCK_TIME);

        vm.warp(block.timestamp + LOCK_TIME + 1);

        lockToken.withdrawTokens(0);
        assertEq(token.balanceOf(USER), 1000 ether);
    }

    function testInvalidLockId() public {
        vm.startPrank(USER);
        lockToken.lockToken(address(token), LOCK_AMOUNT, LOCK_TIME);

        vm.expectRevert(LockToken.InvalidLockId.selector);

        lockToken.withdrawTokens(999);
    }

    function testInsufficientAmount() public {
        vm.startPrank(USER);
        vm.expectRevert(LockToken.InsufficientAmount.selector);
        lockToken.lockToken(address(token), 0, LOCK_TIME);
    }

    function testMinimumDurationReq() public {
        vm.startPrank(USER);
        vm.expectRevert(LockToken.MinimumDurationReq.selector);
        lockToken.lockToken(address(token), LOCK_AMOUNT, 0);
    }

    function testNoFundsLeft() public {
        vm.startPrank(USER);
        lockToken.lockToken(address(token), LOCK_AMOUNT, LOCK_TIME);
        vm.warp(block.timestamp + LOCK_TIME + 1);
        lockToken.withdrawTokens(0);

        vm.expectRevert(LockToken.NoFundsLeft.selector);
        lockToken.withdrawTokens(0);
    }
}
