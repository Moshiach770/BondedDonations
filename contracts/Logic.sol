pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "./BondingCurve.sol";
import "./Token.sol";

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

    // Minimum ETH balance for valid bonding curve
    uint256 public minEth;

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

    event LogMinEthChanged
    (
        address byWhom,
        address oldAmount,
        address newAmount
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

    modifier minimumBondingBalance() {
        require(bondingContract.balance >= minEth, "Not enough ETH in bonding contract");
        _;
    }

    // payable function calls donation function

    // donation function splits ETH, 90% to charityAddress, 10% to fund bonding curve
    
    // calculate how many tokens will be minted, return value

    // DAI integration: buy DAI with ETH, store in charityAddress

    function sell(uint256 _amount) public minimumBondingBalance returns (bool) {
        uint256 tokenBalanceOfSender = Token(tokenContract).balanceOf(msg.sender);
        require(_amount > 0 && tokenBalanceOfSender >= _amount, "Amount needs to be > 0 and tokenBalance >= amount to sell");

        // calculate sell return
        uint256 amountOfEth = calculateReturn(_amount, tokenBalanceOfSender);

        // burn tokens
        Token(tokenContract).burn(msg.sender, _amount);

        // sendEth to msg.sender from bonding curve
        BondingCurve(bondingContract).sendEth(amountOfEth, msg.sender);
    }

    function calculateReturn(uint256 _sellAmount, uint256 _tokenBalance) public view returns (uint256) {
        require(_tokenBalance >= _sellAmount, "User trying to sell more than they have");
        uint256 supply = Token(tokenContract).getSupply();

        // For EVM accuracy
        uint256 multiplier = 10**18;

        if (coolDownPeriod(msg.sender) <= 0) {
            // price = ((tokens i have or # I want to sell) / (total token supply)) * ETH in contract
            // using a multiplier due to EVM constraints
            uint256 redeemableEth = (_sellAmount.mul(multiplier).div(supply).mul(bondingContract.balance)).div(multiplier);
            return redeemableEth;
        } else {
            return 0;
        }
    }

    // !! TODO: - set cooldown time period before selling
    // returns uint256 in number of hours
    function coolDownPeriod(address _tokenHolder) public view returns (uint256) {
        // something like today - (day of buying + 7 days)
        // todo when minting tokens
        return 0;
    }

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

    /**
    * @dev Set the 'minEth' amount
    */
    function setMinEth(uint256 _minEth) public onlyOwner {
        uint256 oldAmount = minEth;
        minEth = _minEth;
        emit LogBondingContractChanged(msg.sender, oldAmount, _minEth);
    }


    //allow freezing of everything

}