var Logic = artifacts.require("./Logic.sol");
var Token = artifacts.require("./Token.sol");
var BondingCurve = artifacts.require("./BondingCurve.sol");

const truffleAssert = require('truffle-assertions');

contract('Logic', function (accounts) {
    const owner = accounts[0];
    const alice = accounts[1];
    const bob = accounts[2];

    let logic;
    let token;
    let bondingCurve;

    let logicAddress;
    let tokenAddress;
    let bondingContract;


    beforeEach('setup contract for each test', async () => {
        console.log("Running new test")

        logic = await Logic.deployed();
        token = await Token.deployed();
        bondingCurve = await BondingCurve.deployed();

        // Get addresses
        logicAddress = logic.address;
        tokenAddress = await logic.tokenContract();
        bondingContract = await logic.bondingContract();

    });

    it("should setup charity address correctly", async () => {
        let redCross = '0x726788048e8b1f3d00ea91f5543c7beb50bb1c14'
        let tx = await logic.setCharityAddress(redCross)
        
        // truffleAssert.eventEmitted(tx, 'LogCharityAddressChanged', (ev) => {
        //     return ev.byWhom === owner && ev.oldAddress === 0x0 && ev.newAddress === bob;
        // });

        let charityAddress = await logic.charityAddress()
        assert.equal(charityAddress, web3.utils.toChecksumAddress(redCross), "charity address was not set correctly")
    })

    it("should receive correct amount of tokens", async () => {
        // let tx = await web3.eth.sendTransaction({to: logicAddress, from: alice, value: web3.utils.toWei('1', 'ether')})
        let tx = await logic.donate({from: owner, value: web3.utils.toWei('1', 'ether')})

        // truffleAssert.eventEmitted(tx, 'LogDonationReceived', (ev) => {
        //     return ev.byWhom === alice && ev.amount === web3.utils.toWei('1', 'ether');
        // });

        let balanceOfBondingCurve = await web3.eth.getBalance(bondingContract)
        assert.equal(balanceOfBondingCurve, web3.utils.toWei('0.1', 'ether'), "Incorrect bonding curve balance")

        let charityAddress = await logic.charityAddress()
        let balanceOfCharityAddress = await web3.eth.getBalance(charityAddress)
        assert.equal(balanceOfCharityAddress, web3.utils.toWei('0.9', 'ether'), "Incorrect charityAddress balance")

        let tokenBalanceOfDonater = await token.balanceOf(owner)
        assert.equal(tokenBalanceOfDonater, web3.utils.toWei('10', 'ether'), "Incorrect amount of tokens minted")
    });
})