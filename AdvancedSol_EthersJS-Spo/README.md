# My First Dapp with Metacrafters
This is a simple exercise aimed at building Decentralized Application that spins up an ERC20 token. The Smart Contract is compiled using 'Remix-IDE' and deployed on the 'GoerliTestnet'. This is a required project to complete the 'Building Your First Dapp' section of ETH PROOF: Advance EVM Course at [@metacraftersio](https://twitter.com/metacraftersio)

## The Smart Contract

### Description
This program is a simple contract written in Solidity, a programming language used for developing smart contracts on the Ethereum blockchain. This inheritance is necessary to enable the spinning of ERC20 token upon deployment.
The contract inherits properties from ERC20, Ownable and ERC20Burnable. This inheritance is made possible by the following codes:
```
import "../node_modules/@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "../node_modules/@openzeppelin/contracts/access/Ownable.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
//import "hardhat/console.log";
```

The contract has several variables in addition to other inherited variables as follows:
```
    //The state variables of the Contract
    //Variable that stores the organisation name
    string public orgName;
    //Array that stores the different stakeholder types
    string [] public stakeholderTypes;
    //Variable indicating whether or not a stakeholder type is registered on the blockchain
    bool stakeholderTypeRegistered = false;
    
    //Array that stores the different vesting periods
    uint [] public vestingPeriods;
    //Variable that gives the vesting period for any given stakeholder type
    mapping (string => uint) public vestingPeriod;
    //Variable that gives the token amount allocated to a stakeholder type
    mapping (string => uint) public tokenAmount;
    //Array that stores all registered members
    Member[] public members;
    // Variable indicating whether or not a member is registered on the blockchain
    bool memberAlreadyRegistered = false;

    //Array that stores all addresses of registered members
    address [] public addrList;
    //Variable that links member address to vestingPeriod
    mapping (address => uint) public  addrVestingPeriod;
    //Variable that links member address to whitelistStatus
    mapping (address => bool) public  whitelistStatus;
    //Variable that links member address to stakeholderType
    mapping (address => string) public  addrStakeholderType;
    
    mapping (address => uint) public vestingStartTime;
    mapping (address => uint) public vestingStopTime;
    mapping (address => uint) private vestingDuration;

    //Variable that holds wallet address of admin
    address private adminAddress;
    

    
``` 

### Functions
The contract has several functions as follows 

#### 1. The Constructor function
The Smart Contract has one constructor function which accepts three (3) arguments namely: orgName_ (name of organisation); name_ (name of token); and symbol_ (symbol of token) in order to deploy the contract. The constructor function passes two arguments i.e name_ and symbol_ to the ERC20 constructor to create an ERC20 token upon deployment. 
The constructor function then updates the organisation's name with the name supplied and sets the address that deployed the contract as the admin for the Smart Contract.
```
    //The constructor function lets the an organisation be registered alongside its ERC20 Token
    constructor(
        string memory orgName_, string memory name_, string memory symbol_
    ) ERC20(name_, symbol_) {
        orgName = orgName_;
        //The address that registers the organisation should be the admin
        adminAddress = msg.sender;
    }
```

#### 2. The getOrgName function
```
    //This function reads the organisation name from the blockchain
    function getOrgName () public view returns (string memory) {
        return orgName;
    }
```
#### 3. setMembershipStatus function
This function receives three arguments, _stakeholderType, _vestingPeriod and _tokenAmount. A mechanism is put in place to ensure that the same stakeholder type is not entered more than once and only the admin can call this function. Once these conditions are met, the provided information is added to the Smart Contract.
```
    //This function allows the organisation to define stakeholder types and their vesting periods
    function setMembershipStatus(
        string memory _stakeholderType, uint _vestingPeriod, uint _tokenAmount
    ) public {
        //Check if the stakeholder type is registered already
        //This will prevent entering the smae stakeholder type multiple times
        for (uint i = 0; i < stakeholderTypes.length; i++){
                if (
                    keccak256(abi.encodePacked(_stakeholderType)) == 
                    keccak256(abi.encodePacked(stakeholderTypes[i]))
                ) {
                    stakeholderTypeRegistered = true;

                    break;
                }
            }
        
        if (stakeholderTypeRegistered){
            revert("This Stakeholder Type is already registered");
        }
        
        // Only the admin should set up stakeholderTypes
        require(msg.sender == adminAddress, "You are not allowed to carry out this operation");
        
        //Add the stakeholder type to the stakeholderType array
        stakeholderTypes.push(_stakeholderType);
        //Add the vesting period to the vestingPeriod array
        vestingPeriods.push(_vestingPeriod);
        //Map the current stakeholderType to the current vestingPeriod
        vestingPeriod[_stakeholderType] = _vestingPeriod;
        //Map the current stakeholderType to the current tokenAmount
        tokenAmount[_stakeholderType] = _tokenAmount;
    }
    
```

#### 4. isStakeholderTypeValid function
This function receives one argument and checks if the argument received is a valid stakeholder type as earlier defined by the admin. The function achieves this task by comparing the argument against elements of the stakeholderType array. For the purpose of gas optimization, the function only compares the argument with stakeholderType array elements whose length are the same. This reduces the number of iterations.
```
    //Function that checks if _stakeholderType is valid
    function isStakeholderTypeValid(string memory _stakeholderType) private view returns (bool isValid) {
        //initialize the return value as false
        isValid = false;
        //Check if the stakeholder type entered matches any of the earlier defined stakeholder types
        for (uint i = 0; i < stakeholderTypes.length; i++){
            //comparing strings directly in Solidity flags an error
            //Instead, we compare the hash of the strings using keccak256 hashing

            //In order to optimize gas, we restrict the operation to where the string lengths match
            require(bytes(_stakeholderType).length == bytes(stakeholderTypes[i]).length);
            if (
                keccak256(abi.encodePacked(_stakeholderType)) == keccak256(abi.encodePacked(stakeholderTypes[i]))
            ) {
                isValid = true;

                break;
            }
        }
        return isValid;  
    }

```

#### 5. registerMember function
This function receives as arguments, member information in order to register them on the Smart Contract. Mechanism is put in place to ensure that only the admin can call this function i.e. only the admin can register members. The function also checks if the _stakeholderType entered is valid, checks if the address is already registered to avoid registering the same person more than once. Where these conditions are met, the function registers the member by using the 'Member struct'.
The function then mints some tokens to the address and assigns a vesting period accordingly depending on the _stakeholderType provided. The address is 'whitelistStatus' of the address is set to 'false' to prevent the member from withdrawing unless whitelisted.
```
    function registerMember(
        address _memberAddr, string memory _stakeholderType
    ) public {
        // Only the admin should register members
        require(msg.sender == adminAddress, "You are not allowed to carry out this operation");
        
        //Ensure the stakeholder type entered is valid
        if (!isStakeholderTypeValid(_stakeholderType)){
            revert("Enter a valid Stakeholder Type");
        }
        
        //Check if the member with this address is registered already
        for (uint i = 0; i < addrList.length; i++){
                if (_memberAddr == addrList[i]) {
                    memberAlreadyRegistered = true;

                    break;
                }
            }
        
        if (memberAlreadyRegistered){
            revert("This address is already registered");
        }

        //Register the member using the provided information
        Member memory member = Member(
            {memberAddr: _memberAddr, stakeholderType: _stakeholderType, whitelisted: false}
        );
        //Assign a vestingPeriod for the address using the stakeholderType
        addrVestingPeriod[_memberAddr] = vestingPeriod[_stakeholderType];
        // Assign the stakeholderType to member address
        addrStakeholderType[_memberAddr] = _stakeholderType;
        //Assign a whitelistStatus of 'false' to the member
        whitelistStatus[_memberAddr] = false;
        //Mint some tokens to the member address using the 
        //tokenAmount specified for the member stakeholderType
        mint(_memberAddr, tokenAmount[_stakeholderType]);
        //Vesting period should start at the time the token is minted to the member address
        vestingStartTime[_memberAddr] = block.timestamp;
        //Vesting duration should is calculated based on _stakeholderType
        vestingDuration[_memberAddr] = 60 * 60 * 24 * 365 * vestingPeriod[_stakeholderType];
        //Vesting period stop time is start time plus duration
        vestingStopTime[_memberAddr] = vestingStartTime[_memberAddr] + vestingDuration[_memberAddr];
        //Add member to the members array
        members.push(member);
        //Add member address to the array of addresses registered
        addrList.push(_memberAddr);

        //Revert the bool variable to false
        
        memberAlreadyRegistered = false;
    }
```

#### 6. whitelistStakeholders function
This function receives _stakeholderType as argument, checks that the caller is the admin, checks if the argument is a valid stakeholder type, iterates over the array of registered addresses to check for those addresses whose stakeholder type matches the argument and changes their 'whitelistStatus' to 'true'.

```
    //This function enables the admin to whitelist a member's address
    function whitelistStakeholders(string memory _stakeholderType) public {
        // Only the admin should whitelist members
        require(msg.sender == adminAddress, "You are not allowed to carry out this operation");
        //Ensure the stakeholder type entered is valid
        if (!isStakeholderTypeValid(_stakeholderType)){
            revert("Enter a valid Stakeholder Type");
        }

        // Iterate over the addrList and check for addresses whose stakeholder type
        // matches with the provided string
        // and change whitelist status of all such addresses
        for (uint i = 0; i < addrList.length; i++) {
            if (
                keccak256(abi.encodePacked(addrStakeholderType[addrList[i]])) == 
                keccak256(abi.encodePacked(_stakeholderType))
            ){
                //Whitelist the member address
                whitelistStatus[addrList[i]] = true;
                //Change the whitelist status of the member
                members[i].whitelisted = true;
            }
        }

    }
```

#### 7.  transferTokens function
This function receives an address (_receiver) and amount (_value) as arguments. The function checks that for any member who is not the admin, the vesting period has elapsed and the 'whitelistStatus' is 'true'. The function then checks that no matter the caller, the address has sufficient balance to transfer. Where all these conditions hold true, the required permission is granted to the Smart Contract the tranfer the requested amount to the receiver on behalf of the caller.
```
    //This function enables a member to withdraw tokens by transfer
    function transferTokens(address _receiver, uint _value) external {
        //Only the Admin is able to withdraw tokens without being whitelisted
        //or having completed vesting period
        //All other members must satisfy these two conditions
        if (msg.sender != adminAddress) {
            //Ensure the member has completed vesting period
            if(block.timestamp < vestingStopTime[msg.sender]){
                revert("You can only withdraw after your Vesting Period");
            }
            //Ensure the member is whitelisted
            if (whitelistStatus[msg.sender] = false){
                revert("You are not allowed to withdraw tokens yet");
            }
        }
        require(balanceOf(msg.sender) >= _value, "You do not have sufficient balance to run transaction");
        approve(msg.sender, _value);
        transferFrom(msg.sender, _receiver, _value);
    }
```

### Compilation and Deployment
To run the program, you can use Remix, an online Solidity IDE which can be accessed using via the website https://remix.ethereum.org/.

Once you are on the Remix website, create a new file by clicking on the '+' icon in the left-hand side bar. Save the file with a .sol extension (e.g., MyDappToken.sol). Copy and paste the following code into the file:

```
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "../ERC20.sol";
import "../Ownable.sol";
import "../ERC20Burnable.sol";
//import "hardhat/console.log";


contract MyDappToken is ERC20, Ownable, ERC20Burnable {
    //The state variables of the Contract
    //Variable that stores the organisation name
    string public orgName;
    //Array that stores the different stakeholder types
    string [] public stakeholderTypes;
    //Variable indicating whether or not a stakeholder type is registered on the blockchain
    bool stakeholderTypeRegistered = false;
    
    //Array that stores the different vesting periods
    uint [] public vestingPeriods;
    //Variable that gives the vesting period for any given stakeholder type
    mapping (string => uint) public vestingPeriod;
    //Variable that gives the token amount allocated to a stakeholder type
    mapping (string => uint) public tokenAmount;
    //Array that stores all registered members
    Member[] public members;
    // Variable indicating whether or not a member is registered on the blockchain
    bool memberAlreadyRegistered = false;

    //Array that stores all addresses of registered members
    address [] public addrList;
    //Variable that links member address to vestingPeriod
    mapping (address => uint) public  addrVestingPeriod;
    //Variable that links member address to whitelistStatus
    mapping (address => bool) public  whitelistStatus;
    //Variable that links member address to stakeholderType
    mapping (address => string) public  addrStakeholderType;
    
    mapping (address => uint) public vestingStartTime;
    mapping (address => uint) public vestingStopTime;
    mapping (address => uint) private vestingDuration;

    //Variable that holds wallet address of admin
    address private adminAddress;
    

    //The constructor function lets the an organisation be registered alongside its ERC20 Token
    constructor(
        string memory orgName_, string memory name_, string memory symbol_
    ) ERC20(name_, symbol_) {
        orgName = orgName_;
        //The address that registers the organisation should be the admin
        adminAddress = msg.sender;
    }

    //This function reads the organisation name from the blockchain
    function getOrgName () public view returns (string memory) {
        return orgName;
    }

    //This function allows the organisation to define stakeholder types and their vesting periods
    function setMembershipStatus(
        string memory _stakeholderType, uint _vestingPeriod, uint _tokenAmount
    ) public {
        //Check if the stakeholder type is registered already
        //This will prevent entering the smae stakeholder type multiple times
        for (uint i = 0; i < stakeholderTypes.length; i++){
                if (
                    keccak256(abi.encodePacked(_stakeholderType)) == 
                    keccak256(abi.encodePacked(stakeholderTypes[i]))
                ) {
                    stakeholderTypeRegistered = true;

                    break;
                }
            }
        
        if (stakeholderTypeRegistered){
            revert("This Stakeholder Type is already registered");
        }
        
        // Only the admin should set up stakeholderTypes
        require(msg.sender == adminAddress, "You are not allowed to carry out this operation");
        
        //Add the stakeholder type to the stakeholderType array
        stakeholderTypes.push(_stakeholderType);
        //Add the vesting period to the vestingPeriod array
        vestingPeriods.push(_vestingPeriod);
        //Map the current stakeholderType to the current vestingPeriod
        vestingPeriod[_stakeholderType] = _vestingPeriod;
        //Map the current stakeholderType to the current tokenAmount
        tokenAmount[_stakeholderType] = _tokenAmount;
    }
    
    //This function displays the stakeholder types of the organisation
    function getStakeholderTypes() public view returns (string [] memory){
        return stakeholderTypes;
    }
    
    //This function displays the vesting periods of the organisation
    function getVestingPeriods() public view returns (uint [] memory){
        return vestingPeriods;
    }


    //Codes for registration of organisation's members 

    struct Member {
    //stakeholder type of the organisation's member
    string stakeholderType;
    //wallet address of the member
    address memberAddr;
    //status of the member, whether whitelisted or not
    bool whitelisted;

    }

    //Assign a decimal of zero to the ERC20 token
    function decimals() override  public pure returns (uint8){
        return 0;
    }

    //function that checks balance of msg.sender
    function getBalance() external view returns (uint256){
        return this.balanceOf(msg.sender);
    }

    //This function mints tokens to given address
    function mint(address to, uint256 amount) internal {
        _mint(to, amount);
    }


    
    //Function that checks if _stakeholderType is valid
    function isStakeholderTypeValid(string memory _stakeholderType) private view returns (bool isValid) {
        //initialize the return value as false
        isValid = false;
        //Check if the stakeholder type entered matches any of the earlier defined stakeholder types
        for (uint i = 0; i < stakeholderTypes.length; i++){
            //comparing strings directly in Solidity flags an error
            //Instead, we compare the hash of the strings using keccak256 hashing

            //In order to optimize gas, we restrict the operation to where the string lengths match
            require(bytes(_stakeholderType).length == bytes(stakeholderTypes[i]).length);
            if (
                keccak256(abi.encodePacked(_stakeholderType)) == keccak256(abi.encodePacked(stakeholderTypes[i]))
            ) {
                isValid = true;

                break;
            }
        }
        return isValid;  
    }

    function registerMember(
        address _memberAddr, string memory _stakeholderType
    ) public {
        // Only the admin should register members
        require(msg.sender == adminAddress, "You are not allowed to carry out this operation");
        
        //Ensure the stakeholder type entered is valid
        if (!isStakeholderTypeValid(_stakeholderType)){
            revert("Enter a valid Stakeholder Type");
        }
        
        //Check if the member with this address is registered already
        for (uint i = 0; i < addrList.length; i++){
                if (_memberAddr == addrList[i]) {
                    memberAlreadyRegistered = true;

                    break;
                }
            }
        
        if (memberAlreadyRegistered){
            revert("This address is already registered");
        }

        //Register the member using the provided information
        Member memory member = Member(
            {memberAddr: _memberAddr, stakeholderType: _stakeholderType, whitelisted: false}
        );
        //Assign a vestingPeriod for the address using the stakeholderType
        addrVestingPeriod[_memberAddr] = vestingPeriod[_stakeholderType];
        // Assign the stakeholderType to member address
        addrStakeholderType[_memberAddr] = _stakeholderType;
        //Assign a whitelistStatus of 'false' to the member
        whitelistStatus[_memberAddr] = false;
        //Mint some tokens to the member address using the 
        //tokenAmount specified for the member stakeholderType
        mint(_memberAddr, tokenAmount[_stakeholderType]);
        //Vesting period should start at the time the token is minted to the member address
        vestingStartTime[_memberAddr] = block.timestamp;
        //Vesting duration should is calculated based on _stakeholderType
        vestingDuration[_memberAddr] = 60 * 60 * 24 * 365 * vestingPeriod[_stakeholderType];
        //Vesting period stop time is start time plus duration
        vestingStopTime[_memberAddr] = vestingStartTime[_memberAddr] + vestingDuration[_memberAddr];
        //Add member to the members array
        members.push(member);
        //Add member address to the array of addresses registered
        addrList.push(_memberAddr);

        //Revert the bool variable to false
        
        memberAlreadyRegistered = false;
    }

    function getMember(
        uint _index
    )
        public
        view
        returns (address memberAddr, string memory stakeholderType, bool whitelisted)
    {
        Member storage member = members[_index];

        return (
            member.memberAddr, member.stakeholderType, 
            member.whitelisted
        );
    }

    //This function enables the admin to whitelist a member's address
    function whitelistStakeholders(string memory _stakeholderType) public {
        // Only the admin should whitelist members
        require(msg.sender == adminAddress, "You are not allowed to carry out this operation");
        //Ensure the stakeholder type entered is valid
        if (!isStakeholderTypeValid(_stakeholderType)){
            revert("Enter a valid Stakeholder Type");
        }

        // Iterate over the addrList and check for addresses whose stakeholder type
        // matches with the provided string
        // and change whitelist status of all such addresses
        for (uint i = 0; i < addrList.length; i++) {
            if (
                keccak256(abi.encodePacked(addrStakeholderType[addrList[i]])) == 
                keccak256(abi.encodePacked(_stakeholderType))
            ){
                //Whitelist the member address
                whitelistStatus[addrList[i]] = true;
                //Change the whitelist status of the member
                members[i].whitelisted = true;
            }
        }

    }

    //This function enables a member to withdraw tokens by transfer
    function transferTokens(address _receiver, uint _value) external {
        //Only the Admin is able to withdraw tokens without being whitelisted
        //or having completed vesting period
        //All other members must satisfy these two conditions
        if (msg.sender != adminAddress) {
            //Ensure the member has completed vesting period
            if(block.timestamp < vestingStopTime[msg.sender]){
                revert("You can only withdraw after your Vesting Period");
            }
            //Ensure the member is whitelisted
            if (whitelistStatus[msg.sender] = false){
                revert("You are not allowed to withdraw tokens yet");
            }
        }
        require(balanceOf(msg.sender) >= _value, "You do not have sufficient balance to run transaction");
        approve(msg.sender, _value);
        transferFrom(msg.sender, _receiver, _value);
    }

}

```
To compile the code, click on the "Solidity Compiler" tab in the left-hand sidebar. Make sure the "Compiler option is set to "0.8.9", and then click on the "Compile MyDappToken.sol" button.

Once the code is compiled, you can deploy the contract by selecting 'injected provider' and clicking on the "Deploy & Run Transactions" tab in the left-hand sidebar. Select the "MyDappToken" contract from the dropdown menu, fill the fields required by the 'constructor' and then click on the "Deploy" button.

Once the contract is deployed, you can interact with it using the buttons provided.

The address of the deployed contract can be found by clicking on 'view on etherscan' on the console at the bottom. 
The contract Application Binary Interface (ABI) can be found at the 'compile' page at the bottom. These can be copied and and pasted in the 'next.config.js' file in the project directory.



## The Front End

- Setup NextJS App
    
    Create a nextjs app with below command
    
    ```bash
    npx create-next-app <project-name>
    ```
    
    Add tailwind (to make it simpler to add styling for frontend elements)
    
    [https://tailwindcss.com/docs/guides/nextjs](https://tailwindcss.com/docs/guides/nextjs) (Step 2 and 3 from the link)

    Install @openzeppelin to ease the creation of the ERC20 token using the command
    ```
    npm install @openzeppelin/contracts
    ```


- Metamask and Network Setup
    
    Make sure you installed metamask or other wallet provider.
    
    Switch the network to GoerliTestNet
    
    Make sure to have some GoerliETH to test the app.

- Install required dependencies

    To start from scratch

    `npm install ethers axios web3modal @walletconnect/web3-provider`

    Update the code in `index.js` as per the requirement.

    
    To simulate the exisiting one:

    Clone the repo.

    Run `npm i` and `npm run dev`


- To connect your own contract

    Update the `/next.config.js` env variables `CONTRACT_ADDRESS` and `ABI`

### Setting up the Front End
In order to enable user interaction with the Smart Contract from the front end, the following changes are made to the 'index.js' file in the project directory.

#### 1. Importing Required Modules
All modules that are required to enable wallet integration and user interaction with the Smart Contract are imported as shown below:
```
// import required modules
// the essential modules to interact with frontend are below imported.
// ethers is the core module that makes RPC calls using any wallet provider like Metamask which is esssential to interact with Smart Contract
import { ethers } from "ethers";
// A single Web3 / Ethereum provider solution for all Wallets
import Web3Modal from "web3modal";
// yet another module used to provide rpc details by default from the wallet connected
import WalletConnectProvider from "@walletconnect/web3-provider";
// react hooks for setting and changing states of variables
import { useEffect, useState } from 'react';

```

#### 2. Setting the required variables
All the variables required to either store user input for parsing to the Smart Contract or variables that store data retrieved from the Smart Contract to be displayed on screen are defined here:
```
// env variables are initalised
  // contractAddress is deployed smart contract addressed 
  const contractAddress = process.env.CONTRACT_ADDRESS
  // application binary interface is something that defines structure of smart contract deployed.
  const abi = process.env.ABI

  // hooks for required variables
  const [provider, setProvider] = useState();
  
  // response from read operation is stored in the below variables
  // which will be used for the constructor function
  const [storedOrgName, setStoredOrgName] = useState("Organisation");
  
  
  // variables for saving stakeholder types into the smart contract
  const [enteredStakeholder, setEnteredStakeholder] = useState();
  const [enteredVestPeriod, setEnteredVestPeriod] = useState();
  const [enteredTokenAmount, setEnteredTokenAmount] = useState();

  // variables for registering a member into the smart contract
  const [enteredWalletAddress, setEnteredWalletAddress] = useState();
  const [enteredStakeholderType, setEnteredStakeholderType] = useState();

  // variable for whitelisting all members with a particular stakehoder type
  const [enteredClass, setEnteredClass] = useState();

  // variables for withdrawing tokens
  const [withdrawalAddress, setWithdrawalAddress] = useState();
  const [withdrawalAmount, setWithdrawalAmount] = useState();


  // the variable is used to invoke loader
  const [storeStakeholderLoader, setStoreStakeholderLoader] = useState(false);
  const [storeMemberLoader, setStoreMemberLoader] = useState(false);
  const [storeWhitelistedMembersLoader, setStoreWhitelistedMembersLoader] = useState(false);
  const [storeWithdrawalLoader, setStoreWithdrawalLoader] = useState(false);
  const [retrieveLoader, setRetrieveLoader] = useState(false);

```

#### 3. Wallet Integration
Wallet integration with the front end is achieved using this function
```
// This function integrates wallet connection to the front end
  async function initWallet(){
    try {
      // check if any wallet provider is installed. i.e metamask xdcpay etc
      if (typeof window.ethereum === 'undefined') {
        console.log("Please install wallet.")
        alert("Please install wallet.")
        return
      }
      else{
          // raise a request for the provider to connect the account to our website
          const web3ModalVar = new Web3Modal({
            cacheProvider: true,
            providerOptions: {
            walletconnect: {
              package: WalletConnectProvider,
            },
          },
        });
        
        const instanceVar = await web3ModalVar.connect();
        const providerVar = new ethers.providers.Web3Provider(instanceVar);
        setProvider(providerVar)
        readOrgName(providerVar)
        return
      }

    } catch (error) {
      console.log(error)
      return
    }
  }

```

#### 4. Other Functions
This function allows the user to write the various stakeholder types on the blockchain
```
// This function allows user to write stakeholder types to the smart contract
  // from the front end
  async function setStakeholderTypes(){
    try {
      setStoreStakeholderLoader(true)
      const signer = provider.getSigner();
      const smartContract = new ethers.Contract(contractAddress, abi, provider);
      const contractWithSigner = smartContract.connect(signer);

      // interact with the methods in smart contract as it's a write operation, we need to invoke the transation usinf .wait()
      const stakeholderType = await contractWithSigner.setMembershipStatus(
        enteredStakeholder, enteredVestPeriod, enteredTokenAmount
      );
      const response = await stakeholderType.wait()
      console.log(await response)
      setStoreStakeholderLoader(false)

      alert(`${enteredStakeholder} with vesting period of ${enteredVestPeriod} and token allocation of ${enteredTokenAmount} successfully registered`)   
      return

    } catch (error) {
      alert(error)
      setStoreStakeholderLoader(false)
      return
    }
  }

```

This function reads the organisation name from the blockchain just the way it was written to the blockchain at deployment
```
async function readOrgName(provider){
    try {
      setRetrieveLoader(true)
      const signer = provider.getSigner();
  
      // initalize smartcontract with the essentials detials.
      const smartContract = new ethers.Contract(contractAddress, abi, provider);
      const contractWithSigner = smartContract.connect(signer);
  
      // interact with the methods in smart contract
      const response = await contractWithSigner.getOrgName();
  
      console.log(response)
      setStoredOrgName(response)
      setRetrieveLoader(false)
      return
    } catch (error) {
      alert(error)
      setRetrieveLoader(false)
      return
    }
  }
```

This function enables the admin to register members on the blockchain
```
// This function allows the admin to register members to the smart contract
  // from the front end
  async function registerMember(){
    try {
      setStoreMemberLoader(true)
      const signer = provider.getSigner();
      const smartContract = new ethers.Contract(contractAddress, abi, provider);
      const contractWithSigner = smartContract.connect(signer);

      // interact with the methods in smart contract as it's a write operation, we need to invoke the transation usinf .wait()
      const regMember = await contractWithSigner.registerMember(
        enteredWalletAddress, enteredStakeholderType
      );
      const response = await regMember.wait()
      console.log(await response)
      setStoreMemberLoader(false)

      alert(`${enteredWalletAddress} registered as ${enteredStakeholderType} successfull`)   
      return

    } catch (error) {
      alert(error)
      setStoreMemberLoader(false)
      return
    }
  }

```

This function enables the admin to whitelist members of a certain class by inputing the stakeholder type desired.
```
// This function allows the admin to whitelist all members assigned a particular 
  // stakeholder type from the front end to enable them withdraw tokens on expiration of vesting period
  async function whitelistMembers(){
    try {
      setStoreWhitelistedMembersLoader(true)
      const signer = provider.getSigner();
      const smartContract = new ethers.Contract(contractAddress, abi, provider);
      const contractWithSigner = smartContract.connect(signer);

      // interact with the methods in smart contract as it's a write operation, we need to invoke the transation usinf .wait()
      const whitelistAll = await contractWithSigner.whitelistStakeholders(
        enteredClass
      );
      const response = await whitelistAll.wait()
      console.log(await response)
      setStoreWhitelistedMembersLoader(false)

      alert(`All ${enteredClass}s are whitelisted successfully and can withdraw tokens as and when due`)   
      return

    } catch (error) {
      alert(error)
      setStoreWhitelistedMembersLoader(false)
      return
    }
  }

```

The function below allows a member to withdraw tokens as and when due by entering the withdrawal address and withdrawal amount.
```
// This function allows a member to withdraw tokens as and when due
  // from the front end
  async function withdrawTokens(){
    try {
      setStoreWithdrawalLoader(true)
      const signer = provider.getSigner();
      const smartContract = new ethers.Contract(contractAddress, abi, provider);
      const contractWithSigner = smartContract.connect(signer);

      // interact with the methods in smart contract as it's a write operation, we need to invoke the transation usinf .wait()
      const withdrawal = await contractWithSigner.transferTokens(
        withdrawalAddress, withdrawalAmount
      );
      const response = await withdrawal.wait()
      console.log(await response)
      setStoreWithdrawalLoader(false)

      alert(`${withdrawalAmount} tokens withdrawn to ${withdrawalAddress} successfully`)   
      return

    } catch (error) {
      alert(error)
      setStoreWithdrawalLoader(false)
      return
    }
  }

```

#### 5. The User Interface
The user interface is made possible by the following lines of code:
```
return (
    <div className='flex-col p-24 m-6 space-y-4 content-center justify-around'>
      <h1 className="text-gray-700 text-3xl font-bold">
        Welcome to <span className='font-bold'>{storedOrgName ? storedOrgName : "Click the button to see Organisation Name"}</span> Dashboard.
      </h1>
      <h2>You can tokenise your organisational assets here.</h2>

      <button className='px-4 py-1 bg-slate-300 hover:bg-slate-500 flex justify-around transition-all w-32' onClick={()=>readOrgName(provider)}> { retrieveLoader ? (
                  <svg
                    className="animate-spin m-1 h-5 w-5 text-white"
                    xmlns="http://www.w3.org/2000/svg"
                    fill="none"
                    viewBox="0 0 24 24"
                  >
                    <circle
                      className="opacity-25"
                      cx="12"
                      cy="12"
                      r="10"
                      stroke="currentColor"
                      strokeWidth="4"
                    ></circle>
                    <path
                      className="opacity-75 text-gray-700"
                      fill="currentColor"
                      d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"
                    ></path>
                  </svg>
              ): "Organisation Name"} </button>
      
      <hr></hr>
      <hr></hr>

      <h3>Stakeholder Types of the Organisation can be written into the smart contract <br></br> 
      by filling the required fields below and clicking the button. </h3>
      <div>
        <input onChange={(e)=>{
          setEnteredStakeholder(e.target.value);
        }} className="placeholder:italic transition-all placeholder:text-gray-500 w-4/6 border border-gray-500 rounded-md p-2 shadow-sm focus:outline-none focus:border-sky-500 focus:ring-sky-500 focus:ring-1 sm:text-sm" placeholder="Enter Stakeholder Type" type="text" name="stakeholder"/>

      <input onChange={(e)=>{
                setEnteredVestPeriod(e.target.value);
              }} className="placeholder:italic transition-all placeholder:text-gray-500 w-4/6 border border-gray-500 rounded-md p-2 shadow-sm focus:outline-none focus:border-sky-500 focus:ring-sky-500 focus:ring-1 sm:text-sm" placeholder="Enter Vesting Period (in years) of Stakeholder Type" type="number" name="vestPeriod"/>

      <input onChange={(e)=>{
                setEnteredTokenAmount(e.target.value);
              }} className="placeholder:italic transition-all placeholder:text-gray-500 w-4/6 border border-gray-500 rounded-md p-2 shadow-sm focus:outline-none focus:border-sky-500 focus:ring-sky-500 focus:ring-1 sm:text-sm" placeholder="Enter Token Amount for Stakeholder Type" type="number" name="tokenAmount"/>
      </div>
      <button onClick={setStakeholderTypes} className='px-4 py-1 bg-slate-300 flex justify-around hover:bg-slate-500 transition-all w-32'> { storeStakeholderLoader ? (
                  <svg
                    className="animate-spin m-1 h-5 w-5 text-white"
                    xmlns="http://www.w3.org/2000/svg"
                    fill="none"
                    viewBox="0 0 24 24"
                  >
                    <circle
                      className="opacity-25"
                      cx="12"
                      cy="12"
                      r="10"
                      stroke="currentColor"
                      strokeWidth="4"
                    ></circle>
                    <path
                      className="opacity-75 text-gray-700"
                      fill="currentColor"
                      d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"
                    ></path>
                  </svg>
              ): "Save Stakeholder Type"} </button>
      
      <hr></hr>
      <hr></hr>

      <h3>You can now register a member into the smart contract. <br></br>
      Kindly ensure that stakeholder types are registered on the smart contract before registering a member. </h3>
      <div>
        <input onChange={(e)=>{
          setEnteredWalletAddress(e.target.value);
        }} className="placeholder:italic transition-all placeholder:text-gray-500 w-4/6 border border-gray-500 rounded-md p-2 shadow-sm focus:outline-none focus:border-sky-500 focus:ring-sky-500 focus:ring-1 sm:text-sm" placeholder="Enter wallet address of member" type="text" name="stakeholder"/>

        <input onChange={(e)=>{
          setEnteredStakeholderType(e.target.value);
        }} className="placeholder:italic transition-all placeholder:text-gray-500 w-4/6 border border-gray-500 rounded-md p-2 shadow-sm focus:outline-none focus:border-sky-500 focus:ring-sky-500 focus:ring-1 sm:text-sm" placeholder="Enter Stakeholder Type of member" type="text" name="vestPeriod"/>
      
      </div>
      <button onClick={registerMember} className='px-4 py-1 bg-slate-300 flex justify-around hover:bg-slate-500 transition-all w-32'> { storeMemberLoader ? (
                  <svg
                    className="animate-spin m-1 h-5 w-5 text-white"
                    xmlns="http://www.w3.org/2000/svg"
                    fill="none"
                    viewBox="0 0 24 24"
                  >
                    <circle
                      className="opacity-25"
                      cx="12"
                      cy="12"
                      r="10"
                      stroke="currentColor"
                      strokeWidth="4"
                    ></circle>
                    <path
                      className="opacity-75 text-gray-700"
                      fill="currentColor"
                      d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"
                    ></path>
                  </svg>
              ): "Register Member"} </button>

      <hr></hr>
      <hr></hr>

      <h3>You can now whitelist members of a particular stakeholder type. <br></br>
      This action will enable all members of that class withdraw their tokens on expiration of vesting period. </h3>
      <div>
        <input onChange={(e)=>{
          setEnteredClass(e.target.value);
        }} className="placeholder:italic transition-all placeholder:text-gray-500 w-4/6 border border-gray-500 rounded-md p-2 shadow-sm focus:outline-none focus:border-sky-500 focus:ring-sky-500 focus:ring-1 sm:text-sm" placeholder="Enter Stakeholder Type to whitelist" type="text" name="whitelistStakeholder"/>

      </div>
      <button onClick={whitelistMembers} className='px-4 py-1 bg-slate-300 flex justify-around hover:bg-slate-500 transition-all w-32'> { storeWhitelistedMembersLoader ? (
                  <svg
                    className="animate-spin m-1 h-5 w-5 text-white"
                    xmlns="http://www.w3.org/2000/svg"
                    fill="none"
                    viewBox="0 0 24 24"
                  >
                    <circle
                      className="opacity-25"
                      cx="12"
                      cy="12"
                      r="10"
                      stroke="currentColor"
                      strokeWidth="4"
                    ></circle>
                    <path
                      className="opacity-75 text-gray-700"
                      fill="currentColor"
                      d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"
                    ></path>
                  </svg>
              ): "Whitelist All"} </button>
        
      
      <hr></hr>
      <hr></hr>

      <h3>Members who are due for withdrawal can do so here. <br></br>
      To withdraw tokens, fill in the wallet address and token amount to be withdrawn. </h3>
      <div>
        <input onChange={(e)=>{
          setWithdrawalAddress(e.target.value);
        }} className="placeholder:italic transition-all placeholder:text-gray-500 w-4/6 border border-gray-500 rounded-md p-2 shadow-sm focus:outline-none focus:border-sky-500 focus:ring-sky-500 focus:ring-1 sm:text-sm" placeholder="Enter Withdrawal Address" type="text" name="withdrawAddress"/>

        <input onChange={(e)=>{
          setWithdrawalAmount(e.target.value);
        }} className="placeholder:italic transition-all placeholder:text-gray-500 w-4/6 border border-gray-500 rounded-md p-2 shadow-sm focus:outline-none focus:border-sky-500 focus:ring-sky-500 focus:ring-1 sm:text-sm" placeholder="Enter Withdrawal Amount" type="number" name="withdrawAmount"/>

        <h3 className="font-bold">Ensure you have entered the details correctly before clicking the 'withdraw' button <br></br> 
        Note that transactions are irreversible.
        </h3>
      </div>
      <button onClick={withdrawTokens} className='px-4 py-1 bg-slate-300 flex justify-around hover:bg-slate-500 transition-all w-32'> { storeWithdrawalLoader ? (
                  <svg
                    className="animate-spin m-1 h-5 w-5 text-white"
                    xmlns="http://www.w3.org/2000/svg"
                    fill="none"
                    viewBox="0 0 24 24"
                  >
                    <circle
                      className="opacity-25"
                      cx="12"
                      cy="12"
                      r="10"
                      stroke="currentColor"
                      strokeWidth="4"
                    ></circle>
                    <path
                      className="opacity-75 text-gray-700"
                      fill="currentColor"
                      d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"
                    ></path>
                  </svg>
              ): "Withdraw"} </button>
    </div>

    
  )
```

## Front End Interaction
In order to interact with the Smart Contract from the Front End, run the following command
```
npm run dev
```
which produces the following output or similar 
```
(node:24944) [DEP0040] DeprecationWarning: The `punycode` module is deprecated. Please use a userland alternative instead.
(Use `node --trace-deprecation ...` to show where the warning was created)
ready - started server on 0.0.0.0:3000, url: http://localhost:3000
```
Go ahead to click on 
```
http://localhost:3000
```
which opens the front end on your browser.

## Authors
Nengak Emmanuel Goltong 

[@NengakGoltong](https://twitter.com/nengakgoltong) 
[@nengakgoltong](https://www.linkedin.com/in/nengak-goltong-81009b200)


## License
This project is licensed under the MIT License - see the LICENSE.md file for details