pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "./BondingCurve.sol";

contract Logic is Ownable {
    using SafeMath for uint256;

    // Keep the balances of ERC20s
    address public tokenContract;

    // Bonding curve ETH
    address public bondingContract;

    // Charity address
    address public charityAddress;

    // KYC flag
    bool public kycEnabled;

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    modifier kycCheck() {
        if (kycEnabled) {
            // require whitelisted address (see Bloom docs?)
        }
        _;
    }

    // payable function calls donation function

    // donation function splits ETH, 90% to charityAddress, 10% to fund bonding curve
    
    // calculate how many tokens will be minted, return value

    // DAI integration: buy DAI with ETH, store in charityAddress

    // sell function - token balances need date of minting. If date > 1 month, then allow selling
    // calls burn function in token.sol
    // calls sendETH function in bondingCurve.sol

    // KYC logic - stretch goals
    // add donator to whitelist
    // see Bloom docs

    // only owner
    //allow changing of tokenContract
    //allow changing of bondingContract
    //allow freezing of everything

}