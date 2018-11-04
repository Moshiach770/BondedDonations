var Logic = artifacts.require("Logic");
var Token = artifacts.require("Token");
var BondingCurveVault = artifacts.require("BondingCurveVault");

module.exports = async function (deployer, network, accounts) {

  console.log('  === Deploying BondedDonation contracts...')

  // Deploy LogicContract
  await deployer.deploy(Logic)
  let logicInstance = await Logic.deployed()

  // Deploy TokenContract
  await deployer.deploy(Token, Logic.address)
  let tokenInstance = await Token.deployed()

  await deployer.deploy(BondingCurveVault, Logic.address)
  let bondingVaultInstance = await BondingCurveVault.deployed()

  await logicInstance.setTokenAndBondingContract(Token.address, BondingCurveVault.address)

  console.log('  === Double check values are correct...')
  let tokenAddress = await logicInstance.tokenContract();
  let bondingContract = await logicInstance.bondingContract();

  console.log('tokenAddress set: ' + tokenAddress)
  console.log('bondingContract set: ' + bondingContract)

  // console.log('  === Fund bonding contract...')

  // await web3.eth.sendTransaction({to: bondingContract, from: accounts[1], value: web3.utils.toWei('5', 'ether')})


  // console.log('  === Double check values are correct...')
  // let tokenAddress = await logicInstance.tokenContract();
  // let bondingContract = await logicInstance.bondingContract();

  // console.log('tokenAddress set: ' + tokenAddress)
  // console.log('bondingContract set: ' + bondingContract)

  // let bondingBalance = await web3.eth.getBalance(bondingContract)
  // console.log('bondingCurve balance: ' + bondingBalance)
};