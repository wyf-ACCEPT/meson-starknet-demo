const { Account, Contract, RpcProvider } = require('starknet')
const { parseUnits, formatUnits, toBeHex } = require('ethers')
const { readFileSync } = require('fs')
require('dotenv').config()

main = async function () {
  // initialize provider & account
  const provider = new RpcProvider({ nodeUrl: "http://127.0.0.1:5050/rpc" })
  const admin = new Account(provider, process.env.ADDRESS_ADMIN, process.env.PRIVATE_KEY_ADMIN)
  const carol = new Account(provider, process.env.ADDRESS_CAROL, process.env.PRIVATE_KEY_CAROL)
  const david = new Account(provider, process.env.ADDRESS_DAVID, process.env.PRIVATE_KEY_DAVID)

  // deploy contract
  /**
   * There are much annoying bugs while declaring and deploying contracts, 
   *  due to the lag/lack of documentation and examples. So we have to do 
   *  it in the shell for now.
   * 
   * Run `katana` in the shell to build up a Starknet local net and keep 
   *  it running.
   * Then open another shell, and  run `./scripts/deploy.sh` to deploy 
   *  the contract.
   */


  // load contract
  const usdcSierra = JSON.parse(
    readFileSync('./target/dev/meson_starknet_MockToken.contract_class.json')
  )
  const mockUsdcAddress = process.env.MOCKUSDC_ADDRESS
  const mockUsdc = new Contract(usdcSierra.abi, mockUsdcAddress, provider)

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
  console.log('    Meson\'s owner           -> ', toBeHex(await meson.getOwner()))
  console.log('    Meson\'s premium manager -> ', toBeHex(await meson.getOwner()))


  // mint tokens to Carol & David
  mockUsdc.connect(admin)

  console.log('\n🚀 Transfer tokens to Carol...')
  await provider.waitForTransaction(
    (await mockUsdc.transfer(carol.address, parseUnits('45000', decimals))).transaction_hash
  )
  console.log('✅  Transaction done.')

  console.log('\n🚀 Transfer tokens to David...')
  await provider.waitForTransaction(
    (await mockUsdc.transfer(david.address, parseUnits('45000', decimals))).transaction_hash
  )
  console.log('✅  Transaction done.')


  // log balances
  console.log('\n✅  Mock USDC balances:')
  console.log(
    '    Admin = ',
    formatUnits((await mockUsdc.balanceOf(admin.address)).toString(), decimals)
  )
  console.log(
    '    Carol = ',
    formatUnits((await mockUsdc.balanceOf(carol.address)).toString(), decimals)
  )
  console.log(
    '    David = ',
    formatUnits((await mockUsdc.balanceOf(david.address)).toString(), decimals)
  )


  // approve meson to spend tokens
  console.log('\n🚀  Approve Meson to spend tokens...')
  mockUsdc.connect(carol)
  await provider.waitForTransaction(
    (await mockUsdc.approve(mesonAddress, parseUnits('45000', decimals))).transaction_hash
  )
  console.log('✅  Transaction done.')
  mockUsdc.connect(david)
  await provider.waitForTransaction(
    (await mockUsdc.approve(mesonAddress, parseUnits('45000', decimals))).transaction_hash
  )
  console.log('✅  Transaction done.')


  // log allowances
  console.log('\n✅  Mock USDC allowances:')
  console.log(
    '    Carol -> Meson = ',
    formatUnits((await mockUsdc.allowance(carol.address, mesonAddress)).toString(), decimals)
  )
  console.log(
    '    David -> Meson = ',
    formatUnits((await mockUsdc.allowance(david.address, mesonAddress)).toString(), decimals)
  )


  // add supported token
  const mockUsdcIndex = 2
  meson.connect(admin)

  console.log('\n🚀  Add supported token...')
  await provider.waitForTransaction(
    (await meson.addSupportToken(mockUsdcAddress, mockUsdcIndex)).transaction_hash
  )
  console.log('✅  Transaction done.')
  const supportedTokens = await meson.getSupportedTokens()
  console.log('\n✅  Supported token now: ')
  for (let i = 0; i < supportedTokens[0].length; i++) {
    console.log(
      '      token index', supportedTokens[1][i].toString(), 
      ' -> ', toBeHex(supportedTokens[0][i])
    )
  }
}

main()