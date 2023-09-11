import { ethers, run, network } from "hardhat";
const { verify } = require("../utils/verify");

async function main() {
  const tokenAContract = await ethers.deployContract("TokenAContract");

  console.log("=========Deploying TokenAContract================");

  // await tokenAContract.waitForDeployment();
  console.log(`tokenAContract deployed to: ${tokenAContract.target}`); // 0x8646Ae354bAfd642d1269b132685f8e05bb3401e

  if (
    network.config.chainId === 11155111 ||
    (5 && process.env.ETHERSCAN_API_KEY)
  ) {
    console.log("Waiting for block confirmations...");

    //wait for 10 block confirmations before verifying the transaction
    // @ts-ignore
    await tokenAContract.waitForDeployment(10);
    await verify(tokenAContract.target, []);
  }
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
