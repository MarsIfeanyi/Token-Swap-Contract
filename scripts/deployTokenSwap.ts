import { ethers, run, network } from "hardhat";
const { verify } = require("../utils/verify");

async function main() {
  const tokensAddresses = [
    "0x8646ae354bafd642d1269b132685f8e05bb3401e",
    "0xB6e41410b3A58062177547684073e19E8d5b5B74",
  ];

  const tokenSwapContract = await ethers.deployContract(
    "TokenSwap",
    tokensAddresses
  );

  console.log("\n===========Deploying TokenSwapContract================");
  await tokenSwapContract.waitForDeployment();

  console.log(`tokenSwapContract deployed to: ${tokenSwapContract.target}`);
  if (
    network.config.chainId === 11155111 ||
    (5 && process.env.ETHERSCAN_API_KEY)
  ) {
    console.log("Waiting for block confirmations...");
    // @ts-ignore
    await tokenSwapContract.waitForDeployment(10);
    await verify(tokenSwapContract.target, [
      "0x8646ae354bafd642d1269b132685f8e05bb3401e",
      "0xB6e41410b3A58062177547684073e19E8d5b5B74",
    ]);
  }
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
