// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract MyInfo {

    mapping (address => string) userName;
    uint userAge;

    function setUserInfo(string memory _name, uint _age) public {
        userName[msg.sender] = _name;
        userAge = _age;
    }

    function getUserName() public view returns (string memory){
        return userName[msg.sender];
    }

    function getUserAge() public view returns (uint){
        return userAge;
    }
}