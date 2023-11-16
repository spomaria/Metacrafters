// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract FourFunctions {
    uint a;
    uint b;
    address owner;

    constructor(){
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(owner == msg.sender, "only the owner has access");
        _;
    }
    // set a function that accepts the two value from user
    function setNumbers(uint num1, uint num2) public onlyOwner{
        a = num1;
        b = num2;
    }

    // function that adds the two numbers
    function addNumbers() public view onlyOwner returns (uint){
        return a + b;
    }

    // function that subtracts the first number from the second
    function subtractNumbers() public view onlyOwner returns (uint){
        return b - a;
    }

    // function that multiplies the two numbers
    function multiplyNumbers() public view onlyOwner returns (uint){
        return a * b;
    }

    // function that divides the two numbers
    function divideNumbers() public view onlyOwner returns (uint){
        return b / a;
    }
}