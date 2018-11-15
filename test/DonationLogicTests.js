var DonationLogic = artifacts.require("./DonationLogic.sol");
var Token = artifacts.require("./Token.sol");
var BondingCurveVault = artifacts.require("./BondingCurveVault.sol");

// const truffleAssert = require('truffle-assertions');

contract('DonationLogic', function (accounts) {
    const owner = accounts[0];
    const alice = accounts[1];
    const bob = accounts[2];

    let logic;
    let token;
    let bondingCurveVault;
    let logicAddress;
    let tokenAddress;
    let bondingVault;
    let charityAddress;

    beforeEach('setup contract for each test', async () => {
        console.log("Running new test")

        logic = await DonationLogic.deployed();
        token = await Token.deployed();
        bondingCurveVault = await BondingCurveVault.deployed();

        // Get addresses
        logicAddress = logic.address;
        tokenAddress = await logic.tokenContract();
        bondingVault = await logic.bondingVault();

        charityAddress = await logic.charityAddress()

        console.log("tokenAddress " + tokenAddress);
        console.log("bondingVault " + bondingVault);

    });

    it("should setup charity address correctly", async () => {
        
        // truffleAssert.eventEmitted(tx, 'LogCharityAddressChanged', (ev) => {
        //     return ev.byWhom === owner && ev.oldAddress === 0x0 && ev.newAddress === bob;
        // });

        assert.isTrue(web3.utils.checkAddressChecksum(charityAddress), "charity address was not set correctly")
    })

    it("should allow donating and receive correct amount of tokens", async () => {
        let balanceOfCharityBefore = await web3.eth.getBalance(charityAddress);
        //let tx = await web3.eth.sendTransaction({to: logicAddress, from: owner, value: web3.utils.toWei('1', 'ether')})
        let tx = await logic.donate({from: bob, value: web3.utils.toWei('1', 'ether')})
            // .on('LogDonationReceived', function(byWhom, amount) {
            //     assert.equal(bob, byWhom, "Incorrect donator emitted")
            //     assert.equal(web3.utils.toWei('1', 'ether'), amount, "Incorrect donated amount emitted")
            // })
            // .on('LogEthReceived', function(amount, account) {
            //     assert.equal(web3.utils.toWei('0.1', 'ether'), amount, "Incorrect bonding curve amount received")
            //     assert.equal(bob, account, "Incorrect donator account")
            // })
            // .on('LogCharityAllocationSent', function(amount, account) {
            //     assert.equal(web3.utils.toWei('0.9', 'ether'), amount, "Incorrect charity amount received")
            //     assert.equal(bob, account, "Incorrect donator account")
            // })
            // .on('LogMint', function(account, amount) {
            //     assert.equal(web3.utils.toWei('10', 'ether'), amount, "Incorrect amount of tokens minted")
            //     assert.equal(bob, account, "Incorrect donator account")
            //     console.log('LogMint')
            // })

        // truffleAssert.eventEmitted(tx, 'LogDonationReceived', (ev) => {
        //     return ev.byWhom === bob && ev.amount === web3.utils.toWei('1', 'ether');
        // });

        let balanceOfBondingCurve = await web3.eth.getBalance(bondingVault)
        assert.equal(balanceOfBondingCurve, web3.utils.toWei('0.1', 'ether'), "Incorrect bonding curve balance")

        let balanceOfCharityAfter = await web3.eth.getBalance(charityAddress)
        assert.equal(balanceOfCharityAfter, Number(balanceOfCharityBefore) + Number(web3.utils.toWei('0.9', 'ether')), "Incorrect charityAddress balance")

        let tokenBalanceOfDonater = await token.balanceOf(bob)
        assert.equal(tokenBalanceOfDonater, web3.utils.toWei('10', 'ether'), "Incorrect amount of tokens minted")
    });

    it("should allow selling and receive correct amount of ETH", async () => {
        let tokenBalanceOfDonater = await token.balanceOf(bob)
        let balanceOfBondingCurve = await web3.eth.getBalance(bondingVault)

        // Calculate return
        let supply = await token.getSupply()
        let redeemableEth = web3.utils.toBN((tokenBalanceOfDonater / supply) * balanceOfBondingCurve)

        let tx = await logic.sell(tokenBalanceOfDonater, {from: bob})
            // .on('LogBurn', function(byWhom, amount) {
            //     assert.equal(bob, byWhom, "Unexpected burn from address")
            //     assert.equal(tokenBalanceOfDonater, amount, "Unexpected amount burned")
            // })
            // .on('LogEthSent', function(amount, account) {
            //     assert.equal(bob, account, "ETH sent to incorrect user")
            //     assert.equal(redeemableEth, amount, "ETH sent to user is incorrect")
            //     console.log('LogEthSent')
            // })
            // .on('receipt', function(receipt) {
            //     console.log("Gas used in sell fn: " + receipt.gasUsed)
            // })
       
        let newTokenBalanceOfDonator = await token.balanceOf(bob)
        let newBalanceOfBondingCurve = await web3.eth.getBalance(bondingVault)

        let expectedTokenBalanceOfDonator = 0
        let expectedBalanceOfBondingCurve = web3.utils.toBN(balanceOfBondingCurve).sub(redeemableEth).toString()

        assert.equal(newTokenBalanceOfDonator, expectedTokenBalanceOfDonator, "tokenBalance of donator is incorrect")
        assert.equal(newBalanceOfBondingCurve, expectedBalanceOfBondingCurve, "balance of bonding curve is incorrect")
    })

    it("should fail on default fallback", async () => {
        try {
            await web3.eth.sendTransaction({to: logicAddress, from: bob, value: web3.utils.toWei('1', 'wei')});
            assert.ok(false, 'contract must have thrown an error');
        } catch (error) {
            assert.ok(true, 'no fallback ');
        }
    })
})