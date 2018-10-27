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

    event LogTokenContractChanged
    (
        address byWhom,
        address oldContract,
        address newContract
    );

    event LogBondingContractChanged
    (
        address byWhom,
        address oldContract,
        address newContract
    );

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

    /**
    * @dev Set both the 'logicContract' and 'bondingContract' to different contract addresses in 1 tx
    */
    function setTokenAndBondingContract(address _tokenContract, address _bondingContract) public onlyOwner {
        setTokenContract(_tokenContract);
        setBondingContract(_bondingContract);
    }

    /**
    * @dev Set the 'logicContract' to a different contract address
    */
    function setTokenContract(address _tokenContract) public onlyOwner {
        address oldContract = tokenContract;
        tokenContract = _tokenContract;
        emit LogTokenContractChanged(msg.sender, oldContract, _tokenContract);
    }

    /**
    * @dev Set the 'bondingContract' to a different contract address
    */
    function setBondingContract(address _bondingContract) public onlyOwner {
        address oldContract = bondingContract;
        bondingContract = _bondingContract;
        emit LogBondingContractChanged(msg.sender, oldContract, _bondingContract);
    }

    //allow freezing of everything

}