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


//Contract ID on Snowtrace is 0xd1044f51D77B5aE3203A08d371266F04E390a384