export admin=0x517ececd29116499f4a1b64b094da79ba08dfd54a3edaa316134c41f8160973

scarb build
starkli declare ./target/dev/meson_starknet_demo_MyUSDToken.contract_class.json
starkli deploy 0x03fda322e44c0e24e5e99686104bdf5c330fc854c886cc8c624fe9a19c70f18d $admin
export mytoken=0x02a7b396d412c59443fa50d0a6746280f1f9196faf3a5037b9541abcb8a257ce

starkli call $mytoken name
starkli call $mytoken balance_of $admin

starkli declare ./target/dev/meson_starknet_demo_HashTimeLock.contract_class.json
starkli deploy 0x01ff79797d1d736a3c995ece09f53e56ec72b2d061e96ca828926a11f1af77d1 $mytoken
export htlc=0x036a1a9a22cba2256ede3943f4644992a5a5a4b08249a26c186abf5ca924182f

starkli invoke $mytoken approve $htlc u256:0xffffffffffffffffff  # ~4722.36 e18
starkli call $mytoken allowance $admin $htlc
