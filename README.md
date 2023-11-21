# Meson-HTLC-Demo

## Introduction

Welcome to [Meson](https://meson.fi/), the faster and safer way to execute low-cost, zero-slippage universal cross-chain swaps across all leading blockchains and layer-2 rollups.

Meson has been launched on 16 high-performance chains, including Ethereum, BNB Chain, Tron, Avalanche, Polygon, Arbitrum, Optimism, and more. Our Solidity code is publicly available on GitHub at [meson-contracts-solidity](https://github.com/MesonFi/meson-contracts-solidity) and is ready to support new EVM chains.

Additionally, we're expanding our support to Non-EVM chains and actively developing corresponding contracts, such as [meson-contracts-aptos](https://github.com/MesonFi/meson-contracts-aptos) and [meson-contracts-solana-rust](https://github.com/MesonFi/meson-contracts-solana-rust). Currently, we are developing a Cairo contract for Starknet, and this project is a simple transaction demo. Our technical product is based on the **HTLC (Hashed Timelock Contract)** prototype, and this HTLC Demo is our first implementation. For more technical details, please visit our [documentation](https://docs.meson.fi/).

<br>

## Running the Demo

### Setup environment

First, install `katana`, `scarb`, and `starkli`. See this link for guidance: [StarkNet Tooling](https://book.starknet.io/ch02-02-starkli-scarb-katana.html).

Then, configure your `.env` file. Our example utilizes a local node (you can easily start a local network with `katana`), like this:

```dotenv
STARKNET_ACCOUNT=katana-0
STARKNET_RPC=http://0.0.0.0:5050
```

Then, initialize the variables by running the following commands. Replace the variable values if you're not using a local node. Otherwise, we suggest using these as-is.

```bash
source .env
export admin=0x517ececd29116499f4a1b64b094da79ba08dfd54a3edaa316134c41f8160973
export carol=0x5686a647a9cdd63ade617e0baf3b364856b813b508f03903eb58a7e622d5855
export david=0x765149d6bc63271df7b0316537888b81aa021523f9516a05306f10fd36914da
export admin_account=katana-0
export carol_account=katana-1
export david_account=katana-2
```

Open another terminal, start `katana`, and leave it running:

```bash
katana
```

<br>

### Deploy the contracts

Begin by compiling the Token contract, followed by its declaration and deployment.

```bash
scarb build
starkli declare ./target/dev/meson_starknet_demo_MyUSDToken.contract_class.json

# ========================== Example Output ==========================
# Declaring Cairo 1 class: 0x03fda322e44c0e24e5e99686104bdf5c330fc854c886cc8c624fe9a19c70f18d
# Compiling Sierra class to CASM with compiler version 2.1.0...
# CASM class hash: 0x0394e25b06ed6099babb0cf9cec66c58f46b27931cb637cdafa03311114f3376
# Contract declaration transaction: 0x03a7ea28d008ac2d2329762361f32f9843ae1e2edfb7781ac9cd5d6783f871f8
# Class hash declared:
# 0x03fda322e44c0e24e5e99686104bdf5c330fc854c886cc8c624fe9a19c70f18d

# Use the "class hash" value above
starkli deploy <class_hash_value_token> $admin

# ========================== Example Output ==========================
# Deploying class 0x03fda322e44c0e24e5e99686104bdf5c330fc854c886cc8c624fe9a19c70f18d with salt 0x07125b5c763191d927e2a3646b8920fbd4257c40b2cbe0458e225336753317b9...
# The contract will be deployed at address 0x06fcc44611637613344ae8280bd1e10b569cd8dd7a49c2d466e760d86b301a04
# Contract deployment transaction: 0x05178f9e9b9a4417c0894e09ce6e13e06023ce766206890f73e91113d38e0420
# Contract deployed:
# 0x06fcc44611637613344ae8280bd1e10b569cd8dd7a49c2d466e760d86b301a04

# Use the "contract deployed" value above
export mytoken=<contract_address_token>
```

Then compile, declare, and deploy the HTLC contract.

```bash
starkli declare ./target/dev/meson_starknet_demo_HashTimeLock.contract_class.json
# ... (the output)

# Use the "class hash" value above
starkli deploy <class_hash_value_htlc> $mytoken
# ... (the output)

# Use the "contract deployed" value above
export htlc=<contract_address_htlc>
```

After deploying these contracts, you can start interacting with them. 

<br>

### Transfer and Approve Tokens

Initially, we pre-minted 1 billion tokens for the token contract's deployer (`admin`). Next, proceed to transfer tokens to Carol and David and then approve a certain transfer amount from HTLC's Sender (Carol) to the HTLC contract.

```bash
starkli call $mytoken symbol
# Should be ["0x4d555344"], that's "MUSD"

starkli call $mytoken name
# Should be ["0x4d79555344546f6b656e"], that's "MyUSDToken"

starkli call $mytoken balance_of $admin
# Should be ["0x33b2e3c9fd0803ce8000000", "0x0"], that's 1 billion token with 18 decimals (10^9 * 10*18)

export approve_amount=0xffffffffffffffffff
export transfer_amount=0xffffffffffffffffff
# That's ~4722.36 $MUSD

starkli invoke $mytoken transfer $carol u256:$transfer_amount
starkli invoke $mytoken transfer $david u256:$transfer_amount
starkli invoke --account $carol_account $mytoken approve $htlc u256:$approve_amount

starkli call $mytoken allowance $carol $htlc
# Should be ["0xffffffffffffffffff", "0x0"]

starkli call $mytoken balance_of $carol
# Should be ["0xffffffffffffffffff", "0x0"]

starkli call $mytoken balance_of $david
# Should be ["0xffffffffffffffffff", "0x0"]
```

<br>

### Interact with HTLC

Next, we embark on the user journey within the HTLC framework.

Imagine Carol sets a `secret`, known exclusively to her:

`0100000c3500c0f000000000d19b03ec0000000a8c00655757b0e708ff0266ff`

And calculates its **keccak256** hash:

`c5ab957f679c2bb7b779af1990a319318fcb3db479af295da5625a797d90d908`

Carol then locks some $MUSD in the contract with the hash, the transfer amount, and the receiver, David, claiming that "David can only withdraw this money before my set expiration time if he provides the original value (my `secret`) of this hash."

To simulate Carol's operation:

```bash
export time_limit=300
# That's 300 seconds

export lock_amount=0xffffffffffffffff
# That's ~18.45 $MUSD

starkli invoke $htlc --account $carol_account lock_asset 0x8fcb3db479af295da5625a797d90d908 0xc5ab957f679c2bb7b779af1990a31931 $time_limit u256:$lock_amount $david
# Notice that we should separately input the "low part" and the "high part" of the hash value
```

Subsequently, anyone can access the current locked asset information by using this hash:

```bash
starkli call $htlc view_current_locked_assets 0x8fcb3db479af295da5625a797d90d908 0xc5ab957f679c2bb7b779af1990a31931
# [
#     "0xffffffffffffffff",  # The locked assets' amount (u256 type)
#     "0x00",                # The "high part" of the amount
#     "0x655c5cd1",          # The expire timestamp
#     "0x0765149d6bc63271df7b0316537888b81aa021523f9516a05306f10fd36914da"
#                            # The expected receiver's address (David)
# ]
```

In a practical scenario, Carol would disclose her Secret to David, enabling him to withdraw the assets:

```bash
starkli invoke $htlc --account $david_account claim_asset 0x0000000a8c00655757b0e708ff0266ff 0x0100000c3500c0f000000000d19b03ec
```

Compare Carol and David's asset balances before and after to see the changes:

```bash
starkli call $mytoken balance_of $carol
# Should be ["0xff0000000000000000", "0x0"]

starkli call $mytoken balance_of $david
# Should be ["0x0100fffffffffffffffe", "0x0"]
```

Congratulations, you have completed an HTLC transfer!
