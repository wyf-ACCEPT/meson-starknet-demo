const { Account, Contract, RpcProvider, CallData, ec, hash } = require('starknet')
// const { Account, constants, ec, json, stark, Provider, hash, CallData, RpcProvider } = require("starknet");
const { parseUnits, formatUnits, toBeHex } = require('ethers')
const { readFileSync } = require('fs')
require('dotenv').config()

async function generateAndDeployAddress(provider, privateKey, deploy=false) {
  console.log('\nGenerating address...', )
  const starkKeyPub = ec.starkCurve.getStarkKey(privateKey)
  console.log('    PublicKey =', starkKeyPub)
  const OZaccountConstructorCallData = CallData.compile({ publicKey: starkKeyPub })
  const OZcontractAddress = hash.calculateContractAddressFromHash(
      starkKeyPub,
      process.env.OZ_ACCOUNT_CLASSHASH,
      OZaccountConstructorCallData,
      0
  )
  console.log('✅  Address =', OZcontractAddress)
  if (!deploy) return OZcontractAddress

  const OZaccount = new Account(provider, OZcontractAddress, privateKey)
  const { transaction_hash, contract_address } = await OZaccount.deployAccount({
      classHash: process.env.OZ_ACCOUNT_CLASSHASH,
      constructorCalldata: OZaccountConstructorCallData,
      addressSalt: starkKeyPub
  })
  await provider.waitForTransaction(transaction_hash);
  console.log('✅   New OpenZeppelin account created.', contract_address)
  return OZcontractAddress
}


main = async function () {
  const provider = new RpcProvider({ nodeUrl: process.env.STARKNET_TESTNET })
  const admin = new Account(provider, process.env.ADDRESS_ADMIN, process.env.PRIVATE_KEY_ADMIN)
  const carol = new Account(provider, process.env.ADDRESS_CAROL, process.env.PRIVATE_KEY_CAROL)
  const david = new Account(provider, process.env.ADDRESS_DAVID, process.env.PRIVATE_KEY_DAVID)

  await generateAndDeployAddress(
    provider, process.env.PRIVATE_KEY_ADMIN, false  // Change to true to deploy!
  )
  await generateAndDeployAddress(
    provider, process.env.PRIVATE_KEY_CAROL, false
  )
  await generateAndDeployAddress(
    provider, process.env.PRIVATE_KEY_DAVID, false
  )
  
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