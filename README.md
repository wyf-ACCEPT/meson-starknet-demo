# Meson Contracts Cairo

## Introduction

Welcome to [Meson](https://meson.fi/), the faster and safer way to execute low-cost, zero-slippage universal cross-chain swaps across all leading blockchains and layer-2 rollups.

Meson has been launched on 16 high-performance chains, including Ethereum, BNB Chain, Tron, Avalanche, Polygon, Arbitrum, Optimism, and more. Our Solidity code is publicly available on GitHub at [meson-contracts-solidity](https://github.com/MesonFi/meson-contracts-solidity) and is ready to support new EVM chains.

Additionally, we're expanding our support to Non-EVM chains and actively developing corresponding contracts, such as [meson-contracts-aptos](https://github.com/MesonFi/meson-contracts-aptos) and [meson-contracts-solana-rust](https://github.com/MesonFi/meson-contracts-solana-rust). Currently, we are developing a Cairo contract for Starknet, and this project is a simple transaction demo. Our technical product is based on the **HTLC (Hashed Timelock Contract)** prototype, and this HTLC Demo is our first implementation. For more technical details, please visit our [documentation](https://docs.meson.fi/).

<br>

## Running the Demo

### 1. Setup environment

First, install `katana`, `scarb`, and `starkli`. See this link for guidance: [StarkNet Tooling](https://book.starknet.io/ch02-02-starkli-scarb-katana.html).

Then, configure your `.env` file. Our example utilizes a local node (you can easily start a local network with `katana`). See `.env.example` for reference.

```dotenv
export STARKNET_ACCOUNT=katana-0
export STARKNET_RPC=http://0.0.0.0:5050

PRIVATE_KEY_ADMIN=0x1800000000300000180000000000030000000000003006001800006600
PRIVATE_KEY_CAROL=0x33003003001800009900180300d206308b0070db00121318d17b5e6262150b
PRIVATE_KEY_DAVID=0x1c9053c053edf324aec366a34c6901b1095b07af69495bffec7d7fe21effb1b

ADDRESS_ADMIN=0x517ececd29116499f4a1b64b094da79ba08dfd54a3edaa316134c41f8160973
ADDRESS_CAROL=0x5686a647a9cdd63ade617e0baf3b364856b813b508f03903eb58a7e622d5855
ADDRESS_DAVID=0x765149d6bc63271df7b0316537888b81aa021523f9516a05306f10fd36914da

MOCKUSDC_ADDRESS=
MESON_ADDRESS=

ETH_INITIATOR_PK=
ETH_INITIATOR_ADDRESS=
```

- The `PRIVATE_KEY_ADMIN`, `PRIVATE_KEY_CAROL`, `PRIVATE_KEY_DAVID`, `ADDRESS_ADMIN`, `ADDRESS_CAROL`, and `ADDRESS_DAVID` variables are pre-defined since it's only used in the local net. You can use them as-is or replace them with your own wallet.

- The `STARKNET_ACCOUNT` and `STARKNET_RPC` variables are used to connect to the Starknet node. If you're using a local node, you can use them as-is. Otherwise, replace them with your own values.

- The `MOCKUSDC_ADDRESS` and `MESON_ADDRESS` variables are used to connect to the Mock USDC contract and Meson contract. They will be filled in automatically when you deploy the contracts.

- The `ETH_INITIATOR_PK` and `ETH_INITIATOR_ADDRESS` variables are used to connect to the Ethereum node. You should **replace them with your own wallet**.

When you finished this, you should open another terminal. Start `katana`, and leave it running:

```bash
source .env
katana
```

<br>

### 2. Deploy the contracts

Begin by compiling the Token contract, followed by its declaration and deployment.

```bash
# Compile the contract
yarn build

# ========================== Example Output ==========================
# yarn run v1.22.17
# $ scarb build
#    Compiling meson_starknet v0.1.0 (/Users/wangyifan/Desktop/Blockchain/Starknet/meson-starknet-contracts/Scarb.toml)
#     Finished release target(s) in 11 seconds
# ✨  Done in 10.67s.

# Deploy the contract
yarn deploy

# ========================== Example Output ==========================
# yarn run v1.22.17
# $ ./scripts/deploy.sh
# Sierra compiler version not specified. Attempting to automatically decide version to use...
# Unknown network. Falling back to the default compiler version 2.1.0. Use the --compiler-version flag to choose a different version.
# Declaring Cairo 1 class: 0x058d753a72e93685085ea0bd496d3b6fa8066cf694f82ba9850548bb3cb61708
# .....................
# .....................
# .....................
# The contract will be deployed at address 0x0620b6c44dfb96db85637db28a25067ce2923d913d1161f5474d1233f2d19ccb
# Contract deployment transaction: 0x0028b75b4ccd47617595d68d227bff22fb083b9ec9d92e575a2b010a1243de7d
# Contract deployed:
# ✨  Done in 5.32s.
```

After finish this scripts, the `MOCKUSDC_ADDRESS` and `MESON_ADDRESS` variables in `.env` will be filled in automatically.

<br>

### 3. Initialize the contracts

In this scripts, we will initialize the Mock USDC contract and the Meson contract. We will firstly transfer some Mock USDC to Carol and David (two mock users), then approve the Meson contract to spend their Mock USDC. Finally, we will add the Mock USDC to the Meson contract's supported token list. See the example output log below for more details.

Run the following commands to initialize the contracts:

```bash
yarn initialize

# ========================== Example Output ==========================
# yarn run v1.22.17
# $ node ./scripts/initialize.js
# ✅  Mock USDC connected at  0x034e8ab9ad3eb86d22a5edfe8594cf769bba9b0abee768c2ef3ce873160eb56c
#     Mock USDC decimals =  6n
# ✅  Meson connected at  0x0620b6c44dfb96db85637db28a25067ce2923d913d1161f5474d1233f2d19ccb
#     Meson's owner           ->  0x0517ececd29116499f4a1b64b094da79ba08dfd54a3edaa316134c41f8160973
#     Meson's premium manager ->  0x0517ececd29116499f4a1b64b094da79ba08dfd54a3edaa316134c41f8160973

# 🚀  Transfer tokens to Carol...
# ✅  Transaction done.

# 🚀  Transfer tokens to David...
# ✅  Transaction done.

# ✅  Mock USDC balances:
#     Admin =  999910000.0
#     Carol =  45000.0
#     David =  45000.0

# 🚀  Approve Meson to spend tokens...
# ✅  Transaction done.
# ✅  Transaction done.

# ✅  Mock USDC allowances:
#     Carol -> Meson =  45000.0
#     David -> Meson =  45000.0

# 🚀  Add supported token...
# ✅  Transaction done.

# ✅  Supported token now: 
#       token index 2  ->  0x034e8ab9ad3eb86d22a5edfe8594cf769bba9b0abee768c2ef3ce873160eb56c
# ✨  Done in 52.31s.
```

<br>

### 4. Interact with Meson

Now, we can interact with the Meson contract. We will firstly deposit some Mock USDC to the Meson contract, then create an HTLC transfer from Carol to David. Finally, we will withdraw the Mock USDC from the Meson contract. See the Meson documentation for more details: [Meson Documentation](https://docs.meson.fi/).

Run the following commands to interact with the Meson contract:

```bash
yarn swap

# ========================== Example Output ==========================
# yarn run v1.22.17
# $ node ./scripts/swap.js
# ✅  Mock USDC connected at  0x034e8ab9ad3eb86d22a5edfe8594cf769bba9b0abee768c2ef3ce873160eb56c
#     Mock USDC decimals =  6n
# ✅  Meson connected at  0x0620b6c44dfb96db85637db28a25067ce2923d913d1161f5474d1233f2d19ccb
#     Meson's owner ->  0x0517ececd29116499f4a1b64b094da79ba08dfd54a3edaa316134c41f8160973
#     Meson's premium manager ->  0x0517ececd29116499f4a1b64b094da79ba08dfd54a3edaa316134c41f8160973

# ✅  Supported token now: 
#       token index 2  ->  0x034e8ab9ad3eb86d22a5edfe8594cf769bba9b0abee768c2ef3ce873160eb56c

# 🚀  Register LP & Deposit token...
# ✅  Transaction done.

# ✅  Mock USDC balances:
#     Carol    =  33000.0
#     Contract =  12015.0
#     Carol (deposit in pool) =  12000.0

# ✅  Initiator   : 0x952fD793D841D7C764012aCE5D7333cD95294A99
# ✅  Encoded swap: 0x010000e4e1c0c00000000000e7552620000000000000659ad1d2232c02232c02
# ✅  Swap ID     : 0xbdc5c07b8cd430d1b3bd72df0a21543ee0914c7d1c3a47be88fb46964d78373d

# 🚀  Step 1.1 Post swap...
# ✅  Transaction done.

# 🚀  Step 1.2 Bond swap...
# ✅  Transaction done.
# ✅  Posted swap on 0x010000e4e1c0c00000000000e7552620000000000000659ad1d2232c02232c02: 
#       pool index  : 5
#       initiator   : 0x952fd793d841d7c764012ace5d7333cd95294a99
#       from address: 0x0765149d6bc63271df7b0316537888b81aa021523f9516a05306f10fd36914da

# 🚀  Step 2. Lock swap...
# ✅  Transaction done.
# ✅  Locked swap on 0x010000e4e1c0c00000000000e7552620000000000000659ad1d2232c02232c02 + 0x952fd793d841d7c764012ace5d7333cd95294a99: 
#       pool index  : 5
#       until       : 1704642095
#       recipient   : 0x0765149d6bc63271df7b0316537888b81aa021523f9516a05306f10fd36914da

# 🚀  Step 3. Release...
# ✅  Transaction done.
# ✅  Locked swap on 0x010000e4e1c0c00000000000e7552620000000000000659ad1d2232c02232c02 + 0x952fd793d841d7c764012ace5d7333cd95294a99: 
#       pool index  : 0
#       until       : 0
#       recipient   : 0x0620b6c44dfb96db85637db28a25067ce2923d913d1161f5474d1233f2d19ccb

# 🚀  Step 4. Execute swap...
# ✅  Transaction done.
# ✅  Posted swap on 0x010000e4e1c0c00000000000e7552620000000000000659ad1d2232c02232c02: 
#       pool index  : 0
#       initiator   : 0x00
#       from address: 0x00

# ✨  Done in 61.94s.
```

Congratulations, you have completed a Meson swap!
