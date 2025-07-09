
---

# 🔐 Lock ERC20 Token: Time-Based Token Locking Smart Contract

## Secure your ERC20 tokens by locking them for a fixed duration — ideal for vesting, airdrops, escrow, or DAO-controlled assets.

---

### 📖 Introduction

The **Lock ERC20 Token** smart contract enables users to **lock any ERC20 token** for a predefined period. This ensures that tokens can only be withdrawn after the lock period has ended, adding a time-based security mechanism ideal for **vesting schedules**, **airdrop delays**, **DAO-controlled funds**, and **escrow services**. Built with Solidity and compatible with any EVM chain, the contract prioritizes **simplicity, gas-efficiency, and decentralization**.

---

### 📊 How It Works 

```
[User Wallet] 
     |
     | lockToken(token, amount, duration)
     v
[LockERC20 Contract] -- stores --> [LockInfo Mapping]
     |
     | after duration passes
     v
 withdrawTokens(lockId)
     |
     v
[User Wallet] <- tokens returned
```
### 🎥 Demo Video

> 🔗 [Watch the full demo on X (Twitter)](https://x.com/0xkille/status/1942267470980735012)

📝 The video demonstrates:

* Locking an ERC20 token from the frontend UI
* The **first attempt to lock fails** (a known testnet issue)
* **Second call succeeds**, and the lock is created
* Tokens are later successfully withdrawn after the lock duration expires

---

### 🚀 Installation & Usage (for End-Users)

#### 1. Clone or Deploy the Contract

You can deploy the contract on Sepolia, Anvil, or any EVM-compatible chain using Foundry or Hardhat.

#### 2. Locking Tokens

```solidity
lockToken(address token, uint256 amount, uint256 duration);
```

#### 3. Withdrawing Tokens

```solidity
withdrawTokens(uint256 lockId);
```

#### 4. Events

* `Locked(address indexed user, uint256 lockId, address token, uint256 amount, uint256 unlockTime)`
* `Withdrawn(address indexed user, uint256 lockId, address token, uint256 amount)`

---

### 🧑‍💻 Frontend Integration (Viem Example)

You can integrate the contract with **Viem** using the `simulateContract` and `writeContract` flow:

```ts
const { request } = await publicClient.simulateContract({
  address: contractAddress,
  abi: lockAbi,
  functionName: "lockToken",
  args: [tokenAddress, parsedAmount, BigInt(durationInSeconds)],
  account,
  chain,
});

await walletClient.writeContract(request);
```

> ⚠️ **Known Frontend Issue:**
> On Sepolia and some testnets, the first transaction attempt to `lockToken` **often fails** with a revert or gas estimation error, but **succeeds on the second attempt**.
> This appears to be a **testnet-specific optimization issue** (e.g., gas estimation fails due to pending approvals or simulation mismatch).
> **Workaround:** Retry the transaction once — it almost always works on the second try.

---

### ⚙️ Installation & Usage (for Contributors)

#### Foundry Setup:

```bash
git clone https://github.com/yourusername/lock-erc20.git
cd lock-erc20
forge install
forge build
forge test
```

Use `.env` for keys if deploying:

```
PRIVATE_KEY=your_private_key
RPC_URL=https://sepolia.infura.io/v3/your_project_id
```

---

### 🤝 Contributor Expectations

We welcome contributions! Here’s how to contribute:

1. Fork the repo
2. Create a feature branch: `git checkout -b feat/your-feature-name`
3. Commit your changes with a meaningful message
4. Open a PR referencing an existing issue (if possible)
5. Follow Solidity formatting guidelines

**Preferred practices:**

* Squash commits before merging
* Use `forge fmt` or `prettier` to maintain code quality
* Add/modify test cases when relevant

---

### 🐞 Known Issues

* 🟡 Frontend: `lockToken()` sometimes fails on the first try, but works on retry
* 🟡 Only supports ERC20 tokens that **return `true` on transfer**
* 🔒 No admin access or upgradeability — this is a permanent, trustless contract
* 🔁 Partial withdrawals are not supported

---

### 📜 License

MIT License

---
