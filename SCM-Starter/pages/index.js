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

  const contractAddress = "0x5FbDB2315678afecb367f032d93F642f64180aa3";
  const atmABI = atm_abi.abi;

  // This function sets the user input to the amount variable
  function onChange () {
    setAmount(event.target.value);
  }

  // This function sets the user input as the number 
  // to be used for the calculations
  function changeNum () {
    setNum(event.target.value);
  }

  const getWallet = async() => {
    if (window.ethereum) {
      setEthWallet(window.ethereum);
    }

    if (ethWallet) {
      const account = await ethWallet.request({method: "eth_accounts"});
      handleAccount(account);
    }
  }

  const handleAccount = (account) => {
    if (account) {
      console.log ("Account connected: ", account);
      setAccount(account);
    }
    else {
      console.log("No account found");
    }
  }

  const connectAccount = async() => {
    if (!ethWallet) {
      alert('MetaMask wallet is required to connect');
      return;
    }
  
    const accounts = await ethWallet.request({ method: 'eth_requestAccounts' });
    handleAccount(accounts);
    
    // once wallet is set we can get a reference to our deployed contract
    getATMContract();
  };

  const getATMContract = () => {
    const provider = new ethers.providers.Web3Provider(ethWallet);
    const signer = provider.getSigner();
    const atmContract = new ethers.Contract(contractAddress, atmABI, signer);
 
    setATM(atmContract);
  }

  const getBalance = async() => {
    if (atm) {
      setBalance((await atm.getBalance()).toNumber());
    }
  }

  const getSquareOfNum = async() => {
    if (atm) {
      setSquare((await atm.getSquareOfNum()).toNumber());
    }
  }

  const getFactorialOfNum = async() => {
    if (atm) {
      setFactorial((await atm.getFactorialOfNum()).toNumber());
    }
  }

  const deposit = async() => {
    if (atm) {
      let tx = await atm.deposit(amount);
      await tx.wait()
      getBalance();
    }
  }

  const withdraw = async() => {
    if (atm) {
      let tx = await atm.withdraw(amount);
      await tx.wait()
      getBalance();
    }
  }

  const squareOfNum = async() => {
    if (atm) {
      let tx = await atm.squareOfNum(num);
      await tx.wait()
      getSquareOfNum();
      getBalance();
    }
  }

  const factorialOfNum = async() => {
    if (atm) {
      let tx = await atm.factorialOfNum(num);
      await tx.wait()
      getFactorialOfNum();
      getBalance();
    }
  }

  const initUser = () => {
    // Check to see if user has Metamask
    if (!ethWallet) {
      return <p>Please install Metamask in order to use this ATM.</p>
    }

    // Check to see if user is connected. If not, connect to their account
    if (!account) {
      return <button onClick={connectAccount}>Please connect your Metamask wallet</button>
    }

    if (balance == undefined) {
      getBalance();
    }

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
  }

  useEffect(() => {getWallet();}, []);

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
}
