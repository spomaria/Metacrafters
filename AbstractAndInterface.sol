// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

interface IWallet {
    function deposit(address _addr, uint _amount) external payable;

    function getBalance(address _addr) external view returns (uint);
}

// Inherit and implement the IWallet interface
contract Wallet is IWallet {
    mapping(address => uint) public balance;

    function deposit(address _addr, uint _amount) external payable override{
        balance[_addr] += _amount;
    }
    function getBalance(address _addr) external view override returns (uint){
        return balance[_addr];
    }
}

contract WalletFriendlyContract {
    uint constant minimumBalance = 100;
    mapping(address => uint) public balance;

    // Checks if the wallet has some minimum balance using the interface
    function hasMinimumBalance(address _addr) external view returns (bool){
        return IWallet(_addr).getBalance(_addr) > minimumBalance;
    }
}