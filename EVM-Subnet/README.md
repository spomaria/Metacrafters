# EVM Subnets
This is a simple exercise on how to create a subnet on Avalanche. By using the functionalities made available on Avalanche, we create a subnet and deploy it on Avalanche. Finally, we deploy two contracts on the subnet and interact with these contracts on Remix.

This is a required project to complete the EVM-Subnet part of ETH + AVAX PROOF: Advance Course at [@metacraftersio](https://twitter.com/metacraftersio)

## Subnets on Avalanche
In order to create an EVM Subnet, we first have to install an Avalanche Command Line Interface (cli). 

### Installing Avalanche cli tool
The easiest way to install the Avalanche cli tool is by using the command 
```
curl -sSfL https://raw.githubusercontent.com/ava-labs/avalanche-cli/main/scripts/install.sh | sh -s
```
The above command fetches the latest release of the Avalanche cli tool and installs it on your local machine.

However, it the above command does not work, you can follow these steps:
1. First install the 'gvm installer' on your machine using this command
```
bash < <(curl -s -S -L https://raw.githubusercontent.com/moovweb/gvm/master/binscripts/gvm-installer)
```
this allows you to install any available version of 'go' on your local machine.

2. Check out the list of all versions of 'go' available using the following command 
```
gvm listall
```

3. Install 'go' on your local machine using the following command 
```
gvm install go1.21.5
```
You may choose a different version of 'go' to install.

4. Next, clone this git repository on your local machine using the following command
```
git clone https://github.com/ava-labs/avalanche-cli/tree/main
```

5. Change to the cloned directory and type in the following commands
```
./scripts/build.sh
./scripts/install.sh
``` 
6. By now, the Avalanche cli tool should have bee installed on your local machine. To ensure this is so, type in the following command to check out the version
```
avalanche --version
```

With the Avalanche cli tool successfully installed, we can proceed to create and deploy an EVM Subnet.

### Creating an EVM Subnet
To create an EVM Subnet, follow these steps:
1. Use this command to create a subnet 
```
avalanche subnet create spoNet
```
'spoNet' is the name of our subnet. You can give it any name of your choosing. Follow the prompts that ensue carefully and supply the needed information to complete the installation process.

2. To deploy the subnet, use the following command
```
avalanche subnet deploy spoNet
```

3. Next step is to add the network manually to your wallet by inputing the RPC URL, Chain ID, name and symbol. When done successfully, your wallet is creditted with 1000000 native tokens of the network as airdrop.

We can then go ahead to deploy contracts on the network (spoNet or whatever you decide to call yours) and interact with these contracts on Remix.

## The Smart Contracts Deployed on the Subnet
For the purpose of this exercise, we shall deploy two contracts on spoNet and interact with them on Remix.

### DegenToken
This program is a simple contract written in Solidity, a programming language used for developing smart contracts on the Ethereum blockchain.
The contract inherits properties from ERC20, Ownable and ERC20Burnable. This inheritance is made possible by the following codes:
```
import "../ERC20.sol";
import "../Ownable.sol";
import "../ERC20Burnable.sol";
```

The contract has one constructor and one public variable in addition to other inherited variables as follows:
```
    constructor() ERC20("Degen", "DGN") {}

    mapping (address => uint) public _balances;
    
``` 

The contract has seven functions as follows 

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
        address store = 0x70997970C51812dc3A010C7d01b50e0d17dc79C8;
        require(balanceOf(msg.sender) >= value, "You do not have enough Degen Tokens");
        approve(msg.sender, value);
        transferFrom(msg.sender, store, value);
    }
```

#### Program Execution
To run the program, you can use Remix, an online Solidity IDE which can be accessed using via the website https://remix.ethereum.org/.

Once you are on the Remix website, create a new file by clicking on the '+' icon in the left-hand side bar. Save the file with a .sol extension (e.g., MyToken.sol). Copy and paste the following code into the file:

```
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "../ERC20.sol";
import "../Ownable.sol";
import "../ERC20Burnable.sol";
//import "hardhat/console.log";

contract DegenToken is ERC20, Ownable, ERC20Burnable {

    constructor() ERC20("Degen", "DGN") {}
    
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
        address store = 0x70997970C51812dc3A010C7d01b50e0d17dc79C8;
        require(balanceOf(msg.sender) >= value, "You do not have enough Degen Tokens");
        approve(msg.sender, value);
        transferFrom(msg.sender, store, value);
    }
}

```

#### Interacting with the Smart Contract Deployed on the Subnet
The first step is to go the 'Deploy & Run Transaction' section on Remix, under the 'Environment' tab, click and select 'Injected Provider'. Note that this will prompt you to connect your MetaMask wallet or any other wallet extension you have on your browser.

On connecting your wallet, check that the chain ID of your EVM Subnet which you added to your wallet manually is displayed at the 'Environment' tab.

Proceed to compile the code, by clicking on the "Solidity Compiler" tab in the left-hand sidebar. Make sure the "Compiler option is set to "0.8.9", and then click on the "Compile DegenToken.sol" button.

Once the code is compiled, you can deploy the contract by clicking on the "Deploy & Run Transactions" tab in the left-hand sidebar. Select the "DegenToken" contract from the dropdown menu, and then click on the "Deploy" button. Your wallet will prompt you to approve the transaction. This is so that the Contract will be deployed on the EVM Subnet created ('spoNet' in this exercise). You are to approve this transaction in order to proceed. In case you receive an error message, do well to clear the activities in your wallet and try again.

Once the contract is deployed, you can interact with it as follows

1. click on "totalSupply" to view the total supply of the coin

2. click on "tokenName" to view the name of the token i.e. "DegenToken"

3. click on "tokenSymbol" to view the token name abbreviation i.e. "DGN"

4. click on "mint" to mint new coins to any given address. You can copy an address from the "Account" tab above the "Deploy" button. This copied address can be used as argument to the mint function by pasting it at the address column, enter the amount of coins you wish to mint and hit the "transact" button to mint. You may click on the "totalSupply" button to check if the amount of coins minted is added to the total supply of the coin.

5. After minting the coins to the copied address, paste the same address into the "balances" column and click on the "balances" button to check the balance of that address.

6. click on "burnTokens" to burn coins from any given address. You can copy any address to which you have minted coins from the "Account" tab above the "Deploy" button. This copied address can be used as argument to the burnTokens function by pasting it at the address column, enter the amount of coins you wish to burn and hit the "transact" button. You may use the "balances" button to check if the balance of the address has reduced by the amount burned. Also click the "totalSupply" button to check if the total supply of the coin has reduced by the amount of coins burned.

7. click on "redeemTokens", input any number between 1, 2 and 3,  to redeem the corresponding item. You may use the "balances" button to check if the balance of the address has reduced by 50, 40 or 30 DGN tokens respectively. 

### ERC20
This program is a simple contract written in Solidity, a programming language used for developing smart contracts on the Ethereum blockchain.
The contract has six variables as follows
```
    uint public totalSupply;
    mapping(address => uint) public balanceOf;
    mapping(address => mapping(address => uint)) public allowance;
    string public name = "Solidity by Example";
    string public symbol = "SOLBYEX";
    uint8 public decimals = 18;

```
The contract has four functions as follows 
#### 1. transfer function
This function enables the user to transfer some tokens to another user 'recipient'.
```
    function transfer(address recipient, uint amount) external returns (bool) {
        balanceOf[msg.sender] -= amount;
        balanceOf[recipient] += amount;
        emit Transfer(msg.sender, recipient, amount);
        return true;
    }
```
#### 2. approve function
This function allows a certain amount of coins to be spent between the user and the spender.
```
    function approve(address spender, uint amount) external returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }
```
#### 3. mint function
This function allows any user to mint some amount of the coin. This increases the user balance and total supply by the amount minted simultaneously. 
```
    function mint(uint amount) external {
        balanceOf[msg.sender] += amount;
        totalSupply += amount;
        emit Transfer(address(0), msg.sender, amount);
    }
```
#### 4. burn function
This function allows any user to burn some amount of the coin i.e. to remove some coins out of circulation. This decreases the user balance and total supply by the amount burned simultaneously.
```
    function burn(uint amount) external {
        balanceOf[msg.sender] -= amount;
        totalSupply -= amount;
        emit Transfer(msg.sender, address(0), amount);
    }
```
The Program Execution and Interaction with the Deployed Contract are as described for the DegenToken.

## Authors
Nengak Emmanuel Goltong 

[@NengakGoltong](https://twitter.com/nengakgoltong) 
[@nengakgoltong](https://www.linkedin.com/in/nengak-goltong-81009b200)

## License
This project is licensed under the MIT License - see the LICENSE.md file for details