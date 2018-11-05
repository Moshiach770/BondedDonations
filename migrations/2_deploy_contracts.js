var DonationLogic = artifacts.require("DonationLogic");
var Token = artifacts.require("Token");
var BondingCurveVault = artifacts.require("BondingCurveVault");

module.exports = async function (deployer, network, accounts) {

  console.log('  === Deploying BondedDonation contracts...')

  // Deploy DonationLogic contract
  let redCross = '0x726788048e8b1f3d00ea91f5543c7beb50bb1c14';
  await deployer.deploy(DonationLogic, redCross)
  let logicInstance = await DonationLogic.deployed()

  // Deploy TokenContract
  await deployer.deploy(Token, DonationLogic.address)
  let tokenInstance = await Token.deployed()

  // Deploy Vault
  await deployer.deploy(BondingCurveVault, DonationLogic.address)
  let bondingVaultInstance = await BondingCurveVault.deployed()

  await logicInstance.setTokenAndBondingVault(Token.address, BondingCurveVault.address)

  console.log('  === Double check values are correct...')
  let tokenAddress = await logicInstance.tokenContract();
  let bondingVault = await logicInstance.bondingVault();

  console.log('tokenAddress set: ' + tokenAddress)
  console.log('bondingVault set: ' + bondingVault)

  // console.log('  === Fund bonding contract...')

  // await web3.eth.sendTransaction({to: bondingVault, from: accounts[1], value: web3.utils.toWei('5', 'ether')})


  // console.log('  === Double check values are correct...')
  // let tokenAddress = await logicInstance.tokenContract();
  // let bondingVault = await logicInstance.bondingVault();

  // console.log('tokenAddress set: ' + tokenAddress)
  // console.log('bondingVault set: ' + bondingVault)

  // let bondingBalance = await web3.eth.getBalance(bondingVault)
  // console.log('bondingCurve balance: ' + bondingBalance)
};