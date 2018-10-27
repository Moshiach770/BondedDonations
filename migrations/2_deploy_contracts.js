var SimpleStorage = artifacts.require("SimpleStorage");
var TutorialToken = artifacts.require("TutorialToken");
var ComplexStorage = artifacts.require("ComplexStorage");

var Logic = artifacts.require("Logic");
var Token = artifacts.require("Token");
var BondingCurve = artifacts.require("BondingCurve");


module.exports = async function (deployer, accounts) {

  // temp
  // deployer.deploy(SimpleStorage);
  // deployer.deploy(TutorialToken);
  // deployer.deploy(ComplexStorage);

  console.log('  === Deploying BondedDonation contracts...')

  // Deploy LogicContract
  await deployer.deploy(Logic)
  let logicInstance = await Logic.deployed()

  // Deploy TokenContract
  await deployer.deploy(Token, Logic.address)
  let tokenInstance = await Token.deployed()

  await deployer.deploy(BondingCurve, Logic.address, Token.address)
  let bondingInstance = await BondingCurve.deployed()

  await logicInstance.setTokenAndBondingContract(Token.address, BondingCurve.address)

  console.log('  === Double check values are correct...')
  let tokenAddress = await logicInstance.tokenContract();
  let bondingContract = await logicInstance.bondingContract();

  console.log('tokenAddress set: ' + tokenAddress)
  console.log('bondingContract set: ' + bondingContract)
};