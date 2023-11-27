//SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

contract PayableFallBack {
    
    error NotFound(bytes4, bytes);

    mapping(address => uint) private balances;
    mapping(address => uint) private debts;
    address public coopAccount;

    function setCoopAccount(address _coopAccount) public {
        coopAccount = _coopAccount;
    }

    function deposit(address _account, uint _number) public payable {
        balances[_account] += _number;
        
    }

    function requestLoan(address _account, uint _number) public payable {
        require(balances[coopAccount] >= _number, "Insufficient Funds in the Treasury");
        if(debts[_account] > 0){
            revert("You have unsettled debt. Request Declined!!");
        }
        balances[coopAccount] -= _number;
        balances[_account] += _number;
        debts[_account] += _number;
    }

    function withdraw(address _account, uint _number) public payable {
        assert(balances[_account] >= _number);
        balances[_account] -= _number;
    }

    function repayLoan(address _account, uint _number) public payable {
        if(balances[_account] < _number){
            revert("You do not have sufficient funds for this transaction");
        }
        balances[_account] -= _number;
        debts[_account] -= _number;
        balances[coopAccount] += _number;
    }

    function getBalance(address _address) public view returns(uint) {
        return balances[_address];
    }

    function getDebt(address _address) public view returns(uint) {
        return debts[_address];
    }

    // The Callback Function
    fallback() external { 
        revert NotFound(msg.sig, msg.data);
    }   
}
