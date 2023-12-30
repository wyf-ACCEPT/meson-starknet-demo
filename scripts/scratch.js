const { Account, Provider } = require('starknet')
require('dotenv').config()

main = async function () {
  // initialize provider
  const provider = new Provider({ sequencer: { baseUrl: "http://0.0.0.0:5050" } });
  // initialize existing pre-deployed account 0 of Devnet
  const privateKey = process.env.PRIVATE_KEY_ADMIN
  const accountAddress = "0x7e00d496e324876bbc8531f2d9a82bf154d1a04a50218ee74cdd372f75a551a";
  const account = new Account(provider, accountAddress, privateKey);

  // Declare & deploy Test contract in devnet
  const compiledTestSierra = json.parse(fs.readFileSync( "./target/test.sierra").toString( "ascii"));
  const compiledTestCasm = json.parse(fs.readFileSync( "./compiledContracts/test.casm").toString( "ascii"));
  const deployResponse = await account.declareAndDeploy({ contract: compiledTestSierra, casm: compiledTestCasm });

  // // Connect the new contract instance:
  // const myTestContract = new Contract(compiledTest.abi, deployResponse.deploy.contract_address, provider);
  // console.log("Test Contract Class Hash =", deployResponse.declare.class_hash);
  // console.log('✅ Test Contract connected at =', myTestContract.address);



  console.log(account)
}

main()