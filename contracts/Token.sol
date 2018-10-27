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

    event LogBurn
    (
        address byWhom,
        uint256 amount
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
    * @dev The fallback function - should call 'donate' function in Logic contract
    */
    function () public payable {
        
    }


    /**
    * @dev Set the 'logicContract' to a different contract address
    */
    function setLogicContract(address _logicContract) public onlyOwner {
        address oldContract = logicContract;
        logicContract = _logicContract;
        emit LogLogicContractChanged(msg.sender, oldContract, _logicContract);
    }

    /**
     * @dev The internal burn function, copied from OpenZepplin's burnable token
     */
    function burn(address _who, uint256 _value) public onlyLogicContract {
        require(_value <= balances[_who], "Burn amount needs to be <= to balance");

        balances[_who] = balances[_who].sub(_value);
        totalSupply_ = totalSupply_.sub(_value);
        emit LogBurn(_who, _value);
    }

    //allow freezing (only logicContract)

    /**
    * @dev Get supply of MintableToken
    */
    function getSupply() public view returns (uint256) {
        return totalSupply();
    }
}