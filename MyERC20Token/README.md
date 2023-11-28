# MyERC20 Token (SpoToken)
This solidity program is a simple exercise aimed at creating a basic ERC20 token  known as 'Spo-Token'. The purpose is to demonstrate how to create a coin that conforms to the ERC20 standards. This is a required project to complete the 'Types of Functions' section of ETH + AVAX PROOF: Intermediate EVM Course at [@metacraftersio](https://twitter.com/metacraftersio)

## Description
This program is a simple contract written in Solidity, a programming language used for developing smart contracts on the Ethereum blockchain.
The program consists of an interface 'Token' and a contract 'SpoToken' which uses the functions declared in the interface. 

For the purpose of this exercise, we shall focus on the functions and variables that are relevant to our objectives.

### 1. The Variables
The variables are given as

```
mapping (address => uint256) public balances;
    mapping (address => mapping (address => uint256)) public allowed;
    uint256 public totalSupply;
    /*
    NOTE:
    The following variables are OPTIONAL vanities. One does not have to include them.
    They allow one to customise the token contract & in no way influences the core functionality.
    Some wallets/interfaces might not even bother to look at this information.
    */
    string public name;                   //fancy name: eg Simon Bucks
    uint8 public decimals;                //How many decimals to show.
    string public symbol;                 //An identifier: eg SBX

```

### 2. The Constructor
The contract has one constructor. This ensures that only the creator of the contract can mint tokens. The constructor sets the total supply, name, decimals, and symbol of the token. The constructor is given as:
```
constructor(uint256 _initialAmount, string memory _tokenName, uint8 _decimalUnits, string  memory _tokenSymbol) {
        balances[msg.sender] = _initialAmount;               // Give the creator all initial tokens
        totalSupply = _initialAmount;                        // Update total supply
        name = _tokenName;                                   // Set the name for display purposes
        decimals = _decimalUnits;                            // Amount of decimals for display purposes
        symbol = _tokenSymbol;                               // Set the symbol for display purposes
    }
```

### 3. The Transfer Function
The function enables the transfer of tokens from one account to the other provided the sender's account has at least the amount of tokens to be transfered.

The transfer function accepts three parameters, the sender's address (_from), the receiver's address (_to) and the amount to be transfered (_value). The function is given as
```
    function transferFrom(address _from, address _to, uint256 _value) public override returns (bool success) {
        // uint256 allowances = allowed[_from][msg.sender];
        // require(balances[_from] >= _value && allowances >= _value, "token balance or allowance is lower than amount requested");
        require(balances[_from] >= _value, "token balance is lower than amount requested");
        balances[_to] += _value;
        balances[_from] -= _value;
        // if (allowances < MAX_UINT256) {
        //     allowed[_from][msg.sender] -= _value;
        // }
        emit Transfer(_from, _to, _value); //solhint-disable-line indent, no-unused-vars
        return true;
    }
```

### 4. The Balance Function
This function checks the balance of any given address. The function accepts the address and returns the balance on that address as below:
```
function balanceOf(address _owner) public override view returns (uint256 balance) {
        return balances[_owner];
    }
```

### 5. The Burn Function
The Burn Function decreases the number of tokens in the given address by a specified number and decreases the total supply by the same amount. This function is given by
```
    // This function burns some tokens by
    // subtracting _value from _owner's account and 
    // subtracting _value from the totalSupply
    function burn(address _owner, uint _value) public payable{
        totalSupply -= _value;
        balances[_owner] -= _value;
    }
```

## Getting Started
### Program Execution
To run the program, you can use Remix, an online Solidity IDE which can be accessed using via the website https://remix.ethereum.org/.

Once you are on the Remix website, create a new file by clicking on the '+' icon in the left-hand side bar. Save the file with a .sol extension (e.g., MyERC20Token.sol). Copy and paste the following code into the file:

```
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

interface Token {

    /// @param _owner The address from which the balance will be retrieved
    /// @return balance the balance
    function balanceOf(address _owner) external view returns (uint256 balance);

    /// @notice send `_value` token to `_to` from `msg.sender`
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return success Whether the transfer was successful or not
    function transfer(address _to, uint256 _value)  external returns (bool success);

    /// @notice send `_value` token to `_to` from `_from` on the condition it is approved by `_from`
    /// @param _from The address of the sender
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return success Whether the transfer was successful or not
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);

    /// @notice `msg.sender` approves `_addr` to spend `_value` tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @param _value The amount of wei to be approved for transfer
    /// @return success Whether the approval was successful or not
    function approve(address _spender  , uint256 _value) external returns (bool success);

    /// @param _owner The address of the account owning tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @return remaining Amount of remaining tokens allowed to spent
    function allowance(address _owner, address _spender) external view returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

contract SpoToken is Token {
    uint256 constant private MAX_UINT256 = 2**256 - 1;
    mapping (address => uint256) public balances;
    mapping (address => mapping (address => uint256)) public allowed;
    uint256 public totalSupply;
    /*
    NOTE:
    The following variables are OPTIONAL vanities. One does not have to include them.
    They allow one to customise the token contract & in no way influences the core functionality.
    Some wallets/interfaces might not even bother to look at this information.
    */
    string public name;                   //fancy name: eg Simon Bucks
    uint8 public decimals;                //How many decimals to show.
    string public symbol;                 //An identifier: eg SBX

    constructor(uint256 _initialAmount, string memory _tokenName, uint8 _decimalUnits, string  memory _tokenSymbol) {
        balances[msg.sender] = _initialAmount;               // Give the creator all initial tokens
        totalSupply = _initialAmount;                        // Update total supply
        name = _tokenName;                                   // Set the name for display purposes
        decimals = _decimalUnits;                            // Amount of decimals for display purposes
        symbol = _tokenSymbol;                               // Set the symbol for display purposes
    }

    function transfer(address _to, uint256 _value) public override returns (bool success) {
        require(balances[msg.sender] >= _value, "token balance is lower than the value requested");
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        emit Transfer(msg.sender, _to, _value); //solhint-disable-line indent, no-unused-vars
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public override returns (bool success) {
        // uint256 allowances = allowed[_from][msg.sender];
        // require(balances[_from] >= _value && allowances >= _value, "token balance or allowance is lower than amount requested");
        require(balances[_from] >= _value, "token balance is lower than amount requested");
        balances[_to] += _value;
        balances[_from] -= _value;
        // if (allowances < MAX_UINT256) {
        //     allowed[_from][msg.sender] -= _value;
        // }
        emit Transfer(_from, _to, _value); //solhint-disable-line indent, no-unused-vars
        return true;
    }

    function balanceOf(address _owner) public override view returns (uint256 balance) {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value) public override returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value); //solhint-disable-line indent, no-unused-vars
        return true;
    }

    function allowance(address _owner, address _spender) public override view returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

    // This function burns some tokens by
    // subtracting _value from _owner's account and 
    // subtracting _value from the totalSupply
    function burn(address _owner, uint _value) public payable{
        totalSupply -= _value;
        balances[_owner] -= _value;
    }
}
```

To compile the code, click on the "Solidity Compiler" tab in the left-hand sidebar. Make sure the "Compiler option is set to "0.8.7", and then click on the "Compile SpoToken.sol" button.

Once the code is compiled, the next step is to deploy the contract. Click the down arrow button beside the 'Deploy' button and input the information of your choice (e.g. _initialAmount as 1,000; tokenName as SpoToken; decimalUnits as 7; tokenSymbol as SPT) and click on the "transact" button to deploy the contract. 

Once the contract is deployed, scrol down to the 'Deployed Contracts' section so you can interact with it as follows

1. click on "totalSupply" to view the total supply of the coin

2. click on "tokenName" to view the name of the token i.e. "SpoToken"

3. click on "tokenSymbol" to view the token name abbreviation i.e. "SPT"

4. by default, the total supply of the token is minted to the wallet address that is currently active in the 'Account' section. To confirm this, copy the address, scrol down and paste it in the space provided beside the 'balances' button and click. You will notice that the amount of tokens in this address is same as the total supply of the token.

5. paste the same wallet address and input the amount to be burnt (say, 200) in the space provided beside the 'burn' button and click. By checking the balance and totalSupply, you'll notice both have reduced by the same amount i.e. the amount burnt.

6. to tranfer tokens to another account, go to the 'transferFrom' button and click on the arrow key beside it. Paste the address initial address in the '_from' column. Move up to the 'Account' section, select another address, copy and copy it. Now, move down to the 'transferFrom' section and paste the copied address in the '_to' column, enter an amount (say 200) and click on 'transact' to transfer.

7. go to the 'balanceOf' section, paste the copied address and click on the 'balanceOf' button. This should equal the same amount transfered. Also, by clicking on the 'balances' button (which still has the wallet address where tokens were recently transfered from), the amount of tokens should have reduced by the amount transfered.

8. To demonstrate that any user can burn tokens, go to the 'burn' section, paste the copied address, enter an amount (say 100) and click on the 'burn' button. On checking, the totalSupply should have reduced by the same amount (i.e. 100) and by clicking the 'balanceOf' button (which still has the wallet address where tokens were recently burnt), the amount of tokens should have reduced by the same amount.

## Authors
Nengak Emmanuel Goltong 

[@NengakGoltong](https://twitter.com/nengakgoltong) 
[@nengakgoltong](https://www.linkedin.com/in/nengak-goltong-81009b200)

## License
This project is licensed under the MIT License - see the LICENSE.md file for details
