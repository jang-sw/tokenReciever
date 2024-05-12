// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts-upgradeable/blob/release-v3.2.0/contracts/token/ERC20/IERC20Upgradeable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v3.2.0/contracts/token/ERC20/SafeERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts-upgradeable/blob/release-v3.2.0/contracts/token/ERC20/SafeERC20Upgradeable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts-upgradeable/blob/release-v3.2.0/contracts/access/OwnableUpgradeable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts-upgradeable/blob/release-v3.2.0/contracts/utils/ReentrancyGuardUpgradeable.sol";


contract TokenReceiver  is OwnableUpgradeable, ReentrancyGuardUpgradeable{

    using SafeERC20Upgradeable for IERC20Upgradeable;
    address public transferOperator;

    
    constructor()
    public
    {
        transferOperator = msg.sender;
    }

    function updateOperator(address[] memory operator) public  {
        
        require(
            msg.sender == transferOperator,
            "Only operator can call this function."
        );

        require(
            operator.length == 1,
            "The length of params are not equal."
        );

        transferOperator = operator[0];
    }

    function batchSendERC20(
        address _token,
        address[] memory _targets,
        uint256[] memory _amounts
    ) public returns (bool success) {
        require(
            _targets.length == _amounts.length,
            "The length of params are not equal."
        );

        require(
            msg.sender == transferOperator,
            "Only operator can call this function."
        );

        IERC20Upgradeable token = IERC20Upgradeable(_token);

        for (uint256 i = 0; i < _targets.length; i++) {
            token.transfer(_targets[i], _amounts[i]);
        }
        return true;
    }

    function batchSendCoin(
        address payable[] memory _targets,
        uint256[]  memory _amounts
    ) public payable {
        require(
            _targets.length == _amounts.length,
            "The length of params are not equal."
        );
        require(
            msg.sender == transferOperator,
            "Only operator can call this function."
        );
        uint256 total = 0;
        for (uint256 i = 0; i < _targets.length; i++) {
            total += _amounts[i];
        }
        require(address(this).balance >= total, "Insufficient fund");
        for (uint256 i = 0; i < _targets.length; i++) {
            (bool sent, ) = _targets[i].call{value: _amounts[i]}("");
            require(sent, "transfer eth failed");
        }
    }

    function depositCoin() public payable {}

    function getBalanceToken(address _token) public view returns (uint256) {
        IERC20Upgradeable token = IERC20Upgradeable(_token);
        return token.balanceOf(address(this));
    }

    function getCoinBalance() public view returns (uint256) {
        return address(this).balance;
    }

}
