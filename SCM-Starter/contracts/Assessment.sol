// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7;

//import "hardhat/console.sol";

contract Assessment {
    address payable public owner;
    uint256 public balance;
    uint256 public square;
    uint256 public factorial = 1;

    event Deposit(uint256 amount);
    event Withdraw(uint256 amount);
    event PayFee();

    constructor(uint initBalance) payable {
        owner = payable(msg.sender);
        balance = initBalance;
    }

    function getBalance() public view returns(uint256){
        return balance;
    }

    // This function allows the user to retrieve the square of a number
    function getSquareOfNum() public view returns(uint256){
        return square;
    }

    // This function allows the user to retrieve the factorial of a number
    function getFactorialOfNum() public view returns(uint256){
        return factorial;
    }

    function deposit(uint256 _amount) public payable {
        uint _previousBalance = balance;

        // make sure this is the owner
        require(msg.sender == owner, "You are not the owner of this account");

        // perform transaction
        balance += _amount;

        // assert transaction completed successfully
        assert(balance == _previousBalance + _amount);

        // emit the event
        emit Deposit(_amount);
    }

    // custom error
    error InsufficientBalance(uint256 balance, uint256 withdrawAmount);

    function withdraw(uint256 _withdrawAmount) public {
        require(msg.sender == owner, "You are not the owner of this account");
        uint _previousBalance = balance;
        if (balance < _withdrawAmount) {
            revert InsufficientBalance({
                balance: balance,
                withdrawAmount: _withdrawAmount
            });
        }

        // withdraw the given amount
        balance -= _withdrawAmount;

        // assert the balance is correct
        assert(balance == (_previousBalance - _withdrawAmount));

        // emit the event
        emit Withdraw(_withdrawAmount);
    }

    function payFee() public {
        require(msg.sender == owner, "You are not the owner of this account");
        uint _previousBalance = balance;
        if (balance < 1) {
            revert ("Your balance must be greater or equal to 1 ETH");
        }

        // pay the required fee
        balance -= 1;

        // assert the balance is correct
        assert(balance == (_previousBalance - 1));

        // emit the event
        emit PayFee();
    }

    // This function allows the user to calculate the square of a number
    // After paying the required fee
    function squareOfNum(uint _num) public payable returns (uint){
        payFee();
        square= _num * _num;
        return square;
    }

    // This function allows the user to calculate the factorial of a number
    // After paying the required fee
    function factorialOfNum(uint _num) public payable returns (uint){
        payFee();
        factorial = 1;
        for(uint i = 1; i <= _num; i++){
            factorial *= i;
        }
        return factorial;
    }
}
