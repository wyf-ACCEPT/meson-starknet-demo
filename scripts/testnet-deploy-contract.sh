# Don't directly run this script! Instead, run the following command line by line and follow the instructions.

# See https://book.starkli.rs/signers and https://book.starkli.rs/accounts for more.

# Use https://goerli.starkgate.starknet.io/ to bridge Goerli ETH.

# Use the guidance in https://www.starknetjs.com/docs/guides/create_account to create a starknet account. Don't use `starkli signer gen-keypair`, and don't create a wallet in Argent wallet. It's 3 diffrent things, and they're not compatible with each other!!! 🤬🤬🤬

STARKNET_KEYSTORE=./account/keystore.json
ACCOUNT_ADMIN_KEYSTORE=./account/testnet_admin.json
STARKNET_TESTNET=https://starknet-goerli.g.alchemy.com/v2/JDkRaXE932elAFfLGl3IzE7jP0aekgAM

starkli account oz init --keystore $STARKNET_KEYSTORE $ACCOUNT_ADMIN_KEYSTORE

# You'll get an address, refund it with Goerli ETH from https://goerli.starkgate.starknet.io/.

# Then, deploy this wallet.

starkli account deploy --keystore $STARKNET_KEYSTORE --rpc $STARKNET_TESTNET $ACCOUNT_ADMIN_KEYSTORE

# You've got an address.

ADDRESS_ADMIN_KEYSTORE=0x3ae38c81fdc403f9ec44215ca4978cca2aff3255cc70c1d99e31a93b1afb435

# Then, declare and deploy the contracts.

MOCKUSDC_CLASS=$(starkli declare --account $ACCOUNT_ADMIN_KEYSTORE --keystore $STARKNET_KEYSTORE --rpc $STARKNET_TESTNET ./target/dev/meson_starknet_MockToken.contract_class.json | tail -n 1)
# -> 0x058d753a72e93685085ea0bd496d3b6fa8066cf694f82ba9850548bb3cb61708

MOCKUSDC_ADDRESS=$(starkli deploy --account $ACCOUNT_ADMIN_KEYSTORE --keystore $STARKNET_KEYSTORE --rpc $STARKNET_TESTNET $MOCKUSDC_CLASS $ADDRESS_ADMIN | tail -n 1)
# -> 0x07c1c0acaac0837b66865f991d0dc6d553652503862614d17aa02e923ba4c681

MESON_CLASS=$(starkli declare --account $ACCOUNT_ADMIN_KEYSTORE --keystore $STARKNET_KEYSTORE --rpc $STARKNET_TESTNET ./target/dev/meson_starknet_Meson.contract_class.json | tail -n 1)
# -> 0x07c1c0acaac0837b66865f991d0dc6d553652503862614d17aa02e923ba4c681

MESON_ADDRESS=$(starkli deploy --account $ACCOUNT_ADMIN_KEYSTORE --keystore $STARKNET_KEYSTORE --rpc $STARKNET_TESTNET $MESON_CLASS $ADDRESS_ADMIN | tail -n 1)
# -> 0x030eb41a672017cac279ed71706794b3ea30aee4a20580f117a9d856dd0b03ff

# We found that the `keystore` typed account can't be loaded in the JavaScript SDK, so we use the `privateKey` typed account instead.

# We transfer the ownership of the contracts to the ADDRESS_ADMIN.

starkli invoke --account $ACCOUNT_ADMIN_KEYSTORE --keystore $STARKNET_KEYSTORE --rpc $STARKNET_TESTNET $MOCKUSDC_ADDRESS transfer $ADDRESS_ADMIN u256:1000000000000

starkli invoke --account $ACCOUNT_ADMIN_KEYSTORE --keystore $STARKNET_KEYSTORE --rpc $STARKNET_TESTNET $MESON_ADDRESS transferOwnership $ADDRESS_ADMIN

# Check the admin's balance
starkli call --rpc $STARKNET_TESTNET $MOCKUSDC_ADDRESS balanceOf $ADDRESS_ADMIN # -> 100000000000000

# Check the ownership...
starkli call --rpc $STARKNET_TESTNET $MESON_ADDRESS getOwner # -> ADDRESS_ADMIN

# Finally, you've prepared the contracts for the testnet. Then run `yarn initialize` to initialize the contracts.
