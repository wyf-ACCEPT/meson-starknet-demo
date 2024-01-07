// const { Account, Contract, RpcProvider } = require('starknet')
// const { parseUnits, formatUnits, toBeHex } = require('ethers')
// const { readFileSync } = require('fs')
// require('dotenv').config()

// main = async function () {
//   const provider = new RpcProvider({ 
//     nodeUrl: "https://starknet-goerli.g.alchemy.com/v2/JDkRaXE932elAFfLGl3IzE7jP0aekgAM" 
//   })
  
//   const erc20Sierra = JSON.parse(
//     readFileSync('./target/dev/meson_starknet_MockToken.contract_class.json')
//   )
//   const gEthAddress = '0x049d36570d4e46f48e99674bd3fcc84644ddd6b96f7c741b1562b82f9e004dc7'
//   const gEth = new Contract(erc20Sierra.abi, gEthAddress, provider)

//   console.log(
//     '    Admin = ',
//     formatUnits((await gEth.balanceOf(
//       '0x026fa92011b2f27eca57a44411837e38a4313dfb11d561146039b445815db35b'
//     )).toString(), 18)
//   )
// }

// main()