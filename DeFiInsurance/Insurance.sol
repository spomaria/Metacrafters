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