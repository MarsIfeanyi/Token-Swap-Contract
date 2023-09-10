import { ethers, run, network } from "hardhat";
const { verify } = require("../utils/verify");

async function main() {
  const tokenAContract = await ethers.deployContract("TokenAContract");

  console.log("=========Deploying TokenAContract================");

  // await tokenAContract.waitForDeployment();
  console.log(`tokenAContract deployed to: ${tokenAContract.target}`); // 0x4ad4a2a47fb6089D395bF5A4876972AE70bfC0d2

  // if (
  //   network.config.chainId === 11155111 ||
  //   (5 && process.env.ETHERSCAN_API_KEY)
  // ) {
  //   console.log("Waiting for block confirmations...");

  //   //wait for 6 block confirmations before verifying the transaction
  //   await tokenAContract.waitForDeployment();
  //   await verify(tokenAContract.target, []);
  // }
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
