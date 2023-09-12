import { ethers, run, network } from "hardhat";
const { verify } = require("../utils/verify");

async function main() {
  const tokenBContract = await ethers.deployContract("TokenBContract");

  console.log("===========Deploying TokenBContract================");
  await tokenBContract.waitForDeployment();

  console.log(`tokenBContract deployed to: ${tokenBContract.target}`); // 0xB6e41410b3A58062177547684073e19E8d5b5B74;

  if (
    network.config.chainId === 11155111 ||
    (5 && process.env.ETHERSCAN_API_KEY)
  ) {
    console.log("Waiting for block confirmations...");

    //wait for 10 block confirmations before verifying the transaction
    // @ts-ignore
    await tokenBContract.waitForDeployment(10);
    await verify(tokenBContract.target, []);
  }
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
