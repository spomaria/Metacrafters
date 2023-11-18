# SpoToken
This solidity program is a simple exercise aimed at creating a basic token  known as 'Spo-Token'. The purpose is to demonstrate how to create a coin in its basic form. This is a required project to complete the course ETH PROOF: Beginner EVM Course at [@metacraftersio](https://twitter.com/metacraftersio)

## Description
This program is a simple contract written in Solidity, a programming language used for developing smart contracts on the Ethereum blockchain.
The contract has three public variables and two functions; 'mint' and 'burnt'. 

The public variables are given as

```
// public variables here
string public tokenName = "Spo-Token";
string public tokenAbrv = "SPT";
uint public totalSupply = 0;

```
Each of these two functions accepts two parameters; address (i.e. _address) and amount of coins (i.e. _value). 

The mint function mints a given number of coins to the given address and increases the total supply of the coin by the same amount. 

```
// mint function
function mint (address _address, uint _value) public {
    totalSupply += _value;
    balances[_address] += _value;
    }
```
On the other hand, the burn function decreases the number of coins in the given address by a specified number and decreases the total supply by the same amount.
```
// burn function
    function burn (address _address, uint _value) public {
        if (balances[_address] >= _value){
            totalSupply -= _value;
            balances[_address] -= _value;
        }
        
    }
```

## Getting Started
### Program Execution
To run the program, you can use Remix, an online Solidity IDE which can be accessed using via the website https://remix.ethereum.org/.

Once you are on the Remix website, create a new file by clicking on the '+' icon in the left-hand side bar. Save the file with a .sol extension (e.g., MyToken.sol). Copy and paste the following code into the file:

```
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

/*
       REQUIREMENTS
    1. Your contract will have public variables that store the details about your coin (Token Name, Token Abbrv., Total Supply)
    2. Your contract will have a mapping of addresses to balances (address => uint)
    3. You will have a mint function that takes two parameters: an address and a value. 
       The function then increases the total supply by that number and increases the balance 
       of the “sender” address by that amount
    4. Your contract will have a burn function, which works the opposite of the mint function, as it will destroy tokens. 
       It will take an address and value just like the mint functions. It will then deduct the value from the total supply 
       and from the balance of the “sender”.
    5. Lastly, your burn function should have conditionals to make sure the balance of "sender" is greater than or equal 
       to the amount that is supposed to be burned.
*/

contract SpoToken {

    // public variables here
    string public tokenName = "Spo-Token";
    string public tokenAbrv = "SPT";
    uint public totalSupply = 0;

    // mapping variable here
    mapping (address => uint) public balances;

    // mint function
    function mint (address _address, uint _value) public {
        totalSupply += _value;
        balances[_address] += _value;
    }

    // burn function
    function burn (address _address, uint _value) public {
        if (balances[_address] >= _value){
            totalSupply -= _value;
            balances[_address] -= _value;
        }
        
    }
}

```

To compile the code, click on the "Solidity Compiler" tab in the left-hand sidebar. Make sure the "Compiler option is set to "0.8.4", and then click on the "Compile SpoToken.sol" button.

Once the code is compiled, you can deploy the contract by clicking on the "Deploy & Run Transactions" tab in the left-hand sidebar. Select the "SpoToken" contract from the dropdown menu, and then click on the "Deploy" button.

Once the contract is deployed, you can interact with it as follows

1. click on "totalSupply" to view the total supply of the coin

2. click on "tokenName" to view the name of the token i.e. "Spo-Token"

3. click on "tokenAbrv" to view the token name abbreviation i.e. "SPT"

4. click on "mint" to mint new coins to any given address. You can copy an address from the "Account" tab above the "Deploy" button. This copied address can be used as argument to the mint function by pasting it at the address column, enter the amount of coins you wish to mint and hit the "transact" button to mint. You may click on the "totalSupply" button to check if the amount of coins minted is added to the total supply of the coin.

5. After minting the coins to the copied address, paste the same address into the "balances" column and click on the "balances" button to check the balance of that address.

6. click on "burn" to burn coins from any given address. You can copy any address to which you have minted coins from the "Account" tab above the "Deploy" button. This copied address can be used as argument to the burn function by pasting it at the address column, enter the amount of coins you wish to burn and hit the "transact" button. You may use the "balances" button to check if the balance of the address has reduced by the amount burned. Also click the "totalSupply" button to check if the total supply of the coin has reduced by the amount of coins burned.

## Authors
Nengak Emmanuel Goltong 

[@NengakGoltong](https://twitter.com/nengakgoltong) 
[@nengakgoltong](https://www.linkedin.com/in/nengak-goltong-81009b200)

## License
This project is licensed under the MIT License - see the LICENSE.md file for details
