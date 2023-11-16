// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract VariableTypes{
    uint posNumber;
    int number;
    string myString;
    bool myBool;

    // create a set function for each of the state variables above
    function setPosNumber(uint _posNumber) public {
        posNumber = _posNumber;
    }

    function setNumber(int _number) public {
        number = _number;
    }

    function setMyString(string memory _myString) public {
        myString = _myString;
    }

    function setMyBool(bool _myBool) public {
        myBool = _myBool;
    }

    // create the get functions to display the values of the state variables
    function getPosNumber() public view returns (uint){
        return posNumber;
    }

    function getNumber() public view returns (int){
        return number;
    }

    function getMyString() public view returns (string memory){
        return myString;
    }

    function getMyBool() public view returns (bool){
        return myBool;
    }
}