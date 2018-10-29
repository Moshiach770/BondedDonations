pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/token/ERC20/ERC20Mintable.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "./BondingCurve.sol";
import "./Logic.sol";

contract Token is ERC20, Ownable {

    string public name = "CharityToken";
    string public symbol = "CHARITY";
    uint8 public decimals = 18;

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

    event LogMint
    (
        address forWhom,
        uint256 amount
    );

    // Enforce logicContract only calls
    modifier onlyLogicContract() {
        require(msg.sender == logicContract, "Only logicContract can call this");
        _;
    }

    constructor(address _logicContract) public {
        setLogicContract(_logicContract);
    }

    /**
     * @dev The mint function
     */
    function mintToken(address _who, uint256 _amount) public onlyLogicContract returns (bool) {
        require(_who != address(0), "Invalid address");
        require(_amount > 0, "Invalid amount to mint");

        _mint(_who, _amount);
        emit LogMint(_who, _amount);
        return true;
    }

    /**
     * @dev The burn function, copied from OpenZepplin's burnable token
     */
    function burn(address _who, uint256 _value) public onlyLogicContract {
        require(_value <= balanceOf(_who), "Burn amount needs to be <= to balance");

        _burn(_who, _value);
        emit LogBurn(_who, _value);
    }

    /**
    * @dev Set the 'logicContract' to a different contract address
    */
    function setLogicContract(address _logicContract) public onlyOwner {
        address oldContract = logicContract;
        logicContract = _logicContract;
        emit LogLogicContractChanged(msg.sender, oldContract, _logicContract);
    }

    //allow freezing (only logicContract)

    /**
    * @dev Get supply of MintableToken
    */
    function getSupply() public view returns (uint256) {
        return totalSupply();
    }
}