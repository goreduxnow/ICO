// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.

const hre = require("hardhat");
const { isCallTrace } = require("hardhat/internal/hardhat-network/stack-traces/message-trace");

async function main() {
  const Token = await ethers.getContractFactory("Redux");
  const token = await Token.deploy();

  await token.deployed();

  const PreSale = await ethers.getContractFactory("Presale");
  presale = await PreSale.deploy(token.address, [0, 1, 2, 3, 4, 5], [15, 15, 5, 100, 100, 5], [3, 3, 12, 12, 6, 12]);	
  await presale.deployed();

  console.log(
    `Token deployed to ${token.address}`
  );


  console.log(
    `ICO deployed to ${presale.address}`
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

// npx hardhat verify --network Mainnet 0xA8ce085C3523f932FACdDf3187852d989627A8D1 "SuperFoodz" "SF" 500000000 3141592653
// npx hardhat verify --network Mumbai 0xa5897874215Dd860a4c360571B04d2c7c4510E50 "0x679b5B1390F38E1E6709043370f45d27A2577Df4" "0xd0D5e3DB44DE05E9F294BB0a3bEEaF030DE24Ada"

// npx hardhat --network BSCTestnet run ./scripts/deploy.js
// npx hardhat --network BSCTestnet verify 0x272d5291F0a316221B0452020C92Bb68561B196a
// npx hardhat --network BSCTestnet verify 0x0f64cA33c23bA83Cfa629AC374dDc16f8138f24f --constructor-args scripts/arguments.js
