import { ethers, run, network } from "hardhat";
const { verify } = require("../utils/verify");

async function main() {
  const tokenSwapContract = await ethers.deployContract("TokenSwap");

  console.log("\n===========Deploying TokenSwapContract================");
  await tokenSwapContract.waitForDeployment();

  console.log(`tokenSwapContract deployed to: ${tokenSwapContract.target}`); // 0xa153cc477c9cead51eff68fe612606b35f55f49d;

  if (
    network.config.chainId === 11155111 ||
    (5 && process.env.ETHERSCAN_API_KEY)
  ) {
    console.log("Waiting for block confirmations...");

    //wait for 6 block confirmations before verifying the transaction

    await tokenSwapContract.waitForDeployment();
    await verify(tokenSwapContract.target, []);
  }
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
