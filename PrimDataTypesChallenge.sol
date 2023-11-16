// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract EthConverter {
    uint ethAmount;

    // function to receive amount of ether by user
    function setEthAmount(uint _ethAmount) public {
        ethAmount = _ethAmount;
    }

    // function that displays ethAmount in units of ether 
    function getEthAmount() view public returns (uint){
        return ethAmount;
    }

    // function that displays ethAmount in units of gwei 
    function getGweiAmount() view public returns (uint){
        return ethAmount * 10**9;
    }

    // function that displays ethAmount in units of wei 
    function getWeiAmount() view public returns (uint){
        return ethAmount * 10**18;
    }
}