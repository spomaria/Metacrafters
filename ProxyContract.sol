// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

// NOTE: Deploy this contract first
contract FirstToken {
    // NOTE: storage layout must be the same as contract oneCall
    // public variables here
    string public tokenName = "First-Token";
    string public tokenAbrv = "FT";
    uint public totalSupply = 0;

    // mapping variable here
    // mapping (address => uint) public balances;

    // mint function
    function mint (uint _value) public {
        totalSupply += _value;
        // balances[_address] += _value;
    }

    // burn function
    function burn (uint _value) public {
        totalSupply -= _value;
        // if (balances[_address] >= _value){
        //     totalSupply -= _value;
        //     balances[_address] -= _value;
        // }
        
    }
}

contract CallFirstToken {
    string public tokenName = "First-Token";
    string public tokenAbrv = "FT";
    uint public totalSupply = 0;

    // mapping variable here
    // mapping (address => uint) public balances;

    function mint (address _contract, uint _value) public {
        // OneCall's storage is set, Twocall is not modified.
        (bool success, bytes memory data) = _contract.delegatecall(
            abi.encodeWithSignature("mint(uint256)", _value)
        );
    }

    function burn (address _contract, uint _value) public {
        // OneCall's storage is set, Twocall is not modified.
        (bool success, bytes memory data) = 
        _contract.delegatecall(
            abi.encodeWithSignature("burn(uint256)", _value)
        );
    }
}
