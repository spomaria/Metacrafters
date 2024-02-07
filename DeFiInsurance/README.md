# Factory Contract for DeFi Insurance
This solidity program is a simple exercise aimed at creating an Insurance Protocol for Decentralized Finance which will be deployed using Factory Contract. This is a required project to complete the DeFi Contracts part of ETH PROOF: Advanced EVM Course at [@metacraftersio](https://twitter.com/metacraftersio)

## Description
This program is a simple contract written in Solidity, a programming language used for developing smart contracts on the Ethereum blockchain.
The project consists of two major Smart Contracts, Insurance.sol and InsuranceFactory.sol (the factory contract).

### Insurance.sol
The contract has the following variables:

```
// This array stores all defined insurance types
    string[] insuranceTypes;

    // This array stores fees for all defined insurance types
    uint[] insuranceFees;

    // This variable maps the _insuranceType to the _amountPayable
    mapping (string => uint) public insuranceFee;

    // This variable maps the address to _insuranceType 
    mapping (address => string) public addressInsuranceType;

    // This variable maps the address to subscription status 
    mapping (address => bool) public addressSubscribed;

    // This variable maps the address to insurance start time
    mapping (address => uint) public insuranceStartTime;

    // This variable maps the address to insurance stop time
    mapping (address => uint) public insuranceStopTime;

    
    address public immutable insurerAddress;
```

#### 1. The constructor function
The Smart Contract has one constructor function which accepts three (3) arguments namely: _insurerAddress (address of wallet into which all subscription fees will be paid); _tokenName (name of token); and _symbol (symbol of token) in order to deploy the contract. The constructor function passes two arguments i.e _tokenName and _symbol to the ERC20 constructor to create an ERC20 token upon deployment. 
The constructor function then updates the 'insurerAddress' with the _insurerAddress supplied. The constructor function also sets up the three subscription types with their corresponding fees.
```
// The constructor function
    constructor (
        address _insurerAddress, string memory _tokenName, string memory _symbol
    ) ERC20(_tokenName, _symbol){
        // Set the address of the insurance entity
        insurerAddress = _insurerAddress;
        // Setting up the different insurance types with their fees
        insuranceFee["Basic"] = 100;
        insuranceFee["Silver"] = 200;
        insuranceFee["Gold"] = 500;
    }
```

#### 2. the getBalance function
This function gets the balance of the caller
```
    //function that checks balance of msg.sender
    function getBalance() external view returns (uint256){
        return this.balanceOf(msg.sender);
    }
```

#### 3. the getToken function
This function allows the user to mint some tokens into their address
```
    // Function allows user to mint some tokens
    function getTokens(uint _amount) public payable {
        _mint(msg.sender, _amount);
    }
```

#### 4. the subscribeForInsurance function
This function allows a user to subscribe for an insurance policy. The function performs some checks such as ensuring that the chosen policy is valid, that the user does not have a valid subscription running (this avoids multiple payments), that the user has the required balance to subscribe for the chosen insurance policy. Upon passing all checks, the smart contract is given permission to transfer funds on behalf of the user, the required fee is transfered from user balance to the 'insurerAddress', user status is updated to indicate subscribed and validity period is set as thirty (30) days.
```
    // Function that allows user to subscribe for _insuranceType of choice
    function subscribeForInsurance(
        string calldata _insuranceType
    )public payable {
        // Check that the _insuranceType is valid
        // if (!isInsuranceRegistered(_insuranceType)){
        //     revert("Input not Valid");
        // }
        // Check that the user does not have a valid subscription already
        if(isUserSubscribed()){
            revert("Already Subscribed");
        }

        // Check that the user has the required amount to pay for subscription
        require(
            balanceOf(msg.sender) >= insuranceFee[_insuranceType],
            "Insufficient Balance"
        );
        // Approve for smart contract to make payment on behalf of user
        approve(msg.sender, insuranceFee[_insuranceType]);

        // Transfer tokens from user balance to the insurerAddress
        transferFrom(msg.sender, insurerAddress, insuranceFee[_insuranceType]);

        // Affirm user subscription
        Subscriber memory subscriber = Subscriber(
            {subscriberAddress: msg.sender, insuranceType: _insuranceType, subscribed: true}
        );

        // Add details to the subscribers array
        subscribers.push(subscriber);
        // Change user subscription status accordingly
        userSubscribed[msg.sender].subscribed = true;
        addressSubscribed[msg.sender] = true;
        
        // Map subscription type to user address
        addressInsuranceType[msg.sender] = _insuranceType;
        
        // Set subscription start time of user address
        insuranceStartTime[msg.sender] = block.timestamp;

        // Set subscription end time of user address
        // Insurance expires after thirty days
        insuranceStopTime[msg.sender] = insuranceStartTime[msg.sender] + 60*60*24*30;
    }
```

#### 5. the endSubscription function
This function revokes user subscription on expiration. However, the function checks that the user is subscribed to an insurance policy and that the the subscription has expired. Where these conditions are met, the user subscription status is changed to 'false' and the subscription type is changed to null.
```
    // Function that revokes insurance on expiration
    function endSubscription() public {
        require(isUserSubscribed(), "No Subscription");
        if(block.timestamp < insuranceStopTime[msg.sender]) {
            revert("Subscription still Valid");
        } 
        // change subscription status to false
        userSubscribed[msg.sender].subscribed = false;
        addressSubscribed[msg.sender] = false;

        // change subscription type of user address to empty
        addressInsuranceType[msg.sender] = "";
        
    }
```

#### 6. the payCompensation function
This function allows the user to receive compensation in the event the token losses some value. The function checks that the caller has subscription, that the subscription is still valid i.e. has not expired, that the token has lost some value. Where these conditions are met, the Smart Contract is given approval to transfer the insuranceFee paid by the caller from the 'insurerAddress' to the caller address and the transfer is carried out accordingly.
```
    // This function pays the subscriber in the event the unforeseen occurs
    function payCompensation() public {
        // Check that the caller of the function has a valid subscription
        require(isUserSubscribed(), "No Subscription");
        if(block.timestamp > insuranceStopTime[msg.sender]) {
            revert("Subscription not Valid");
        }
        // Check that the caller suffered a hack or
        // Check that the coin lost its value
        require(valueLoss(), "Condition not Satisfied");
        // Check the amount the caller paid as fee and approve for the 
        // Smart contract to transfer the same amount from the insurerAddress
        // to the caller address
        _approve(insurerAddress, msg.sender, insuranceFee[addressInsuranceType[msg.sender]]);
        _transfer(insurerAddress, msg.sender, insuranceFee[addressInsuranceType[msg.sender]]);
        
    }
```


### InsuranceFactory.sol
The InsuranceFactory.sol is the factory contract that allows the deployment of several instances of the Insurance contract. Deployment of several instances of the Insurance contract is enabled firstly by importing the Insurance.sol contract into the factory contract. The factory contract has the following functions:

#### 1. the createInsurance function
This function accepts the three parameters needed for the constructor function of the Insurance.sol contract to be deployed, deploys an instance of the Insurance contract and adds the address of the deployed contract to the _insuranceList. 
```
    // An array that stores all instances of the Insurance contract deployed
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
```

#### 2. the getSomeTokens contract
The function accepts two arguments; the index of the deployed contract address in the _insuranceList array, and the amount of tokens to be minted. Once these arguments are provided, the amount of tokens are minted to the caller address.
```
    // This function allows user to mint some tokens for self
    function getSomeTokens(uint _index, uint _amount) public {
        _insuranceList[_index].getTokens(_amount);
    }
```

#### 3. the getBalance function
The function accepts the index of the deployed contract address in the _insuranceList array and returns the balance of the caller address.
```
    // Function that checks user balance
    function getBalance(uint _index) public view returns (uint){
        return _insuranceList[_index].getBalance();
    }
```

#### 4. the getSubscription function
The function accepts two arguments; the index of the deployed contract address in the _insuranceList array, and the insurance policy the caller wants to subscribe to. Once these arguments are provided, the necessary checks are carried out and the user is subscribed.
```
    // This function allows user to subscribe
    function getSubscription(uint _index, string memory _insuranceType) public {
        _insuranceList[_index].subscribeForInsurance(_insuranceType);
    }
```

#### 5. the claimCompensation function
The function accepts the index of the deployed contract address in the _insuranceList array. Once this argument is provided, the necessary checks are carried out and the user is compensated accordingly.
```
// This function allows user to claim compensation
    function claimCompensation(uint _index) public {
        _insuranceList[_index].payCompensation();
    }
```



## Getting Started
### Program Execution
To run the program, you can use Remix, an online Solidity IDE which can be accessed using via the website https://remix.ethereum.org/.

Once you are on the Remix website, create a new file by clicking on the '+' icon in the left-hand side bar. Save the file with a .sol extension (e.g., Insurance.sol). Copy and paste the following code into the file:
```
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./ERC20.sol";

contract Insurance is ERC20{
    // State variables


    // This array stores all defined insurance types
    string[] insuranceTypes;

    // This array stores fees for all defined insurance types
    uint[] insuranceFees;

    // This variable maps the _insuranceType to the _amountPayable
    mapping (string => uint) public insuranceFee;

    // This variable maps the address to _insuranceType 
    mapping (address => string) public addressInsuranceType;

    // This variable maps the address to subscription status 
    mapping (address => bool) public addressSubscribed;

    // This variable maps the address to insurance start time
    mapping (address => uint) public insuranceStartTime;

    // This variable maps the address to insurance stop time
    mapping (address => uint) public insuranceStopTime;

    
    address public immutable insurerAddress;


    // The constructor function
    constructor (
        address _insurerAddress, string memory _tokenName, string memory _symbol
    ) ERC20(_tokenName, _symbol){
        // Set the address of the insurance entity
        insurerAddress = _insurerAddress;
        // Setting up the different insurance types with their fees
        insuranceFee["Basic"] = 100;
        insuranceFee["Silver"] = 200;
        insuranceFee["Gold"] = 500;
    }

    
    // Function that checks the payable amount for any _insuranceType
    function getInsuranceFee(
        string calldata _insuranceType
    ) public view returns (uint){
        return insuranceFee[_insuranceType];
    }

    
    //Assign a decimal of zero to the ERC20 token
    function decimals() override  public pure returns (uint8){
        return 2;
    }

    //function that checks balance of msg.sender
    function getBalance() external view returns (uint256){
        return this.balanceOf(msg.sender);
    }

    // Function allows user to mint some tokens
    function getTokens(uint _amount) public payable {
        _mint(msg.sender, _amount);
    }
    
    // This struct describes the properties for any customer
    struct Subscriber{
        address subscriberAddress;
        string insuranceType;
        bool subscribed;
    }

    Subscriber[] public subscribers;
    mapping (address => Subscriber) public userSubscribed;

    // Function that checks if an _insuranceType is alreaday registered
    function isUserSubscribed() public view returns(bool subscribed){
        return userSubscribed[msg.sender].subscribed;

    }

    // Function that allows user to subscribe for _insuranceType of choice
    function subscribeForInsurance(
        string calldata _insuranceType
    )public payable {
        // Check that the _insuranceType is valid
        // if (!isInsuranceRegistered(_insuranceType)){
        //     revert("Input not Valid");
        // }
        // Check that the user does not have a valid subscription already
        if(isUserSubscribed()){
            revert("Already Subscribed");
        }

        // Check that the user has the required amount to pay for subscription
        require(
            balanceOf(msg.sender) >= insuranceFee[_insuranceType],
            "Insufficient Balance"
        );
        // Approve for smart contract to make payment on behalf of user
        approve(msg.sender, insuranceFee[_insuranceType]);

        // Transfer tokens from user balance to the insurerAddress
        transferFrom(msg.sender, insurerAddress, insuranceFee[_insuranceType]);

        // Affirm user subscription
        Subscriber memory subscriber = Subscriber(
            {subscriberAddress: msg.sender, insuranceType: _insuranceType, subscribed: true}
        );

        // Add details to the subscribers array
        subscribers.push(subscriber);
        // Change user subscription status accordingly
        userSubscribed[msg.sender].subscribed = true;
        addressSubscribed[msg.sender] = true;
        
        // Map subscription type to user address
        addressInsuranceType[msg.sender] = _insuranceType;
        
        // Set subscription start time of user address
        insuranceStartTime[msg.sender] = block.timestamp;

        // Set subscription end time of user address
        // Insurance expires after thirty days
        insuranceStopTime[msg.sender] = insuranceStartTime[msg.sender] + 60*60*24*30;
    }

    // This function checks the validity of user subscription
    function isSubscriptionValid() public view returns (bool){
        bool isValid = false;
        uint checkTime = block.timestamp;
        if (checkTime < insuranceStopTime[msg.sender]) isValid = true;
        return isValid;
    }

    // Function that revokes insurance on expiration
    function endSubscription() public {
        require(isUserSubscribed(), "No Subscription");
        if(block.timestamp < insuranceStopTime[msg.sender]) {
            revert("Subscription still Valid");
        } 
        // require(!isSubscriptionValid(), "Subscription time valid");
        // change subscription status to false
        userSubscribed[msg.sender].subscribed = false;
        addressSubscribed[msg.sender] = false;

        // change subscription type of user address to empty
        addressInsuranceType[msg.sender] = "";
        
    }

    function valueLoss() public pure returns (bool){
        return true;
    }

    // This function pays the subscriber in the event the unforeseen occurs
    function payCompensation() public {
        // Check that the caller of the function has a valid subscription
        if(block.timestamp > insuranceStopTime[msg.sender]) {
            revert("Subscription not Valid");
        }
        // Check that the caller suffered a hack or
        // Check that the coin lost its value
        require(valueLoss(), "Condition not Satisfied");
        // Check the amount the caller paid as fee and approve for the 
        // Smart contract to transfer the same amount from the insurerAddress
        // to the caller address
        _approve(insurerAddress, msg.sender, insuranceFee[addressInsuranceType[msg.sender]]);
        _transfer(insurerAddress, msg.sender, insuranceFee[addressInsuranceType[msg.sender]]);
        
    }
}
```

Open another file and save the file with a .sol extension (e.g., InsuranceFactory.sol). Copy and paste the following code into the file:

```
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
```

To compile the code, click on the "Solidity Compiler" tab in the left-hand sidebar. Make sure the "Compiler option is set to "0.8.9", and then click on the "Compile InsuranceFactory.sol" button.

Once the code is compiled, you can deploy the contract by clicking on the "Deploy & Run Transactions" tab in the left-hand sidebar. Select the "InsuranceFactory" contract from the dropdown menu, and then click on the "Deploy" button.

Once the contract is deployed, you can interact with it as follows

1. click on the arrow beside the "createInsurance" button, input the 'insurerAddress' (i.e. address where subscription fees are paid to), input 'name' (i.e. the name of the ERC20 token to spin up while deploying the Insurance contract), and input 'symbol' (i.e. the symbol of the ERC20 token). Now click on 'transact' to to deploy an instance of the Insurance contract. Note that to interact with the other functions, you are required to input a value for the '_index'. If only one instance of the contract was deployed, the value of _index to be used is 0. But if multiple instances were deployed, specify the _index of the specific instance you wish to interact with (start counting from 0 not 1).

2. click on "getSomeTokens" to mint some of the tokens to the user address. Note that you have to specify the amount of the token to mint.

3. click on "getSubscription" to subscribe to an Insurance policy. Note that you can only specify any of 'Basic', 'Silver' or 'Gold' as the insurance policy of choice.

4. click on "getCompensation" to claim compensation assuming the coin has lost some value.

5. click on "getBalance" to check user balance.

## Authors
Nengak Emmanuel Goltong 

[@NengakGoltong](https://twitter.com/nengakgoltong) 
[@nengakgoltong](https://www.linkedin.com/in/nengak-goltong-81009b200)

## License
This project is licensed under the MIT License - see the LICENSE.md file for details
