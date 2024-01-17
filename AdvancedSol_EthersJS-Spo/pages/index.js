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
import { parseBytes32String } from "ethers/lib/utils";

export default function Home() {
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

  useEffect(() => {
    initWallet();
  }, [])
  

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
}
