pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/token/ERC20/MintableToken.sol";
import "./BondingCurve.sol";

contract Token is MintableToken {

    // Where business logic resides
    address public logicContract;

    // Enforce logicContract only calls
    modifier onlyLogicContract() {
        require(msg.sender == logicContract);
        _;
    }

    // constructor takes logicContract address

    // mint tokens (only logicContract) to address

    // payable function mints tokens to sender (donation), sends 90% to logic contract for chairty

    // only owner
    //allow changing of logicContract
    //allow freezing (only logicContract)
}