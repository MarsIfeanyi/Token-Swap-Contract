import { ethers, run, network } from "hardhat";
const { verify } = require("../../utils/verify");
import { TokenA_Address, TokenB_Address } from "../contractAddress/address";

async function main() {
  const tokensAddresses = [TokenA_Address, TokenB_Address];

  const tokenSwapContract = await ethers.deployContract(
    "TokenSwap",
    tokensAddresses
  );

  console.log("\n===========Deploying TokenSwapContract================");
  // @ts-ignore
  await tokenSwapContract.waitForDeployment(10);

  console.log(`tokenSwapContract deployed to: ${tokenSwapContract.target}`);

  // CONTRACT VERIFICATIONS

  if (
    network.config.chainId === 11155111 ||
    (5 && process.env.ETHERSCAN_API_KEY)
  ) {
    console.log("Waiting for block confirmations...");
    // @ts-ignore
    await tokenSwapContract.waitForDeployment(20);
    await verify(tokenSwapContract.target, [TokenA_Address, TokenB_Address]);
  }
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
