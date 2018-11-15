pragma solidity ^0.4.24;

/**
 * @title Abstraction, used to interact with the Bonding Curve Token
 */
interface TokenInterface {

    function mintToken(address _who, uint256 _amount) external returns (bool);

    function balanceOf(address owner) external view returns (uint256);

    function burn(address _who, uint256 _value) external;

    function getSupply() external view returns (uint256);

}