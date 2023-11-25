# Smart Contract Management Project
This project consist of Solidity and JavaScript framework (i.e. React) files. The purpose is to demonstrate how to integrate a Smart Contract to the frontend of a Decentralized Application (Dapp). This is a required project to complete the Smart Contract Management section of ETH + AVAX PROOF: Intermediate EVM Course at [@metacraftersio](https://twitter.com/metacraftersio)

## Description
This program is a simple project that has a Smart Contract and frontend component. The Smart Contract is written in Solidity, a programming language used for developing smart contracts on the Ethereum blockchain while React was used to build the frontend.

### 1. The Frontend Component
The home page of the frontend application displays a welcome message and button to connect to a metamask wallet. This is made possible by the following lines of code:
```
return (
    <main className="container">
      <header><h1>Welcome to the Metacrafters ATM!</h1></header>
      {initUser()}
      <style jsx>{`
        .container {
          text-align: center
        }
      `}
      </style>
    </main>
  )
```
On clicking the 'please connect your metamask wallet' button, the user is prompted to download a wallet if non exists on the browser, or the user is prompted to input the password of the wallet to connect if a wallet exists on the brower. After the wallet connects successfully, the interface of the frontend shows the following

i. Wallet address, 

ii. account balance, 

iii. input box to type in the required amount

iv. a 'deposit' button to deposit the inputed amount into the owner's account

v. a 'withdraw' button to withdraw the inputed amount from the owner's account

vi. a message inviting the user to perform some math calculations

vii. input box to type in the desired number

viii. 'calculate the square ...' button to calculate the square of the inputed number

ix. 'calculate the factorial ...' button to calculate the factorial of the inputed number

x. a message showing where the square of the inputed number will be displayed

xi. a message showing where the factorial of the inputed number will be displayed

This interface is displayed by the following lines of code
```
return (
      <div>
        <p>Your Account: {account}</p>
        <p>Your Balance: {balance}</p>
        <label>Please input an amount: </label>
        <input type="number" value={amount} onChange={onChange} /> <br/> <br/>
        <button onClick={deposit}>Deposit {amount} ETH</button>
        <button onClick={withdraw}>Withdraw {amount} ETH</button>
        <br/> <br/> 
        <h2>You can do some maths here</h2>
        <label>Please input a number: </label>
        <input type="number" value={num} onChange={changeNum} /> <br/> <br/>
        <button onClick={squareOfNum}>Calculate the square of {num} </button>
        <button onClick={factorialOfNum}>Calculate the factorial of {num} </button>
        <h4> The Square of {num} is: {square}</h4>
        <h4> The Factorial of {num} is: {factorial}</h4>
      </div>
    )
```
To ensure that the frontend updates the user input at any given time, React hooks are used as follows
```
import {useState, useEffect} from "react";
import {ethers} from "ethers";
import atm_abi from "../artifacts/contracts/Assessment.sol/Assessment.json";

export default function HomePage() {
  const [ethWallet, setEthWallet] = useState(undefined);
  const [account, setAccount] = useState(undefined);
  const [atm, setATM] = useState(undefined);
  const [balance, setBalance] = useState(undefined);
  const [amount, setAmount] = useState(0);
  const [num, setNum] = useState(0);
  const [square, setSquare] = useState(0);
  const [factorial, setFactorial] = useState(1);

```

To deposit any amount into the owner account, the user inputs the desired number in the input box provided which is tracked by the frontend because of the 'onChange' property added to the 'input tag' and then clicks on the 'deposit' button calling the 'deposit' function made possible because of the 'onClick' property added to the button.
```
    <input type="number" value={amount} onChange={onChange} /> <br/> <br/>
    <button onClick={deposit}>Deposit {amount} ETH</button>
    <button onClick={withdraw}>Withdraw {amount} ETH</button>
    <br/> <br/> 
        
```
The 'deposit' function on the frontend sends a signal to the Smart Contract by calling on the 'deposit' function written in Solidity which accepts the argument passed to it and executes the operation. The Solidity function then sends back the account balance as requested. This balance is updated as a result of the React hook 'useState' explained earlier. All these occur because of the following lines of code 
```
const deposit = async() => {
    if (atm) {
      let tx = await atm.deposit(amount);
      await tx.wait()
      getBalance();
    }
  }
```

The withdraw function behaves in a similar manner which is made possible due to the following lines of code
```
const withdraw = async() => {
    if (atm) {
      let tx = await atm.withdraw(amount);
      await tx.wait()
      getBalance();
    }
  }
```

The 'squareOfNum' function on the frontend sends a signal to the Smart Contract by calling on the 'squareOfNum' function written in Solidity which accepts the argument passed to it and executes the operation. The Solidity function then sends back the square of the number inputed by the user and the account balance as requested. The account ballance is updated since 1 is deducted from the account ballance as fee for performing the calculation. All these occur because of the following lines of code
```
const squareOfNum = async() => {
    if (atm) {
      let tx = await atm.squareOfNum(num);
      await tx.wait()
      getSquareOfNum();
      getBalance();
    }
  }
```
Similar lines of codes perform the factorial calculation as follows
```
const factorialOfNum = async() => {
    if (atm) {
      let tx = await atm.factorialOfNum(num);
      await tx.wait()
      getFactorialOfNum();
      getBalance();
    }
  }
```

### 2. The Smart Contract Component
The Smart Contract is written in Solidity, a programming language used for developing smart contracts on the Ethereum blockchain. The contract has the following components
#### State Variables
There are four state variables; one is of type address while the remaining three are unsigned integers (i.e. non-negative integers). All variables are public
```
    address payable public owner;
    uint256 public balance;
    uint256 public square;
    uint256 public factorial = 1;
```

#### Events
The Smart Contract has three events which track deposits, withdrawals and payment of specified fees for performance of basic math calculations viz:
```
    event Deposit(uint256 amount);
    event Withdraw(uint256 amount);
    event PayFee();
``` 

#### Constructor
This function sets up the owner's account by accepting as input the initial balance for the account
```
    constructor(uint initBalance) payable {
        owner = payable(msg.sender);
        balance = initBalance;
    }
```

#### Functions
There are three getter functions to obtain the balance of the account, the square of a given number and the factorial of a given number. These functions are given as
```
    function getBalance() public view returns(uint256){
        return balance;
    }

    // This function allows the user to retrieve the square of a number
    function getSquareOfNum() public view returns(uint256){
        return square;
    }

    // This function allows the user to retrieve the factorial of a number
    function getFactorialOfNum() public view returns(uint256){
        return factorial;
    }
```
There are five other functions that perform tasks in this Smart Contract. These functions use the require, revert and assert methods of error handling to guard against erros as follows:
1. The 'deposit' function accepts the amount to deposit in the owner's account and increments the balance of owner's account by the same amount
```
    function deposit(uint256 _amount) public payable {
        uint _previousBalance = balance;

        // make sure this is the owner
        require(msg.sender == owner, "You are not the owner of this account");

        // perform transaction
        balance += _amount;

        // assert transaction completed successfully
        assert(balance == _previousBalance + _amount);

        // emit the event
        emit Deposit(_amount);
    }

```

2. The 'withdraw' function accepts the amount to withdraw from the owner's account and decrements the balance of owner's account by the same amount
```
    function withdraw(uint256 _withdrawAmount) public {
        require(msg.sender == owner, "You are not the owner of this account");
        uint _previousBalance = balance;
        if (balance < _withdrawAmount) {
            revert InsufficientBalance({
                balance: balance,
                withdrawAmount: _withdrawAmount
            });
        }

        // withdraw the given amount
        balance -= _withdrawAmount;

        // assert the balance is correct
        assert(balance == (_previousBalance - _withdrawAmount));

        // emit the event
        emit Withdraw(_withdrawAmount);
    }
```

3. The 'payFee' function decrements the owner's account by 1 as fees for calculating either the square or factorial of a given number
```
    function payFee() public {
        require(msg.sender == owner, "You are not the owner of this account");
        uint _previousBalance = balance;
        if (balance < 1) {
            revert ("Your balance must be greater or equal to 1 ETH");
        }

        // pay the required fee
        balance -= 1;

        // assert the balance is correct
        assert(balance == (_previousBalance - 1));

        // emit the event
        emit PayFee();
    }
```

4. The 'squareOfNum' function accepts a number as input and calculates the square of that number after charging a fee of 1 by calling the 'payFee' function.
```
    // This function allows the user to calculate the square of a number
    // After paying the required fee
    function squareOfNum(uint _num) public payable returns (uint){
        payFee();
        square= _num * _num;
        return square;
    }
```

5. The 'factorialOfNum' function accepts a number as input and calculates the factorial of that number after charging a fee of 1 by calling the 'payFee' function.
```
    // This function allows the user to calculate the factorial of a number
    // After paying the required fee
    function factorialOfNum(uint _num) public payable returns (uint){
        payFee();
        factorial = 1;
        for(uint i = 1; i <= _num; i++){
            factorial *= i;
        }
        return factorial;
    }
```

## Program Execution
After cloning the github, you will want to do the following to get the code running on your computer.

1. Inside the project directory, in the terminal type: `npm i`
2. Open two additional terminals in your VS code
3. In the second terminal type: `npx hardhat node`
4. In the third terminal, type: `npx hardhat run --network localhost scripts/deploy.js`
5. Back in the first terminal, type `npm run dev` to launch the front-end.

After this, the project will be running on your localhost. 
Typically at http://localhost:3000/

You will need to install a Metamask wallet and connect the wallet to the front end application in order to perform any further tasks.

### Deposit and Withdrawal
On the frontend in your local browser, input any given number, click the 'deposit' button and approve the transaction by clicking on the 'accept' button as prompted on the wallet extension on the brower to deposit the given amount into the owner's account. Observe that the account balance has increased by the deposited amount.

To withdraw any amount, input the required number in the input box provided and click on the 'withdraw' button to withdraw the given amount from the owner's account. Observe that the account balance has decreased by the withdrawn amount.

Note that you need to approve all transactions by clicking on the 'accept' button as prompted by the wallet before such transactions are executed.

### Basic Maths Calculation
To calculate the square of a given number, input the number in the input box provided, and click on the 'calculate the square ...' button and the result will be diplayed below the button. Notice that the account balance of owner will decrease by 1 because the transaction attracts a fee of 1 to be deducted from the owner's account.

To calculate the factorial of a given number, input the number in the input box provided, and click on the 'calculate the factorial ...' button and the result will be diplayed below the button. Notice that the account balance of owner will decrease by 1 because the transaction attracts a fee of 1 to be deducted from the owner's account.

## Authors
Nengak Emmanuel Goltong 

[@NengakGoltong](https://twitter.com/nengakgoltong) 
[@nengakgoltong](https://www.linkedin.com/in/nengak-goltong-81009b200)

## License
This project is licensed under the MIT License - see the LICENSE.md file for details