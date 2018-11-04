pragma solidity ^0.4.24;

import "./Logic.sol";


/**
 * @title Proof of Concept contract for Donation customization of Bonding Curve Logic
 */
contract DonationLogic is Logic {

    // Charity address
    address public charityAddress;

    // KYC flag
    bool public kycEnabled;

    event LogCharityAddressChanged
    (
        address byWhom,
        address oldAddress,
        address newAddress
    );

    event LogDonationReceived
    (
        address byWhom,
        uint256 amount
    );

    event LogCharityAllocationSent(
        uint256 amount,
        address indexed account
    );

    modifier kycCheck() {
        if (kycEnabled) {
            // require whitelisted address (see Bloom docs?)
        }
        _;
    }

    /**
    * @dev donation function splits ETH, 90% to charityAddress, 10% to fund bonding curve
    */
    function donate() public payable {
        require(charityAddress != address(0), "Charity address is not set correctly");
        require(msg.value > 0, "Must include some ETH to donate");

        // Make ETH distributions
        uint256 multiplier = 100;
        uint256 charityAllocation = (msg.value).mul(90); // 90% with multiplier
        uint256 bondingAllocation = (msg.value.mul(multiplier)).sub(charityAllocation).div(multiplier);
        sendToCharity(charityAllocation.div(multiplier));

        //fund the Logic with ETH calling fallback function
        address(this).transfer(bondingAllocation);

        // Mint the tokens - 10:1 ratio (e.g. for every 1 ETH sent, you get 10 tokens)
        super.award(msg.sender, (msg.value).mul(10),  'Donation received');
        emit LogDonationReceived(msg.sender, msg.value);
    }

    // TODO: - DAI integration: buy DAI with ETH, store in charityAddress
    function sendToCharity(uint256 _amount) internal {
        // this should auto convert to DAI
        // look into OasisDEX or Bancor on-chain tx
        charityAddress.transfer(_amount);
        emit LogCharityAllocationSent(_amount, msg.sender);
    }

    // KYC logic - stretch goals
    // add donator to whitelist
    // see Bloom docs

    // only owner

    /**
    * @dev Set the 'charityAddress' to a different contract address
    */
    function setCharityAddress(address _charityAddress) public onlyOwner {
        address oldAddress = charityAddress;
        charityAddress = _charityAddress;
        emit LogCharityAddressChanged(msg.sender, oldAddress, _charityAddress);
    }

}