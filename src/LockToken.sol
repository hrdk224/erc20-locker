//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract LockToken {
    error InsufficientAmount();
    error MinimumDurationReq();
    error InvalidLockId();
    error LockNotYetExpired();
    error NoFundsLeft();

    ///@notice struct represents each token lock

    struct Lock {
        address token; // Address of the Token
        uint256 amount; // Amount of token locked
        uint256 unlockTime; // Timestamp when the toke can be withdrawn
        bool withdraw; // To check token is withdrawn or not
    }
    ///@notice users => list of thier locks(lock)

    mapping(address => Lock[]) public userLocks;

    ///@notice emitted when Tokens are Locked
    event tokenLocked(address indexed user, address indexed token, uint256 amount, uint256 duration);

    ///@notice emitted when Tokens are Unlocked
    event tokenWithdrawn(address indexed user, address indexed token, uint256 amount, uint256 lockId);

    ///@notice locks token for specific duration (sec)
    function lockToken(address _token, uint256 _amount, uint256 _duration) external {
        if (_amount == 0) {
            revert InsufficientAmount();
        }

        if (_duration <= 0) {
            revert MinimumDurationReq();
        }

        //transfer token from user to contract
        IERC20(_token).transferFrom(msg.sender, address(this), _amount);

        //create the lock
        Lock memory newLock =
            Lock({token: _token, amount: _amount, unlockTime: block.timestamp + _duration, withdraw: false});

        //feeding newLock to struct array
        userLocks[msg.sender].push(newLock);
        // Updating the current state
        emit tokenLocked(msg.sender, _token, _amount, block.timestamp + _duration);
    }
    ///@notice withdraw unlocked tokens using token index

    function withdrawTokens(uint256 lockId) external {
        if (lockId >= userLocks[msg.sender].length) {
            revert InvalidLockId();
        }

        Lock storage userLock = userLocks[msg.sender][lockId];

        if (block.timestamp < userLock.unlockTime) {
            revert LockNotYetExpired();
        }

        if (userLock.withdraw == true) {
            revert NoFundsLeft();
        }

        userLock.withdraw = true;

        //transfer of token to user
        IERC20(userLock.token).transfer(msg.sender, userLock.amount);

        //udpating withdrawn state~
        emit tokenWithdrawn(msg.sender, userLock.token, userLock.amount, lockId);
    }

    //Getter function

    function getLockCount(address user) external view returns (uint256) {
        return userLocks[user].length;
    }
}
