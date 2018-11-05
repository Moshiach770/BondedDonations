pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";

contract Logic is Ownable {
    using SafeMath for uint256;

    // Keep the balances of ERC20s
    TokenInterface public tokenContract;

    // Bonding curve ETH
    VaultInterface public bondingVault;

    // Minimum ETH balance for valid bonding curve
    uint256 public minEth;

    event LogTokenContractChanged
    (
        address byWhom,
        address oldContract,
        address newContract
    );

    event LogBondingVaultChanged
    (
        address byWhom,
        address oldContract,
        address newContract
    );

    event LogMinEthChanged
    (
        address byWhom,
        uint256 oldAmount,
        uint256 newAmount
    );

    modifier minimumBondingBalance() {
        require(bondingVault.balance >= minEth, "Not enough ETH in bonding vault contract");
        _;
    }

    /**
     * @dev The fallback function, which is used to 'fund' the Vault
     * TODO: To take from Khana Framework
     */
    function () public payable {
        address(bondingVault).transfer(msg.value);
    }

    /**
    * @dev this is a 'general' award method for the Bonding Curve, to be taken from Khana Framework.
    * TODO: This method is supposed to be called by authorized accounts only (i.e. 'admins')
    * which might be not a case for custmomizations, like 'Donations' where an 'external' action (donation) must be awarded.
    * For such cases the sub-contract must be added to the authorized accounts list
    */
    function award(
        address _account,
        uint256 _amount,
        string _ipfsHash
    )
    public
    {
        tokenContract.mintToken(_account, _amount);
    }

    /**
    * @dev sell function for selling tokens to bonding curve
    */
    function sell(uint256 _amount) public minimumBondingBalance returns (bool) {
        uint256 tokenBalanceOfSender = tokenContract.balanceOf(msg.sender);
        require(_amount > 0 && tokenBalanceOfSender >= _amount, "Amount needs to be > 0 and tokenBalance >= amount to sell");

        // calculate sell return
        uint256 amountOfEth = calculateReturn(_amount, tokenBalanceOfSender);

        // burn tokens
        tokenContract.burn(msg.sender, _amount);

        // sendEth to msg.sender from bonding curve
        bondingVault.sendEth(amountOfEth, msg.sender);
    }

    /**
    * @dev calculate how much ETH should be returned for a certain amount of tokens
    */
    function calculateReturn(uint256 _sellAmount, uint256 _tokenBalance) public view returns (uint256) {
        require(_tokenBalance >= _sellAmount, "User trying to sell more than they have");
        uint256 supply = tokenContract.getSupply();

        // For EVM accuracy
        uint256 multiplier = 10**18;

        if (coolDownPeriod(msg.sender) <= 0) {
            // Price = (Portion of Supply ^ ((1/4) - Portion of Supply)) * (ETH in Pot / Token supply)
            // NOT YET WORKING (problem with decimal precision for exponent)
            uint256 portionOfSupply = (_tokenBalance.mul(multiplier).div(supply));
            uint256 exponent = ((multiplier.div(multiplier).div(4*multiplier)).sub(portionOfSupply)).div(multiplier);
            uint256 price = ((portionOfSupply**exponent).mul((address(bondingVault).balance).div(supply))).div(multiplier);
            
            uint256 redeemableEth = price.mul(_sellAmount);
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

    /**
    * @dev Set both the 'logicContract' and 'bondingVault' to different contract addresses in 1 tx
    */
    function setTokenAndBondingVault(address _tokenContract, address _bondingVaultContract) public onlyOwner {
        setTokenContract(_tokenContract);
        setBondingVault(_bondingVaultContract);
    }

    /**
    * @dev Set the 'logicContract' to a different contract address
    */
    function setTokenContract(address _tokenContract) public onlyOwner {
        address oldContract = tokenContract;
        tokenContract = TokenInterface(_tokenContract);
        emit LogTokenContractChanged(msg.sender, oldContract, _tokenContract);
    }

    /**
    * @dev Set the 'bondingVault' to a different contract address
    */
    function setBondingVault(address _bondingVault) public onlyOwner {
        address oldContract = bondingVault;
        bondingVault = VaultInterface(_bondingVault);
        emit LogBondingVaultChanged(msg.sender, oldContract, _bondingVault);
    }

    /**
    * @dev Set the 'minEth' amount
    */
    function setMinEth(uint256 _minEth) public onlyOwner {
        uint256 oldAmount = minEth;
        minEth = _minEth;
        emit LogMinEthChanged(msg.sender, oldAmount, _minEth);
    }

    //allow freezing of everything

}

/**
 * @title Abstraction, used to interact with the Bonding Curve Vault
 */
interface VaultInterface {

    function sendEth(uint256 _amount, address _account) external;

}

/**
 * @title Abstraction, used to interact with the Bonding Curve Token
 */
interface TokenInterface {

    function mintToken(address _who, uint256 _amount) external returns (bool);

    function balanceOf(address owner) external view returns (uint256);

    function burn(address _who, uint256 _value) external;

    function getSupply() external view returns (uint256);

}