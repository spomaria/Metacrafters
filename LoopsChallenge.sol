// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract Loops {
    // Note that this simple loop can run for up to 7500 iterations
    // without flagging a gas limit error message given a gass limit of 3000000
    // Raising the gass limit ten times higher allows more than 30000 iterations
    function simpleLoop(uint _x) public pure returns (uint){
        uint sumX;
        for(uint i =0; i <= _x; i++){
            sumX += i;
        }
        return sumX;
    }

    // Note that this complex loop can run only  about 50 iterations
    // without flagging a gas limit error message given a gass limit of 3000000
    // Raising the gass limit ten times higher allows about 55 iterations only
    function complexLoop(int _y) public pure returns (int){
        int sumY;
        int prodY = 1;
        // string memory errMessage = "Please insert a number greater than zero";
        if (_y > 0){
            for(int j =1; j <= _y; j++){
            sumY += j;
            prodY *= j;
            }
            int diffSumProd = prodY - sumY;
            return diffSumProd;
        }else return 0;
    }
}