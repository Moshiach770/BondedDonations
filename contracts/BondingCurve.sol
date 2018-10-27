pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

contract BondingCurve is Ownable {

    // Keep the balances of ERC20s
    address public tokenContract;

    // Where business logic resides
    address public logicContract;

    // Enforce tokenContract only calls
    modifier onlyTokenContract() {
        require(msg.sender == tokenContract);
        _;
    }

    // Enforce logicContract only calls
    modifier onlyLogicContract() {
        require(msg.sender == logicContract);
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    // constructor takes tokenContract address and logicContract address

    // send eth to seller (onlyLogicContract can call)

    // mint tokens to donator (onlyLogicContract)

    // payable function mints tokens to sender (donation), sends 90% to logic contract for chairty

    // only owner
    //allow changing of tokenContract
    //allow changing of logicContract
    //allow freezing (only logicContract)
}