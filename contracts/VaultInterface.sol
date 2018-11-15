pragma solidity ^0.4.24;

/**
 * @title Abstraction, used to interact with the Bonding Curve Vault
 */
interface VaultInterface {

    function sendEth(uint256 _amount, address _account) external;

}