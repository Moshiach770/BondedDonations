pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";

import "./VaultInterface.sol";
import "./TokenInterface.sol";
import "./FractionalExponents.sol";

contract Logic is Ownable {
    using SafeMath for uint256;

    // Keep the balances of ERC20s
    address public tokenContract;

    // Bonding curve ETH
    address public bondingVault;

    // Contract that handles fractional exponents
    address public exponentContract;

    // Minimum ETH balance for valid bonding curve
    uint256 public minEth;

    event LogTokenSell
    (
        address byWhom,
        uint256 price,
        uint256 amountOfEth
    );

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

    event LogExponentContractChanged
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
     * @dev No fallback is allowed, use sponsor() to fund the Bonding Curve
     */
    function () public payable {
        revert();
    }

    /**
     * @dev Sponsoring the Bonding Curve with ETH. Note: this will not mint the tokens in return
     * TODO: To take from Khana Framework
     */
    function sponsor() public payable {
        require(bondingVault != address(0), "Vault is missing");
        bondingVault.transfer(msg.value);
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
        TokenInterface(tokenContract).mintToken(_account, _amount);
    }

    /**
    * @dev sell function for selling tokens to bonding curve
    */
    function sell(uint256 _amount) public minimumBondingBalance returns (bool) {
        uint256 tokenBalanceOfSender = TokenInterface(tokenContract).balanceOf(msg.sender);
        require(_amount > 0 && tokenBalanceOfSender >= _amount, "Amount needs to be > 0 and tokenBalance >= amount to sell");

        // calculate sell return
        (uint256 price, uint256 amountOfEth) = calculateReturn(_amount, tokenBalanceOfSender);

        // burn tokens
        TokenInterface(tokenContract).burn(msg.sender, _amount);

        // sendEth to msg.sender from bonding curve
        VaultInterface(bondingVault).sendEth(amountOfEth, msg.sender);

        emit LogTokenSell(msg.sender, price, amountOfEth);
    }

    /**
     * @dev calculate how much ETH should be returned for a certain amount of tokens
     * @notice using version 2.1 of Khana formula - see documentation for more details
     * @notice the first returned value (finalPrice) includes the 10^18 multiplier.
    */
    function calculateReturn(
        uint256 _sellAmount, 
        uint256 _tokenBalance
    ) 
        public 
        view 
        returns (
            uint256 finalPrice, 
            uint256 redeemableEth
        ) 
    {
        require(exponentContract != address(0), "exponentContract must be set to valid address");
        require(_tokenBalance >= _sellAmount, "User trying to sell more than they have");
        uint256 tokenSupply = TokenInterface(tokenContract).getSupply();
        uint256 ethInVault = bondingVault.balance;

        // For EVM accuracy
        uint256 multiplier = 10**18;

        if (coolDownPeriod(msg.sender) <= 0) {
            // a = (Sp.10^8)
            uint256 portionE8 = (_tokenBalance.mul(10**8).div(tokenSupply));

            // b = a^1/10
            (uint256 exponentResult, uint8 precision) = FractionalExponents(exponentContract).power(portionE8, 1, 1, 10);

            // b/8 * (funds backing curve / token supply)
            uint256 interimPrice = (exponentResult.div(8)).mul(ethInVault.mul(multiplier).div(tokenSupply)).div(multiplier);

            // get final price (with multiplier)
            finalPrice = (interimPrice.mul(multiplier)).div(2**uint256(precision));
            
            // redeemable ETH (without multiplier)
            redeemableEth = finalPrice.mul(_sellAmount).div(multiplier);
            return (finalPrice, redeemableEth);
        } else {
            return (0,0);
        }
    }

    /**
    * @dev Owner can withdraw the remaining ETH balance as long as no minted tokens left
    */
    function sweepVault() public onlyOwner {
        require(TokenInterface(tokenContract).getSupply() == 0, 'Sweep available only if no minted tokens left');
        require(bondingVault.balance > 0, 'Vault is empty');
        VaultInterface(bondingVault).sendEth(bondingVault.balance, msg.sender);
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
        tokenContract = _tokenContract;
        emit LogTokenContractChanged(msg.sender, oldContract, _tokenContract);
    }

    /**
    * @dev Set the 'bondingVault' to a different contract address
    */
    function setBondingVault(address _bondingVault) public onlyOwner {
        address oldContract = bondingVault;
        bondingVault = _bondingVault;
        emit LogBondingVaultChanged(msg.sender, oldContract, _bondingVault);
    }

    /**
    * @dev Set the 'exponentContract' which calculates fractional exponents
    */
    function setExponentContract(address _exponentContract) public onlyOwner {
        address oldContract = exponentContract;
        exponentContract = _exponentContract;
        emit LogExponentContractChanged(msg.sender, oldContract, exponentContract);
    }

    /**
    * @dev Set the 'minEth' amount
    */
    function setMinEth(uint256 _minEth) public onlyOwner {
        uint256 oldAmount = minEth;
        minEth = _minEth;
        emit LogMinEthChanged(msg.sender, oldAmount, _minEth);
    }
}