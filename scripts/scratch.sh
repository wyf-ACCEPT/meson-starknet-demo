export admin=0x517ececd29116499f4a1b64b094da79ba08dfd54a3edaa316134c41f8160973
export carol=0x5686a647a9cdd63ade617e0baf3b364856b813b508f03903eb58a7e622d5855
export david=0x765149d6bc63271df7b0316537888b81aa021523f9516a05306f10fd36914da
export admin_account=katana-0
export carol_account=katana-1
export david_account=katana-2
source .env

# One-time
starkli account fetch $admin --output $admin_path
starkli account fetch $carol --output $carol_path
starkli account fetch $david --output $david_path

# Deploy
scarb build
starkli declare ./target/dev/meson_starknet_demo_MyUSDToken.contract_class.json

# ========================== Example Output ==========================
# Declaring Cairo 1 class: 0x03fda322e44c0e24e5e99686104bdf5c330fc854c886cc8c624fe9a19c70f18d
# Compiling Sierra class to CASM with compiler version 2.1.0...
# CASM class hash: 0x0394e25b06ed6099babb0cf9cec66c58f46b27931cb637cdafa03311114f3376
# Contract declaration transaction: 0x03a7ea28d008ac2d2329762361f32f9843ae1e2edfb7781ac9cd5d6783f871f8
# Class hash declared:
# 0x03fda322e44c0e24e5e99686104bdf5c330fc854c886cc8c624fe9a19c70f18d

starkli deploy 0x03fda322e44c0e24e5e99686104bdf5c330fc854c886cc8c624fe9a19c70f18d $admin

# ========================== Example Output ==========================
# Deploying class 0x03fda322e44c0e24e5e99686104bdf5c330fc854c886cc8c624fe9a19c70f18d with salt 0x07125b5c763191d927e2a3646b8920fbd4257c40b2cbe0458e225336753317b9...
# The contract will be deployed at address 0x06fcc44611637613344ae8280bd1e10b569cd8dd7a49c2d466e760d86b301a04
# Contract deployment transaction: 0x05178f9e9b9a4417c0894e09ce6e13e06023ce766206890f73e91113d38e0420
# Contract deployed:
# 0x06fcc44611637613344ae8280bd1e10b569cd8dd7a49c2d466e760d86b301a04

export mytoken=0x06fcc44611637613344ae8280bd1e10b569cd8dd7a49c2d466e760d86b301a04

starkli call $mytoken name
starkli call $mytoken balance_of $admin

starkli declare ./target/dev/meson_starknet_demo_HashTimeLock.contract_class.json
starkli deploy 0x01e92394182f132059b89834651909e938810bd19379b75e3013732e94a8830d $mytoken
export htlc=0x04c88290e58f8961f0185549d46dc490c4917b1655bdab8df83414959d23e9d1

# Approve & transfer
export transfer_amount=0xffffffffffffffffff
starkli invoke $mytoken approve $htlc u256:$transfer_amount  # ~4722.36 e18
starkli invoke $mytoken transfer $carol u256:$transfer_amount
starkli invoke $mytoken transfer $david u256:$transfer_amount
starkli call $mytoken allowance $admin $htlc
starkli call $mytoken balance_of $carol
starkli call $mytoken balance_of $david


# HTLC user journey
### Hash value: c5ab957f679c2bb7b779af1990a31931 8fcb3db479af295da5625a797d90d908
### Secret    : 0100000c3500c0f000000000d19b03ec 0000000a8c00655757b0e708ff0266ff

export lock_amount=0xffffffffffffffff
starkli invoke $htlc --account $carol_account lock_asset 0x8fcb3db479af295da5625a797d90d908 0xc5ab957f679c2bb7b779af1990a31931 300 u256:$lock_amount $david # ~ 18.45

starkli call $htlc view_current_locked_assets 0x8fcb3db479af295da5625a797d90d908 0xc5ab957f679c2bb7b779af1990a31931 
# [
#     "0x000000000000000000000000000000000000000000000000ffffffffffffffff",
#     "0x0000000000000000000000000000000000000000000000000000000000000000",
#     "0x00000000000000000000000000000000000000000000000000000000655c5cd1",
#     "0x0765149d6bc63271df7b0316537888b81aa021523f9516a05306f10fd36914da"
# ]

starkli invoke $htlc --account $david_account claim_asset 0x0000000a8c00655757b0e708ff0266ff 0x0100000c3500c0f000000000d19b03ec
