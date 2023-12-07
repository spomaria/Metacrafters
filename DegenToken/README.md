# DegenToken
This is a simple exercise aimed at creating a basic ERC20 token  known as 'DegenToken'. The Smart Contract is compiled using 'hardhat' and deployed on the 'fuji network'. This is a required project to complete the course ETH + AVAX PROOF: Intermediate EVM Course at [@metacraftersio](https://twitter.com/metacraftersio)

## Description
This program is a simple contract written in Solidity, a programming language used for developing smart contracts on the Ethereum blockchain.
The contract inherits properties from ERC20, Ownable and ERC20Burnable. This inheritance is made possible by the following codes:
```
import "../node_modules/@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "../node_modules/@openzeppelin/contracts/access/Ownable.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
//import "hardhat/console.log";
```

The contract has one constructor and one public variable in addition to other inherited variables as follows:
```
    constructor() ERC20("Degen", "DGN") {}

    mapping (address => uint) public _balances;
    
``` 

### Functions
The contract has five functions as follows 

#### 1. The mint function
The mint function mints a given number of coins to the given address and increases the total supply of the coin by the same amount. This function inherits the standard mint function of the ERC20.

```
function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }
```

#### 2. The decimal function
This function returns the number of decimals of the DegenToken which in this case is zero. The 'override' keywords permit us to modify the original function to suite our present need.
```
    function decimals() override  public pure returns (uint8){
        return 0;
    }
```

#### 3. The getBalance function
This function returns the senders account balance.

```
    function getBalance() external view returns (uint256){
        return this.balanceOf(msg.sender);
    }
```
#### 4. the transferTokens function
This function enables the sender to send some tokens to another user. The 'require' keyword ensures that the sender has the required in his or her account. The 'approve' function enables the sender to grant approval for the smart contract to send the required amount to the sender on behalf of the sender. Note that the smart contract does not have anothe tokens of its own.
```
    function transferTokens(address _receiver, uint _value) external {
        require(balanceOf(msg.sender) >= _value, "You do not have enough Degen Tokens");
        approve(msg.sender, _value);
        transferFrom(msg.sender, _receiver, _value);
    }

```

#### 5. the burnTokens function
This function allows the sender to burn some tokens out of their account. This also reduces the total supply of the token by the amount burned.
```
    function burnTokens(uint256 _value) public payable {
        require(balanceOf(msg.sender) >= _value, "You do not have enough Degen Tokens");
        approve(msg.sender, _value);
        burnFrom(msg.sender, _value);
    }
```

#### 6. the displayStoreItems function
This function displays the items available on the store which the players can redeem by exchanging some of their tokens. This serves as a guide for the players to know what options correspond to which item.
```
    function displayStoreItems() external pure returns (string memory) {
        return "Option 1: Madona NFT \n Option 2: Miraculous Medal \n Option 3: Portrait of Hilder Baci";
    }
```

#### 7. the redeemTokens function
This function receives the option selected by the player, checks if the player has the required balance, deducts the required amount from the players account and updates the players account balance.
```
    // This function lets one to exchange an item from the store
    // by redeeming some Degen Tokens
    function redeemTokens(uint _option) public payable {
        require(_option == 1 || _option == 2 || _option == 3,
            "Selection out of bounds. Please select within the approved options");
        uint value;
        if(_option == 1){
            value = 50;
        }else if(_option == 2){
            value = 40;
        }else {
            value = 30;
        }
        address owner = _msgSender();
        uint256 senderBalance = _balances[owner];
        require(senderBalance >= value, "You do not have enough Degen Tokens");
        approve(msg.sender, value);
        senderBalance -= value;
        _balances[owner] = senderBalance;
    }
```

## Getting Started
### Program Execution
To run the program, you can use Remix, an online Solidity IDE which can be accessed using via the website https://remix.ethereum.org/.

Once you are on the Remix website, create a new file by clicking on the '+' icon in the left-hand side bar. Save the file with a .sol extension (e.g., MyToken.sol). Copy and paste the following code into the file:

```
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "../node_modules/@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "../node_modules/@openzeppelin/contracts/access/Ownable.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
//import "hardhat/console.log";

contract DegenToken is ERC20, Ownable, ERC20Burnable {

    constructor() ERC20("Degen", "DGN") {}

    mapping (address => uint) public _balances;
    
    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    function decimals() override  public pure returns (uint8){
        return 0;
    }

    function getBalance() external view returns (uint256){
        return this.balanceOf(msg.sender);
    }

    function transferTokens(address _receiver, uint _value) external {
        require(balanceOf(msg.sender) >= _value, "You do not have enough Degen Tokens");
        approve(msg.sender, _value);
        transferFrom(msg.sender, _receiver, _value);
    }

    function burnTokens(uint256 _value) public payable {
        require(balanceOf(msg.sender) >= _value, "You do not have enough Degen Tokens");
        approve(msg.sender, _value);
        burnFrom(msg.sender, _value);
    }

    function displayStoreItems() external pure returns (string memory) {
        return "Option 1: Madona NFT \n Option 2: Miraculous Medal \n Option 3: Portrait of Hilder Baci";
    }

    // This function lets one to exchange an item from the store
    // by redeeming some Degen Tokens
    function redeemTokens(uint _option) public payable {
        require(_option == 1 || _option == 2 || _option == 3,
            "Selection out of bounds. Please select within the approved options");
        uint value;
        if(_option == 1){
            value = 50;
        }else if(_option == 2){
            value = 40;
        }else {
            value = 30;
        }
        address owner = _msgSender();
        uint256 senderBalance = _balances[owner];
        require(senderBalance >= value, "You do not have enough Degen Tokens");
        approve(msg.sender, value);
        senderBalance -= value;
        _balances[owner] = senderBalance;
    }
}

```

To compile the code, click on the "Solidity Compiler" tab in the left-hand sidebar. Make sure the "Compiler option is set to "0.8.9", and then click on the "Compile DegenToken.sol" button.

Once the code is compiled, you can deploy the contract by clicking on the "Deploy & Run Transactions" tab in the left-hand sidebar. Select the "DegenToken" contract from the dropdown menu, and then click on the "Deploy" button.

Once the contract is deployed, you can interact with it as follows

1. click on "totalSupply" to view the total supply of the coin

2. click on "tokenName" to view the name of the token i.e. "DegenToken"

3. click on "tokenSymbol" to view the token name abbreviation i.e. "DGN"

4. click on "mint" to mint new coins to any given address. You can copy an address from the "Account" tab above the "Deploy" button. This copied address can be used as argument to the mint function by pasting it at the address column, enter the amount of coins you wish to mint and hit the "transact" button to mint. You may click on the "totalSupply" button to check if the amount of coins minted is added to the total supply of the coin.

5. After minting the coins to the copied address, paste the same address into the "balances" column and click on the "balances" button to check the balance of that address.

6. click on "burnTokens" to burn coins from any given address. You can copy any address to which you have minted coins from the "Account" tab above the "Deploy" button. This copied address can be used as argument to the burnTokens function by pasting it at the address column, enter the amount of coins you wish to burn and hit the "transact" button. You may use the "balances" button to check if the balance of the address has reduced by the amount burned. Also click the "totalSupply" button to check if the total supply of the coin has reduced by the amount of coins burned.

7. click on "redeemTokens", input any number between 1, 2 and 3,  to redeem the corresponding item. You may use the "balances" button to check if the balance of the address has reduced by 50, 40 or 30 DGN tokens respectively. 

## Authors
Nengak Emmanuel Goltong 

[@NengakGoltong](https://twitter.com/nengakgoltong) 
[@nengakgoltong](https://www.linkedin.com/in/nengak-goltong-81009b200)

## License
This project is licensed under the MIT License - see the LICENSE.md file for details