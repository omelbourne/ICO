const { ethers } = require("hardhat");
require("dotenv").config({ path: ".env" });
const { ANTIPARALLEL_NFT_CONTRACT_ADDRESS } = require("../constants");

async function main() {
  // Address of the deployed NFT contract
  const antiparallelNFTContract = ANTIPARALLEL_NFT_CONTRACT_ADDRESS;

  /*
    A ContractFactory in ethers.js is an abstraction used to deploy new smart contracts,
    so antiparallelTokenContract here is a factory for instances of the token contract.
    */
  const antiparallelTokenContract = await ethers.getContractFactory(
    "AntiparallelToken"
  );

  // deploy the contract
  const deployedAntiparallelTokenContract = await antiparallelTokenContract.deploy(
    antiparallelNFTContract
  );

  // print the address of the deployed contract
  console.log(
    "Antiparallel Token Contract Address:",
    deployedAntiparallelTokenContract.address
  );
}

// Call the main function and catch if there is any error
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
