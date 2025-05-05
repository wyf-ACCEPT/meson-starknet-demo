# Meson Contracts Cairo

## Introduction

Welcome to [Meson](https://meson.fi/), the faster and safer way to execute low-cost, zero-slippage universal cross-chain swaps across all leading blockchains and layer-2 rollups.

Meson has been launched on 16 high-performance chains, including Ethereum, BNB Chain, Tron, Avalanche, Polygon, Arbitrum, Optimism, and more. Our Solidity code is publicly available on GitHub at [meson-contracts-solidity](https://github.com/MesonFi/meson-contracts-solidity) and is ready to support new EVM chains.

Furthermore, we have started supporting new Non-EVM chains and developing corresponding contracts, such as [meson-contracts-aptos](https://github.com/MesonFi/meson-contracts-aptos) and [meson-contracts-solana-rust](https://github.com/MesonFi/meson-contracts-solana-rust). Currently, we are developing a Cairo contract for Starknet, and this project is a simple transaction demo. Our technical product is based on the **HTLC (Hashed Timelock Contract)** prototype, and this HTLC Demo is our first implementation. For more technical details, please visit our [documentation](https://docs.meson.fi/).

<br>

## How to Deploy

## 1. Setup Environment

Before deployment, you need two client tools: **Starkli** and **Scarb**. **Starkli** is a command-line interface that allows you to interact with Starknet, and **Scarb** is a build toolchain and package manager for Cairo and Starknet ecosystems.

### 1.1 Install Starkli

Firstly, install **Starkliup**, the installer for the Starkli environment:

```bash
curl https://get.starkli.sh | sh
```

Restart your terminal and install **Starkli** by:

```bash
starkliup -v 0.4.1
```

While 0.4.1 is the latest version at the time of writing, you can check the [latest release version](https://github.com/xJonathanLEI/starkli/releases) supported by Starkli.

Check your installation by:

```bash
starkli --version       # 0.4.1 (b4223ee)
```

### 1.2 Install Scarb

It's recommended by the official documentation to install Scarb via the asdf version manager. Follow the steps below:

```bash
brew install asdf
asdf plugin add scarb
asdf install scarb 2.11.2
asdf global scarb 2.11.2
```

Check your installation by:

```bash
scarb --version       # 2.11.2 (9c1873c6d 2025-03-11)
```

The version of **Starkli** and **Scarb** should be matched, otherwise you may not be able to declare the contract successfully.

See [Starknet Docs - Setting up your environment](https://docs.starknet.io/quick-start/environment-setup/) for more details.

### 1.3 Setup `.env`

Copy the `.env.example` file to `.env` and fill in the values:

```bash
cp .env.example .env
```

You can use your private RPC provider from [Quicknode](https://dashboard.quicknode.com/endpoints/new/STRK).

---

## 2. Setup Account

Starknet uses smart wallets to manage accounts, not a simple private-key pattern. You should firstly create a wallet in [Argent X Wallet](https://chromewebstore.google.com/detail/argent-x-starknet-wallet/dlcobpjiigpikoobohmabehhmhfoodbb), which is the most popular Starknet wallet. Select `Standard Account` when creating a new account.

### 2.1 Create Keystore

In the Argent X Wallet, navigate to: `Settings section` -> `Select your Account` -> `Export Private Key`.

Create a keystore file with the private key by:

```bash
mkdir -p ~/.starkli-wallets/deployer
starkli signer keystore from-key ~/.starkli-wallets/deployer/keystore.json
# Paste the private key and press Enter
```

You will get a keystore file stored in `~/.starkli-wallets/deployer/keystore.json`. If you use a different path, please also update the `STARKNET_KEYSTORE` in the `.env` file.

### 2.2 Fund Account

- If you're using Starknet Sepolia Testnet, fund your account of Argent X Wallet by [Starknet Faucet](https://blastapi.io/faucets/starknet-sepolia-eth) (recommended). You can also bridge your tETH from Ethereum Sepolia Testnet, but it may take a while.
- If you're using Starknet Mainnet, directly transfer ETH or STRK to your account.

In the Argent X Wallet, navigate to: `Settings section` -> `Select your Account` -> `Deploy account`. Because Starknet uses smart wallets to manage accounts, you need to deploy your account before using it.

### 2.3 Create Account Store

After deploying your account in Argent X Wallet, collect your account information by:

```bash
source .env
starkli account fetch <SMART_WALLET_ADDRESS> --output ~/.starkli-wallets/deployer/account.json
```

If it returns a `ContractNotFound` error, it's probably because your account is not deployed yet. Please redo the steps in [2.2 Fund Account](#22-fund-account) and wait for a few seconds.

Also, if you've changed the default path of the keystore and account store, please update the `STARKNET_ACCOUNT` in the `.env` file.

---

## 3. Deploy Contract

In Starknet, you must declare a contract before deploying it. `Declare` means sending your contract’s code to the network, while `Deploy` means creating an instance of the code you previously declared here.

### 3.1 Compile Contract

Compile the contract by:

```bash
scarb build
```

And you will find the compiled contract under `target/dev` directory.

### 3.2 Declare Contract

Declare the contract by:

```bash
source .env
starkli declare target/dev/meson_starknet_Meson.contract_class.json
```

You will get a result like this:

```log
Declaring Cairo 1 class: 0x5678567856785678567856785678567856785678567856785678567856785678
Compiling Sierra class to CASM with compiler version 2.11.2...
CASM class hash: 0x1234123412341234123412341234123412341234123412341234123412341234
Contract declaration transaction: 0x9abc9abc9abc9abc9abc9abc9abc9abc9abc9abc9abc9abc9abc9abc9abc9abc
Class hash declared:
0x5678567856785678567856785678567856785678567856785678567856785678
```

The `Class hash` is the hash of the contract code, which is used to identify the contract on the network.

### 3.3 Deploy Contract

Deploy the contract by:

```bash
source .env
starkli deploy <CLASS_HASH> <OWNER_ADDRESS>
```

Where `<CLASS_HASH>` is the class hash of the contract you just declared, and `<OWNER_ADDRESS>` is the address of the contract admin.

You will get a result like this:

```log
Deploying class 0x5678567856785678567856785678567856785678567856785678567856785678 with salt 0x1111222211112222111122221111222211112222111122221111222211112222...
The contract will be deployed at address 0xdef0def0def0def0def0def0def0def0def0def0def0def0def0def0def0def0
Contract deployment transaction: 0x3333444433334444333344443333444433334444333344443333444433334444
Contract deployed:
0xdef0def0def0def0def0def0def0def0def0def0def0def0def0def0def0def0
```

The `Contract deployed` is the address of the deployed contract.

---

## 4. Interact with Contract

Finally, you can interact with the contract by using `Starkli`. Use `starkli call` to call the view functions, and use `starkli invoke` to call the write functions.

### 4.1 Transfer Ownership

Transfer ownership by:

```bash
source .env
starkli invoke <CONTRACT_ADDRESS> transferOwnership <NEW_OWNER>
# e.g. starkli invoke 0x053100f633c0d0ec4fb9ac0a3444ab880bc8b5477f33fcf8f41605f30d6cb6da transferOwnership 0x010D40d06B29350BdAd0Df077E5BC001C6AAF62903D81F44230a1e7c195A1396
```

Check the owner by:

```bash
starkli call <CONTRACT_ADDRESS> getOwner
```

### 4.2 Add Support Token

Add a new supported token by:

```bash
source .env
starkli invoke <CONTRACT_ADDRESS> addSupportToken <TOKEN_ADDRESS> <TOKEN_INDEX>
# e.g. starkli invoke 0x053100f633c0d0ec4fb9ac0a3444ab880bc8b5477f33fcf8f41605f30d6cb6da addSupportToken 0x04718f5a0fc34cc1af16a1cdee98ffb20c31f5cd61d6ab07201858f4287c938d 65
```

You can view the result in the [starknet explorer](https://sepolia.starkscan.co/).

Then check the supported tokens by:

```bash
starkli call <CONTRACT_ADDRESS> getSupportedTokens
# e.g. starkli call 0x053100f633c0d0ec4fb9ac0a3444ab880bc8b5477f33fcf8f41605f30d6cb6da getSupportedTokens
```

It will return 2 concatenated arrays, like this:

```log
[
    "0x0000000000000000000000000000000000000000000000000000000000000002",   // Array 1 has 2 tokens
    "0x04718f5a0fc34cc1af16a1cdee98ffb20c31f5cd61d6ab07201858f4287c938d",   // Token-1 address
    "0x049d36570d4e46f48e99674bd3fcc84644ddd6b96f7c741b1562b82f9e004dc7",   // Token-2 address
    "0x0000000000000000000000000000000000000000000000000000000000000002",   // Array 2 has 2 tokens
    "0x0000000000000000000000000000000000000000000000000000000000000041",   // Token-1 index
    "0x0000000000000000000000000000000000000000000000000000000000000043"    // Token-2 index
]
```

