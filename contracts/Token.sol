pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/token/ERC20/MintableToken.sol";
import "./BondingCurve.sol";

contract Token is MintableToken {

    // Where business logic resides
    address public logicContract;

    event LogLogicContractChanged
    (
        address byWhom,
        address oldContract,
        address newContract
    );

    // Enforce logicContract only calls
    modifier onlyLogicContract() {
        require(msg.sender == logicContract);
        _;
    }

    constructor(address _logicContract) public {
        setLogicContract(_logicContract);
    }

    // mint tokens (only logicContract) to address

    // payable function mints tokens to sender (donation), sends 90% to logic contract for chairty

    /**
    * @dev Set the 'logicContract' to a different contract address
    */
    function setLogicContract(address _logicContract) public onlyOwner {
        address oldContract = logicContract;
        logicContract = _logicContract;
        emit LogLogicContractChanged(msg.sender, oldContract, _logicContract);
    }

    //allow freezing (only logicContract)
}