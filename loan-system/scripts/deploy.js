// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");

async function main() { 
  const EventTest = await hre.ethers.getContractFactory("LoanSystem");
  const eventTest = await EventTest.deploy();

  await eventTest.deployed();

  eventTest.on("Deposit", (_account, amount) => {
    console.log(`New deposit: ${_account} ${amount} WEI`);
  })

  eventTest.on("DisburseLoan", (_coopAccount, _account, amount) => {
    console.log(`New Loan Disbursement: ${_coopAccount} ${_account} ${amount} WEI`);
  })

  eventTest.on("Withdraw", (_account, amount) => {
    console.log(`New withdrawal: ${_account} ${amount} WEI`);
  })

  eventTest.on("RepayLoan", (_account, _coopAccount, amount) => {
    console.log(`New Loan Repayment: ${_account} ${_coopAccount} ${amount} WEI`);
  })
  

  console.log(
    `Contract deployed to ${eventTest.address}`
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
