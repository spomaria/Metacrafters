// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./Insurance.sol";

contract InsuranceFactory{
    Insurance[] private _insuranceList;

    // This deploys an instance of the contract
    function createInsurance(
        address _insurerAddress, string memory _tokenName, string memory _symbol
    ) public {
        Insurance insurance = new Insurance(
            _insurerAddress, 
            _tokenName, 
            _symbol
        );
        _insuranceList.push(insurance);
    }

    // This function allows user to mint some tokens for self
    function getSomeTokens(uint _index, uint _amount) public {
        _insuranceList[_index].getTokens(_amount);
    }

    // Function that checks user balance
    function getBalance(uint _index) public view returns (uint){
        return _insuranceList[_index].getBalance();
    }

    // This function allows user to subscribe
    function getSubscription(uint _index, string memory _insuranceType) public {
        _insuranceList[_index].subscribeForInsurance(_insuranceType);
    }

    // This function allows user to claim compensation
    function claimCompensation(uint _index) public {
        _insuranceList[_index].payCompensation();
    }

}