source .env
export admin=0x517ececd29116499f4a1b64b094da79ba08dfd54a3edaa316134c41f8160973
export carol=0x5686a647a9cdd63ade617e0baf3b364856b813b508f03903eb58a7e622d5855
export david=0x765149d6bc63271df7b0316537888b81aa021523f9516a05306f10fd36914da
export admin_account=katana-0
export carol_account=katana-1
export david_account=katana-2

# One-time
starkli account fetch $admin --output $admin_path
starkli account fetch $carol --output $carol_path
starkli account fetch $david --output $david_path

# Deploy
scarb build
starkli declare ./target/dev/meson_starknet_demo_MyUSDToken.contract_class.json
starkli deploy 0x03fda322e44c0e24e5e99686104bdf5c330fc854c886cc8c624fe9a19c70f18d $admin
export mytoken=

starkli call $mytoken name
starkli call $mytoken balance_of $admin

starkli declare ./target/dev/meson_starknet_demo_HashTimeLock.contract_class.json
starkli deploy 0x0210c74ae9c2909312484e9271f5c098361bf5e8f902281f4142c50c7e4b0b5d $mytoken
export htlc=

# Approve & transfer
starkli invoke $mytoken approve $htlc u256:0xffffffffffffffffff  # ~4722.36 e18
starkli invoke $mytoken transfer $carol u256:0xffffffffffffffffff
starkli invoke $mytoken transfer $david u256:0xffffffffffffffffff
starkli call $mytoken allowance $admin $htlc
starkli call $mytoken balance_of $carol
starkli call $mytoken balance_of $david


# HTLC user journey
### Hash value: c5ab957f679c2bb7b779af1990a31931 8fcb3db479af295da5625a797d90d908
### Secret    : 0100000c3500c0f000000000d19b03ec 0000000a8c00655757b0e708ff0266ff

starkli invoke $htlc lock_asset 0x8fcb3db479af295da5625a797d90d908 0xc5ab957f679c2bb7b779af1990a31931 300 u256:0xffffffffffffffff $carol # ~ 18.45
starkli call $htlc view_current_locked_assets 0x8fcb3db479af295da5625a797d90d908 0xc5ab957f679c2bb7b779af1990a31931 
starkli invoke --account $carol_account $htlc claim_asset 0x0000000a8c00655757b0e708ff0266ff 0x0100000c3500c0f000000000d19b03ec
