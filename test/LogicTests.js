var DonationLogic = artifacts.require("./DonationLogic.sol");
var Token = artifacts.require("./Token.sol");
var BondingCurveVault = artifacts.require("./BondingCurveVault.sol");

// const truffleAssert = require('truffle-assertions');

contract('Logic', function (accounts) {
    const owner = accounts[0];
    const alice = accounts[1];
    const bob = accounts[2];

    let logic;
    let token;
    let bondingCurveVault;
    let logicAddress;
    let tokenAddress;
    let bondingVault;

    beforeEach('setup contract for each test', async () => {
        console.log("Running new test")

        logic = await DonationLogic.deployed();
        token = await Token.deployed();
        bondingCurveVault = await BondingCurveVault.deployed();

        // Get addresses
        logicAddress = logic.address;
        tokenAddress = await logic.tokenContract();
        bondingVault = await logic.bondingVault();

        console.log("tokenAddress " + tokenAddress);
        console.log("bondingVault " + bondingVault);

    });

    it("should allow sweeping by the owner", async () => {
        //award
        await logic.award(bob, web3.utils.toWei('1', 'ether'), "ipfsHash_placeholder");

        //attempt to sweep
        try {
            await logic.sweepVault();
            assert.ok(false, 'contract must have thrown an error');
        } catch (error) {
            assert.ok(true, 'no early sweep');
        }
        //sell
        await logic.sell(web3.utils.toWei('1', 'ether'), {from : bob});
        assert.equal(await token.balanceOf(bob), 0, "Hey, Bob sold it all!")

        //check vault, some remaining
        assert.isTrue(Number(await web3.eth.getBalance(bondingVault)) > 0);

        //attempt to sweep by bad guy
        try {
            await logic.sweepVault({from: alice});
            assert.ok(false, 'contract must have thrown an error');
        } catch (error) {
            assert.ok(true, 'alice cant sweep, no no');
        }

        //sweep
        await logic.sweepVault();
        assert.equal(Number(await web3.eth.getBalance(bondingVault)), 0, "Vault must be empty after sweep")

        //attempt to sweep again
        try {
            await logic.sweepVault();
            assert.ok(false, 'contract must have thrown an error');
        } catch (error) {
            assert.ok(true, 'no doulbe sweeping in Ethereum!');
        }
    })

});