import React, { Component } from "react";
import getWeb3 from "./utils/getWeb3";
import truffleContract from "truffle-contract";

import LogicContract from "./contracts/Logic.json";
import TokenContract from "./contracts/Token.json";
import BondingContract from "./contracts/BondingCurve.json"

import { Pane, Text, Heading, TextInputField, Button } from 'evergreen-ui'


import "./App.css";

class App extends Component {
  state = { 
    charityAddress: 0, 
    web3: null, 
    accounts: null,
    myEthBalance: 0, 
    isOwner: false,
    logicContract: null, 
    tokenContract: null,
    bondingContract: null,
    tokenInfo: {
      tokenBalance: 0,
      tokenSupply: 0,
      tokenSymbol: ''
    },
    bondingBalance: 0,
    charityBalance: 0
  };

  componentDidMount = async () => {
    try {
      // Get network provider and web3 instance.
      const web3 = await getWeb3();

      // Use web3 to get the user's accounts.
      const accounts = await web3.eth.getAccounts();

      let myEthBalance = await web3.eth.getBalance(accounts[0])

      // Get the logicContract instance.
      const logicContract = truffleContract(LogicContract);
      logicContract.setProvider(web3.currentProvider);
      const logicInstance = await logicContract.deployed();

      let charityAddress = await logicInstance.charityAddress()
      let charityBalance = charityAddress != 0x0000000000000000000000000000000000000000 ? await web3.eth.getBalance(charityAddress) : '0'

      let isOwner = (await logicInstance.owner()) == accounts[0]

      // Get tokenContract instance
      const tokenContract = truffleContract(TokenContract)
      tokenContract.setProvider(web3.currentProvider)
      const tokenInstance = await tokenContract.deployed()

      let tokenSymbol =  await tokenInstance.symbol()
      let tokenBalance = (await tokenInstance.balanceOf(accounts[0])).toString()
      let tokenSupply = (await tokenInstance.totalSupply()).toString()

      // Get bondingCurve instance
      const bondingContract = truffleContract(BondingContract)
      bondingContract.setProvider(web3.currentProvider)
      const bondingInstance = await bondingContract.deployed()

      let bondingBalance = await web3.eth.getBalance(bondingInstance.address)

      this.setState({ 
        web3, 
        accounts, 
        myEthBalance,
        isOwner,
        logicContract: logicInstance, 
        tokenContract: tokenInstance, 
        bondingContract: bondingInstance, 
        charityAddress, 
        tokenInfo: {
          tokenBalance,
          tokenSupply,
          tokenSymbol
        },
        bondingBalance, 
        charityBalance
      });
    } catch (error) {
      // Catch any errors for any of the above operations.
      alert(
        `Failed to load web3, accounts, or contract. Check console for details.`
      );
      console.log(error);
    }
  };

  setCharityAddress = async (event) => {
    event.preventDefault()
    let { accounts, logicContract } = this.state


    await logicContract.setCharityAddress(event.target.address.value, { from: accounts[0], gas: 100000, gasPrice: this.state.web3.utils.toWei('5', 'gwei') })

    let response = await logicContract.charityAddress()
    this.setState({ charityAddress: response })
  };

  donate = async (event) => {
    event.preventDefault()
    let { accounts, logicContract } = this.state
    let web3 = this.state.web3

    let amount = web3.utils.toWei(event.target.amount.value, 'ether')

    await logicContract.donate({ value: amount, from: accounts[0], gas: 200000, gasPrice: web3.utils.toWei('5', 'gwei') })
    this.updateBalances()
  }

  sell = async (event) => {
    event.preventDefault()
    let { accounts, logicContract } = this.state

    let sellAmount = this.state.web3.utils.toWei(event.target.amount.value, 'ether')
    let calculatedReturn = await logicContract.calculateReturn(sellAmount, this.state.tokenInfo.tokenSupply)
    let alert = window.confirm("You will receive " + this.state.web3.utils.fromWei(calculatedReturn, 'ether') + ' ETH in return for ' + this.state.web3.utils.fromWei(sellAmount, 'ether') + ' ' + this.state.tokenInfo.tokenSymbol + '. Are you sure?')

    if (alert === true) {
      await logicContract.sell(sellAmount, { from: accounts[0], gas: 100000, gasPrice: this.state.web3.utils.toWei('5', 'gwei') })
    } else {
      console.log('sell cancelled')
    }

    this.updateBalances()
  }

  updateBalances = async (event) => {
    let { web3, accounts, tokenContract, bondingContract, charityAddress } = this.state
    let tokenBalance = (await tokenContract.balanceOf(accounts[0])).toString()
    let tokenSupply = (await tokenContract.totalSupply()).toString()
    let tokenSymbol = await tokenContract.symbol()

    let bondingBalance = (await web3.eth.getBalance(bondingContract.address)).toString()
    let charityBalance = (await web3.eth.getBalance(charityAddress)).toString()
    let myEthBalance = (await web3.eth.getBalance(this.state.accounts[0])).toString()

    this.setState({ myEthBalance, tokenInfo: { tokenBalance, tokenSupply, tokenSymbol}, bondingBalance, charityBalance})
  }

  render() {

    if (!this.state.web3 || !this.state.tokenContract || !this.state.bondingContract || !this.state.logicContract) {
      return <div>Loading Web3, accounts, and contracts...</div>;
    }

    let web3 = this.state.web3
    let tokenBalance = web3.utils.fromWei(this.state.tokenInfo.tokenBalance, 'ether')
    let tokenSupply = web3.utils.fromWei(this.state.tokenInfo.tokenSupply, 'ether')
    let bondingBalance = web3.utils.fromWei(this.state.bondingBalance, 'ether')
    let charityBalance = web3.utils.fromWei(this.state.charityBalance, 'ether')
    let myEthBalance = web3.utils.fromWei(this.state.myEthBalance, 'ether')

    let tokenSymbol = this.state.tokenInfo.tokenSymbol

    let sellLabel = "Amount of " + tokenSymbol + " to sell"

    return (
      <Pane padding={16}>
        <Heading size={800}>Bonded Donations ⛓🎗</Heading>
        <Pane padding={16} background="tint1" borderRadius={5} border="default" marginTop={16} marginBottom={16}>
          <Pane marginBottom={16}>
            <Heading>Charity Info</Heading>
            <Text>
              Charity address: {this.state.charityAddress} <br />
              Charity balance: {charityBalance} ETH
            </Text>
          </Pane>
            
          <Pane marginBottom={16}>
            <Heading>Bonding Curve Info</Heading>
            <Text>Bonded Curve Balance: {bondingBalance} ETH</Text>
          </Pane>

          <Pane marginBottom={16}>
            <Heading>Token Info</Heading>
            <Text>Total supply: {tokenSupply} {tokenSymbol}</Text>
          </Pane>

          <Pane marginBottom={8}>
            <Heading>My Info</Heading>
            <Text>
              Token Balance: {tokenBalance} {tokenSymbol}<br />
              ETH Balance: {myEthBalance} ETH
            </Text>
          </Pane>
        </Pane>

        <Pane padding={16} background="greenTint" borderRadius={5} border="default" marginBottom={16}>
          <Heading>Donate</Heading>
          <Pane marginTop={16} marginBottom={16}>
            <form onSubmit={this.donate} id="donate">
              <TextInputField
                label="Amount to donate (ETH)"
                placeholder="1"
                htmlFor="donate"
                type="number"
                name="amount"
              />
              <Button type="submit" id="donateButton" marginTop={-16}>Donate</Button>
            </form>
          </Pane>

          <p></p>

          <Heading>Sell</Heading>
          <Pane marginTop={16} marginBottom={16}>
            <form onSubmit={this.sell} id="sell">
              <TextInputField
                label={sellLabel}
                placeholder="10"
                htmlFor="sell"
                type="number"
                name="amount"
              />
              <Button type="submit" id="sellButton" marginTop={-16}>Sell</Button>
            </form>
          </Pane>
        </Pane>

        {this.state.isOwner &&
          <Pane padding={16} background="tint1" borderRadius={5} marginBottom={16}>
            <Heading>Admin</Heading>
            <Pane marginTop={16} marginBottom={16}>
              <form onSubmit={this.setCharityAddress} id="setCharityAddress">
                <TextInputField
                  label="Change charity's address"
                  placeholder="0x...."
                  htmlFor="setCharityAddress"
                  type="text"
                  name="address"
                />
                <Button type="submit" id="setButton" marginTop={-16}>Change</Button>
              </form>
            </Pane>
          </Pane>
        }
        
      </Pane>
    );
  }
}

export default App;
