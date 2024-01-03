const { Account, Contract, RpcProvider } = require('starknet')
const { formatUnits, parseUnits, toBeHex, assert, keccak256, Wallet } = require('ethers')
const { readFileSync } = require('fs')
require('dotenv').config()

function buildEncoded(
  amount, expireTs, outToken, inToken,
  salt = 'c00000000000e7552620', fee = '0000000000', 
  ) {
  let version = '01'
  let amountString = amount.toString(16).padStart(10, '0')
  let expireTsString = expireTs.toString(16).padStart(10, '0')
  let outChain = '232c'
  let inChain = '232c'
  let encodedHex = [
    version, amountString, salt, fee, expireTsString, outChain, outToken, inChain, inToken
  ].join('')
  assert(amount < 0x0fffffffff, "Amount should less than $68719.476735!")
  assert(encodedHex.length == 64, "Encodedswap length should be 64!")
  return encodedHex
}

function getExpireTs(delay = 90) {
  return Math.floor(Date.now() / 1e3 + 60 * delay)
}

function getSwapId(encodedHex, initiator) {
  let concat = encodedHex + initiator
  assert(concat.length == 104 && typeof (concat) == 'string', "")
  let hashHex = keccak256(Buffer.from(concat, 'hex')).slice(2)
  return hashHex
}

function signRequest(encodedHex, initiator) {
  let contentHash = keccak256(Buffer.from(encodedHex, 'hex')).slice(2)
  let digestRequest = Buffer.from(keccak256(Buffer.from(
    '7b521e60f64ab56ff03ddfb26df49be54b20672b7acfffc1adeb256b554ccb25' + contentHash, 'hex'
  )).slice(2), 'hex')
  let sig = initiator.signingKey.sign(digestRequest)
  return { r: sig.r, yParityAndS: sig.yParityAndS}
}

function signRelease(encodedHex, initiator, recipient) {
  let contentHash = keccak256(Buffer.from(encodedHex + recipient, 'hex')).slice(2)
  let digestRelease = Buffer.from(keccak256(Buffer.from(
    'd23291d9d999318ac3ed13f43ac8003d6fbd69a4b532aeec9ffad516010a208c' + contentHash, 'hex'
  )).slice(2), 'hex')
  let sig = initiator.signingKey.sign(digestRelease)
  return { r: sig.r, yParityAndS: sig.yParityAndS}
}



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
  console.log('    Meson\'s premium manager -> ', toBeHex(await meson.getOwner()))

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
  // console.log('\n🚀  Deposit token...')
  // await provider.waitForTransaction(
  //   (await meson.deposit(
  //     parseUnits('200', decimals), poolTokenIndex
  //   )).transaction_hash
  // )
  // console.log('✅  Transaction done.')

  // console.log('\n🚀  Withdraw token...')
  // await provider.waitForTransaction(
  //   (await meson.withdraw(
  //     parseUnits('160', decimals), poolTokenIndex
  //   )).transaction_hash
  // )
  // console.log('✅  Transaction done.')

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


  // swap phase
  const amount = 15_000_000

  const initiator = new Wallet(process.env.ETH_INITIATOR_PK)
  const encodedHex = buildEncoded(amount, getExpireTs(), '02', '02')
  const swapId = getSwapId(encodedHex, initiator.address.slice(2))
  console.log('\n✅  Initiator   :', initiator.address)
  console.log('✅  Encoded swap:', '0x' + encodedHex)
  console.log('✅  Swap ID     :', '0x' + swapId)
  const sig = signRelease(encodedHex, initiator, initiator.address.slice(2))


  meson.connect(david)
  console.log('\n🚀  Step 1.1 Post swap...')
  await provider.waitForTransaction((
    await meson.postSwap(
      '0x' + encodedHex, initiator.address, 0
    )
  ).transaction_hash)
  console.log('✅  Transaction done.')

  meson.connect(carol)
  console.log('\n🚀  Step 1.2 Bond swap...')
  await provider.waitForTransaction((
    await meson.bondSwap(
      '0x' + encodedHex, poolIndex
    )
  ).transaction_hash)
  console.log('✅  Transaction done.')

  const posted = await meson.getPostedSwap('0x' + encodedHex)
  console.log(`✅  Posted swap on 0x${encodedHex}: `)
  console.log(`      pool index  : ${posted[0]}`)
  console.log(`      initiator   : ${toBeHex(posted[1])}`)
  console.log(`      from address: ${toBeHex(posted[2])}`)

  
  meson.connect(carol)
  console.log('\n🚀  Step 2. Lock swap...')
  await provider.waitForTransaction((
    await meson.lockSwap(
      '0x' + encodedHex, initiator.address, david.address
    )
  ).transaction_hash)
  console.log('✅  Transaction done.')

  const locked = await meson.getLockedSwap('0x' + swapId)
  console.log(`✅  Locked swap on 0x${encodedHex} + ${toBeHex(initiator.address)}: `)
  console.log(`      pool index  : ${locked[0]}`)
  console.log(`      until       : ${locked[1]}`)
  console.log(`      recipient   : ${toBeHex(locked[2])}`)


  meson.connect(admin)
  console.log('\n🚀  Step 3. Release...')
  await provider.waitForTransaction((
    await meson.release(
      '0x' + encodedHex, sig.r, sig.yParityAndS, initiator.address
    )
  ).transaction_hash)
  console.log('✅  Transaction done.')

  const lockedAfter = await meson.getLockedSwap('0x' + swapId)
  console.log(`✅  Locked swap on 0x${encodedHex} + ${toBeHex(initiator.address)}: `)
  console.log(`      pool index  : ${lockedAfter[0]}`)
  console.log(`      until       : ${lockedAfter[1]}`)
  console.log(`      recipient   : ${toBeHex(lockedAfter[2])}`)


  meson.connect(david)
  console.log('\n🚀  Step 4. Execute swap...')
  await provider.waitForTransaction((
    await meson.executeSwap(
      '0x' + encodedHex, sig.r, sig.yParityAndS, initiator.address, true
    )
  ).transaction_hash)
  console.log('✅  Transaction done.')

  const postedAfter = await meson.getPostedSwap('0x' + encodedHex)
  console.log(`✅  Posted swap on 0x${encodedHex}: `)
  console.log(`      pool index  : ${postedAfter[0]}`)
  console.log(`      initiator   : ${toBeHex(postedAfter[1])}`)
  console.log(`      from address: ${toBeHex(postedAfter[2])}`)


  console.log()
}

main()