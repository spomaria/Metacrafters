//SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

contract LoanSystem {
    // This is a contract regarding the disbursement and repayment of loans
    // We then need to keep track of the debt acrued to those who received loans

    mapping(address => uint) private balances;
    mapping(address => uint) private debts;

    event Deposit(address indexed _account, uint amount);
    event LoanRequest(address indexed _account, uint amount);
    event DisburseLoan(address indexed _coopAccount, address indexed _account, uint amount);
    event Withdraw(address indexed _account, uint amount);
    event RepayLoan(address indexed _account, address indexed _coopAccount, uint amount);

    function deposit(address _account, uint _number) public payable {
        balances[_account] += _number;
        emit Deposit(_account, _number);
    }

    function disburseLoan(address _coopAccount, address _account, uint _number) public payable {
        require(balances[_coopAccount] >= _number, "Insufficient Funds in Treasury");
        balances[_coopAccount] -= _number;
        balances[_account] += _number;
        debts[_account] += _number;
        emit LoanRequest(_account, _number);
        emit DisburseLoan(_coopAccount, _account, _number);
    }

    function withdraw(address _account, uint _number) public payable {
        require(balances[_account] > 0, "You're broke!");
        balances[_account] -= _number;
        emit Withdraw(_account, _number);
    }

    function repayLoan(address _account, address _coopAccount, uint _number) public payable {
        require(balances[_account] >= _number, "You do not have enough funds for this transaction");
        balances[_account] -= _number;
        debts[_account] -= _number;
        balances[_coopAccount] += _number;
        emit RepayLoan(_account, _coopAccount, _number);
    }

    function getBalance(address _address) public view returns(uint) {
        return balances[_address];
    }

    function getDebt(address _address) public view returns(uint) {
        return debts[_address];
    } 
}