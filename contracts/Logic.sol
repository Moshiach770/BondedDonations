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

    event LogCharityAddressChanged
    (
        address byWhom,
        address oldAddress,
        address newAddress
    );

    event LogDonationReceived
    (
        address byWhom,
        address amount
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

    /**
    * @dev The fallback function - should call 'donate' function in Logic contract
    */
    function () public payable {
        donate();
    }

    /**
    * @dev donation function splits ETH, 90% to charityAddress, 10% to fund bonding curve
    */
    function donate() public payable returns (bool) {
        require(charityAddress != address(0), "Charity address is not set correctly");
        require(msg.value > 0, "Must include some ETH to donate");

        // Make ETH distributions
        uint256 charityAllocation = (msg.value).mul(0.9);
        uint256 bondingAllocation = (msg.value).sub(charityAllocation);
        sendToCharity(charityAllocation);
        bondingContract.transfer(bondingAllocation);

        // Mint the tokens - 10:1 ratio (e.g. for every 1 ETH sent, you get 10 tokens)
        Token(tokenContract).mintToken(msg.sender, (msg.value).mul(10));

        emit LogDonationReceived(msg.sender, msg.value);
    }
    
    // TODO: - DAI integration: buy DAI with ETH, store in charityAddress
    function sendToCharity(uint256 _amount) internal {
        // this should auto convert to DAI
        charityAddress.transfer(charityAllocation);
    }

    /**
    * @dev sell function for selling tokens to bonding curve
    */
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

    /**
    * @dev calculate how much ETH should be returned for a certain amount of tokens
    */
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

    /**
    * @dev Set the 'charityAddress' to a different contract address
    */
    function setCharityAddress(address _charityAddress) public onlyOwner {
        address oldAddress = charityAddress;
        charityAddress = _charityAddress;
        emit LogCharityAddressChanged(msg.sender, oldAddress, _charityAddress);
    }


    //allow freezing of everything

}