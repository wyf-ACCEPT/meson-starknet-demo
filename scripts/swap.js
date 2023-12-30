const { Account, Contract, RpcProvider } = require('starknet')
const { parseUnits, parseEther, formatUnits, toBigInt, toBeHex,  } = require('ethers')
const { readFileSync } = require('fs')
require('dotenv').config()

main = async function () {
  // initialize provider & account
  const provider = new RpcProvider({ nodeUrl: "http://127.0.0.1:5050/rpc" })
  const admin = new Account(provider, process.env.ADDRESS_ADMIN, process.env.PRIVATE_KEY_ADMIN)
  const carol = new Account(provider, process.env.ADDRESS_CAROL, process.env.PRIVATE_KEY_CAROL)
  const david = new Account(provider, process.env.ADDRESS_DAVID, process.env.PRIVATE_KEY_DAVID)

  // load contract
  const usdcABI = JSON.parse(
    readFileSync('./target/dev/meson_starknet_MockToken.contract_class.json')
  ).abi
  const mockUsdcAddress = process.env.MOCKUSDC_ADDRESS
  const mockUsdc = new Contract(usdcABI, mockUsdcAddress, provider)

  const mesonABI = JSON.parse(
    readFileSync('./target/dev/meson_starknet_Meson.contract_class.json')
  ).abi
  const mesonAddress = process.env.MESON_ADDRESS
  const meson = new Contract(mesonABI, mesonAddress, provider)


  // log contract info
  const decimals = await mockUsdc.decimals()
  console.log('✅  Mock USDC connected at ', mockUsdc.address)
  console.log('    Mock USDC decimals = ', decimals)
  console.log('✅  Meson connected at ', meson.address)
  console.log('    Meson\'s owner -> ', toBeHex(await meson.getOwner()))
  console.log('    Meson\'s premiujm manager -> ', toBeHex(await meson.getOwner()))

  const supportedTokens = await meson.getSupportedTokens()
  console.log('\n✅  Supported token now: ')
  for (let i = 0; i < supportedTokens[0].length; i++) {
    console.log(
      '      token index', supportedTokens[1][i].toString(), 
      ' -> ', toBeHex(supportedTokens[0][i])
    )
  }

  
  // LP register & deposit
  const mockUsdcIndex = 2
  const poolIndex = 5
  const poolTokenIndex = mockUsdcIndex * 0x10000000000 + poolIndex
  meson.connect(carol)

  /** For the first time */
  // console.log('\n🚀  Register LP & Deposit token...')
  // await provider.waitForTransaction(
  //   (await meson.depositAndRegister(
  //     parseUnits('12000', decimals), poolTokenIndex
  //   )).transaction_hash
  // )
  // console.log('✅  Transaction done.')

  /** Directly deposit */
  console.log('\n🚀  Deposit token...')
  await provider.waitForTransaction(
    (await meson.deposit(
      parseUnits('200', decimals), poolTokenIndex
    )).transaction_hash
  )
  console.log('✅  Transaction done.')

  // log balances
  console.log('\n✅  Mock USDC balances:')
  console.log(
    '    Carol    = ',
    formatUnits((await mockUsdc.balanceOf(carol.address)).toString(), decimals)
  )
  console.log(
    '    Contract = ',
    formatUnits((await mockUsdc.balanceOf(meson.address)).toString(), decimals)
  )
  console.log(
    '    Carol (deposit in pool) = ',
    formatUnits((await meson.getBalanceOfPoolToken(poolTokenIndex)).toString(), decimals)
  )



  console.log()
}

main()