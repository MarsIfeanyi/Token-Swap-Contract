import { ethers } from "hardhat";

import { TokenSwapAddress, ownerAddress } from "../contractAddress/address";
async function main() {
  const tokenSwapContract = await ethers.getContractAt(
    "ITokenSwap",
    TokenSwapAddress
  );

  const reserveTokenA = await tokenSwapContract.getReserveA();
  console.log({
    reserveTokenA: ethers.formatEther(reserveTokenA),
  });

  const reserveTokenB = await tokenSwapContract.getReserveB();
  console.log({
    reserveTokenB: ethers.formatEther(reserveTokenB),
  });

  const liquidityProvided = await tokenSwapContract.getLiquidityProvided(
    ownerAddress
  );
  console.log({
    liquidityProvided: liquidityProvided,
  });

  const reserveTokenATokenB =
    await tokenSwapContract.getReserveA_and_ReserveB();
  console.log({
    reserveTokenATokenB: reserveTokenATokenB,
  });

  const CPMM = await tokenSwapContract.getCPMM();
  console.log({
    CPMM: CPMM,
  });
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
