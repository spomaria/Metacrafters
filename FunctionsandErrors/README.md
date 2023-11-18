# LoanSystem
This solidity program is a simple exercise that sets up a basic system for loan request and disbursement. The purpose is to demonstrate the three error handling forms in Solidity. This is a required project to complete the course ETH + AVAX PROOF: Intermediate EVM Course at [@metacraftersio](https://twitter.com/metacraftersio)

## Description
This program is a simple contract written in Solidity, a programming language used for developing smart contracts on the Ethereum blockchain.
The contract has two private variables (i.e. mapping), one public variable (i.e. address) and seven functions. 

The three variables are given as

```
// This is a contract regarding the disbursement and repayment of loans
    // We then need to keep track of the debt acrued to those who received loans

    mapping(address => uint) private balances;
    mapping(address => uint) private debts;
    address public coopAccount;

```
Each of the seven functions accepts at least one parameter. 

The 'setCoopAccount' function sets the address of the Cooperative Account from which loans are disbursed and to which loan repayments are made. 

```
function setCoopAccount(address _coopAccount) public {
        coopAccount = _coopAccount;
    }
```
The 'deposit' function accepts two parameters. This function allows deposit of a given amount to be made into any given address.
```
function deposit(address _account, uint _number) public payable {
        balances[_account] += _number;
        
    }
```

The 'requestLoan' function allows one to request for loan by specifying their address and the amount to be disbursed. The function checks two conditions: i) if the Cooperative has up to the requested amount and ii) if the user is not owing the Cooperative any money. The function uses the 'require' and 'revert' methods of error handling to verify these conditions. Where these conditions are met, the user address is credited the requested amount, the users debt is increased by the amount disbursed and the Cooperative address is decreased by the same amount. 

If the user requests an amount greater than the balance on the Cooperative address, the transaction fails and "Insufficient Funds in the Treasury" is displayed on the screen. Also, where the user has outstanding debt to settle, the transaction fails and "You have unsettled debt. Request Declined!!" is displayed to the screen.
```
function requestLoan(address _account, uint _number) public payable {
        require(balances[coopAccount] >= _number, "Insufficient Funds in the Treasury");
        if(debts[_account] > 0){
            revert("You have unsettled debt. Request Declined!!");
        }
        balances[coopAccount] -= _number;
        balances[_account] += _number;
        debts[_account] += _number;
    }
```

The 'withdraw' function allows the user to withdraw some amount from an address provided that address holds at least the amount to be withdrawn. The function uses the 'assert' method of error handling to verify this condition. 
```
function withdraw(address _account, uint _number) public payable {
        assert(balances[_account] > 0);
        balances[_account] -= _number;
    }
```

The 'repayLoan' function allows the user to repay loan that was previously disbursed provided that the user address holds at least the amount to be repayed. The function uses the 'revert' method of error handling to verify this condition. Where the condition holds true, the Cooperative address is increased by the repayed amount, the user address is decreased by the repayed amount and the user debt is decreased by the same amount.

If the condition does not hold true, the transaction fails and the reason for failed transaction is displayed as "You do not have sufficient funds for this transaction".
```
function repayLoan(address _account, uint _number) public payable {
        if(balances[_account] >= _number){
            revert("You do not have sufficient funds for this transaction");
        }
        balances[_account] -= _number;
        debts[_account] -= _number;
        balances[coopAccount] += _number;
    }
```

The 'getBalance' function accepts address as argument and checks the balance of that address
```
function getBalance(address _address) public view returns(uint) {
        return balances[_address];
    }
```

The 'getDebt' function accepts address as argument and checks the debt (i.e. loan that is yet to be repayed) of that address
```
function getDebt(address _address) public view returns(uint) {
        return debts[_address];
    }
```

## Getting Started
### Program Execution
To run the program, you can use Remix, an online Solidity IDE which can be accessed using via the website https://remix.ethereum.org/.

Once you are on the Remix website, create a new file by clicking on the '+' icon in the left-hand side bar. Save the file with a .sol extension (e.g., MyToken.sol). Copy and paste the following code into the file:

```
//SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

contract LoanSystem {
    // This is a contract regarding the disbursement and repayment of loans
    // We then need to keep track of the debt acrued to those who received loans

    mapping(address => uint) private balances;
    mapping(address => uint) private debts;
    address public coopAccount;

    function setCoopAccount(address _coopAccount) public {
        coopAccount = _coopAccount;
    }

    function deposit(address _account, uint _number) public payable {
        balances[_account] += _number;
        
    }

    function requestLoan(address _account, uint _number) public payable {
        require(balances[coopAccount] >= _number, "Insufficient Funds in the Treasury");
        if(debts[_account] > 0){
            revert("You have unsettled debt. Request Declined!!");
        }
        balances[coopAccount] -= _number;
        balances[_account] += _number;
        debts[_account] += _number;
    }

    function withdraw(address _account, uint _number) public payable {
        assert(balances[_account] > 0);
        balances[_account] -= _number;
    }

    function repayLoan(address _account, uint _number) public payable {
        if(balances[_account] >= _number){
            revert("You do not have sufficient funds for this transaction");
        }
        balances[_account] -= _number;
        debts[_account] -= _number;
        balances[coopAccount] += _number;
    }

    function getBalance(address _address) public view returns(uint) {
        return balances[_address];
    }

    function getDebt(address _address) public view returns(uint) {
        return debts[_address];
    } 
}
```

To compile the code, click on the "Solidity Compiler" tab in the left-hand sidebar. Make sure the "Compiler option is set to "0.8.7", and then click on the "Compile SpoToken.sol" button.

Once the code is compiled, you can deploy the contract by clicking on the "Deploy & Run Transactions" tab in the left-hand sidebar. Select the "LoanSystem" contract from the dropdown menu, and then click on the "Deploy" button.

Once the contract is deployed, you can interact with it as follows

1. You can copy an address from the "Account" tab above the "Deploy" button. This copied address can be used as argument to the 'setCoopAccount' function by pasting it at the address column and hit the "transact" button to set the Cooperative address.

2. click on the arrow beside the "deposit" button, paste the copied address in the address column and enter any amount, say 100 in the _number column and click on 'transact'.

3. In the column beside the 'getBalance' button, paste the copied address and click on 'getBalance' to view the balance in the Cooperative account. This should equal the deposited amount.

4. You can copy another address, say the second address, from the "Account" tab above the "Deploy" button. This copied address can be used as argument to the 'requestLoan' function by pasting it at the address column, enter the required amount of loan and hit the "transact" button for your request to be processed.

5. In the column beside the 'getBalance' button, paste the copied address and click on 'getBalance' to view the balance in the user account. This should equal the requested amount.

6. In the column beside the 'getDebt' button, paste the copied address and click on 'getDebt' to view the debt in the user account. This should equal the requested amount that was disbursed.

7. Click the drop down arrow beside the 'withdraw' function, paste the copied address, enter the amount to be withdrawn and click on 'transact'. Check the balance of the user address and confirm that the balance has reduced by the withdrawn amount.

8. Click the drop down arrow beside the 'repayLoan' function, paste the copied address, enter the amount to be repayed and click on 'transact'. Check and confirm that the balance of the user address has reduced by the repayed amount, the debt of the user address has reduced by the repayed amount, and the balance of the Cooperative address has increased by the repayed amount.

## Authors
Nengak Emmanuel Goltong 

[@NengakGoltong](https://twitter.com/nengakgoltong) 
[@nengakgoltong](https://www.linkedin.com/in/nengak-goltong-81009b200)

## License
This project is licensed under the MIT License - see the LICENSE.md file for details
