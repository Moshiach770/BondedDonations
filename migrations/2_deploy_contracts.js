var DonationLogic = artifacts.require("DonationLogic");
var Token = artifacts.require("Token");
var BondingCurveVault = artifacts.require("BondingCurveVault");
var FractionalExponents = artifacts.require("FractionalExponents");

module.exports = async function (deployer, network, accounts) {

  console.log('  === Deploying BondedDonation contracts...')

  // Deploy DonationLogic contract
  let charityAddress;
  if (network == 'develop' || network == 'development' || network == 'test') {
      charityAddress = '0x726788048e8b1f3d00ea91f5543c7beb50bb1c14';
  } else {
    //TODO
  }
  await deployer.deploy(DonationLogic, charityAddress)
  let logicInstance = await DonationLogic.deployed()

  // Deploy TokenContract
  await deployer.deploy(Token, DonationLogic.address)
  let tokenInstance = await Token.deployed()

  // Deploy Vault
  await deployer.deploy(BondingCurveVault, DonationLogic.address)
  let bondingVaultInstance = await BondingCurveVault.deployed()

  // Deploy FractionalExponents contract
  await deployer.deploy(FractionalExponents)

  // Set compulsary values in logic contract
  await logicInstance.setTokenAndBondingVault(Token.address, BondingCurveVault.address)
  await logicInstance.setExponentContract(FractionalExponents.address)

  console.log('  === Double check values are correct...')
  let tokenAddress = await logicInstance.tokenContract();
  let bondingVault = await logicInstance.bondingVault();
  let exponentAddress = await logicInstance.exponentContract();

  console.log('tokenAddress set: ' + tokenAddress)
  console.log('bondingVault set: ' + bondingVault)
  console.log('exponentAddress set: ' + exponentAddress)

  console.log('  === Fund bonding contract...')

  await web3.eth.sendTransaction({to: bondingVault, from: accounts[1], value: web3.utils.toWei('5', 'ether')})

  let bondingBalance = await web3.eth.getBalance(bondingVault)
  console.log('bondingCurve balance: ' + bondingBalance)
};