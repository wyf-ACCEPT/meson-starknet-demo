const { Account, Contract, RpcProvider } = require('starknet')
// const { Account, constants, ec, json, stark, Provider, hash, CallData, RpcProvider } = require("starknet");
const { parseUnits, formatUnits, toBeHex } = require('ethers')
const { readFileSync } = require('fs')
require('dotenv').config()

main = async function () {
  const provider = new RpcProvider({ nodeUrl: process.env.STARKNET_TESTNET })
  const admin = new Account(provider, process.env.ADDRESS_ADMIN, process.env.PRIVATE_KEY_ADMIN)
  const carol = new Account(provider, process.env.ADDRESS_CAROL, process.env.PRIVATE_KEY_CAROL)
  const david = new Account(provider, process.env.ADDRESS_DAVID, process.env.PRIVATE_KEY_DAVID)

  const starkKeyPub = ec.starkCurve.getStarkKey(process.env.ADDRESS_ADMIN);
  console.log('publicKey=', starkKeyPub);
  
  // const OZaccountClassHash = "0x2794ce20e5f2ff0d40e632cb53845b9f4e526ebd8471983f7dbd355b721d5a";
  // // Calculate future address of the account
  // const OZaccountConstructorCallData = CallData.compile({ publicKey: starkKeyPub });
  // const OZcontractAddress = hash.calculateContractAddressFromHash(
  //     starkKeyPub,
  //     OZaccountClassHash,
  //     OZaccountConstructorCallData,
  //     0
  // );
  // console.log('Precalculated account address=', OZcontractAddress);


  const erc20Sierra = JSON.parse(
    readFileSync('./target/dev/meson_starknet_MockToken.contract_class.json')
  )
  const gEthAddress = '0x049d36570d4e46f48e99674bd3fcc84644ddd6b96f7c741b1562b82f9e004dc7'
  const gEth = new Contract(erc20Sierra.abi, gEthAddress, provider)
  const decimals = await gEth.decimals()

  console.log('\n✅  Georli ETH balances:')
  console.log(
    '    Admin = ',
    formatUnits((await gEth.balanceOf(admin.address)).toString(), decimals)
  )
  console.log(
    '    Carol = ',
    formatUnits((await gEth.balanceOf(carol.address)).toString(), decimals)
  )
  console.log(
    '    David = ',
    formatUnits((await gEth.balanceOf(david.address)).toString(), decimals)
  )
}

main()