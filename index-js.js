import {
    createWalletClient,
    createPublicClient,
    custom,
    parseUnits,
    formatUnits,
    defineChain,
    parseAbi
} from "https://esm.sh/viem"

import { contractAddress, lockAbi } from "./constant-js.js"

//declaration of variables which connect to HTML
const connectBtn = document.getElementById("connectBtn")
const lockBtn = document.getElementById("lockBtn")
const withdrawBtn = document.getElementById("withdrawBtn")
const infoBtn = document.getElementById("infoBtn")

const tokenInput = document.getElementById("tokenAddress")
const amountInuput = document.getElementById("amount")
const durationInput = document.getElementById("duration")
const lockIdInput = document.getElementById("lockId")
const output = document.getElementById("output")

let walletClient //signing and writing transaction
let publicClient //reading transaction

async function Connect() {
    if (typeof window.ethereum !== "undefined") //check for metamask installed
    {
        walletClient = createWalletClient({
            transport: custom(window.ethereum),   // sending Sign request via metamask
        })
        await walletClient.requestAddresses()    //waiting for Sign and return address
        connectBtn.innerText = "Connected"
    }
    else {
        connectBtn.innerText = "Please install MetaMask"
    }
}

async function lockToken() {
    // for grabing inputs from user
    const token = tokenInput.value
    const amount = amountInuput.value
    const duration = durationInput.value

    console.log("🔢 Input Token:", token)
    console.log("💰 Input Amount:", amount)
    console.log("⏳ Lock Duration (seconds):", duration)

    const [account] = await walletClient.requestAddresses() //grabs the first account connected
    console.log("👤 Connected Wallet Address:", account)

    const chain = await getCurrentChain(walletClient) // fetches current network from getCurrentChain func
    console.log("🌐 Current Chain:", chain)

    publicClient = createPublicClient({ transport: custom(window.ethereum) }) //declaring a viem tool to read through blockchain
    console.log("🔍 Public client created.")

    //ERC20 approve

    //declaring erc20Abi and only use two of its functions approve and decimals
    const erc20Abi = parseAbi([
        "function approve(address spender, uint256 amount) external returns (bool)",
        "function decimals() view returns (uint8)"
    ])


    console.log("📘 ERC20 ABI parsed.")

    //declaring a variable called decimals by using publicClient we are viewing decimal of a particular token
    const decimals = await publicClient.readContract({
        address: token,
        abi: erc20Abi,
        functionName: "decimals",
    })

    // declaring parsedAmount which contains amount*10^decimals
    const parsedAmount = parseUnits(amount, decimals)


    //calling approve function for giving approval to access the erc20 token sent by user to contract address
    const approveTx = await walletClient.writeContract({
        address: token,
        abi: erc20Abi,
        functionName: "approve",
        args: [contractAddress, parsedAmount],
        account,
        chain,


    })

    console.log("Approval tx:", approveTx)
    await publicClient.waitForTransactionReceipt({ hash: approveTx }); //Waits for the approveTx hash from the blockchain


    //Lock tokens
    const { request } = await publicClient.simulateContract({
        address: contractAddress,
        abi: lockAbi,
        functionName: "lockToken",
        args: [token, parsedAmount, BigInt(duration)],
        account,
        chain,

    })

    const txHash = await walletClient.writeContract(request) // sends transaction request to wallet for broadcasting it to network
    console.log("Lock tx:", txHash)


}

async function withdrawTokens() {
    //getting input values and preparing for transaction
    const lockId = BigInt(lockIdInput.value)
    const [account] = await walletClient.requestAddresses()
    const chain = await getCurrentChain(walletClient)

    publicClient = createPublicClient({ transport: custom(window.ethereum) })

    //simulating contract to check the desired data
    const { request } = await publicClient.simulateContract({
        address: contractAddress,
        abi: lockAbi,
        functionName: "withdrawTokens",
        args: [lockId],
        account,
        chain,
    })
    // sends transaction request to wallet for broadcasting it to network 
    const txHash = await walletClient.writeContract(request)
    console.log("Withdraw tx:", txHash)
}

// gives  All lock info done by user
async function getLockInfo() {
    const [account] = await walletClient.requestAddresses();
    const chain = await getCurrentChain(walletClient);
    publicClient = createPublicClient({ transport: custom(window.ethereum) })

    const lockCount = await publicClient.readContract({
        address: contractAddress,
        abi: lockAbi,
        functionName: 'getLockCount',
        args: [account],
        account,
        chain,
    });

    const locks = [];
    for (let i = 0; i < lockCount; i++) {
        const lock = await publicClient.readContract({
            address: contractAddress,
            abi: lockAbi,
            functionName: "userLocks",
            args: [account, i],
        })

        locks.push(lock);
    }
    output.innerText = ""; // Clear previous output

    locks.forEach((lock, i) => {
        output.innerText += `🔒 Lock ${i}\n`;
        output.innerText += `📦 Token: ${lock[0]}\n`;
        output.innerText += `💰 Amount: ${lock[1]}\n`;
        output.innerText += `⏰ Unlock Time: ${new Date(Number(lock[2]) * 1000)}\n\n`;
    });


}

async function getCurrentChain(client) {
    const chainId = await client.getChainId()
    return defineChain({
        id: chainId,
        name: "CustomChain",
        nativeCurrency: { name: "ETH", symbol: "ETH", decimals: 18 },
        rpcUrls: { default: { http: ["http://localhost:8545"] } },
    })
}


lockBtn.onclick = lockToken
connectBtn.onclick = Connect
withdrawBtn.onclick = withdrawTokens
infoBtn.onclick = getLockInfo


