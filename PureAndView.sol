// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract PureAndView {
    uint a = 10;
    uint b = 15;

    mapping(address => uint256) balances;
    
    // A 'pure' function that adds the two numbers
    // This function does not interact with the blockchain
    function addNumbers(uint _a, uint _b) public pure returns (uint){
        return _a + _b;
    }

    // A 'view' function that subtracts the first number from the second
    // This function reads from the blockchain but does not write on the blockchain
    function subtractNumbers(uint _num) public view returns (string memory){
        if(_num > a && _num > b){
            return "The inputed number is the largest";
        }
        return "The inputed number is not the largest";
    }


}