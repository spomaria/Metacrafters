// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "../node_modules/@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "../node_modules/@openzeppelin/contracts/access/Ownable.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
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

