import { ethers } from "hardhat";
import {
  TokenA_Address,
  TokenB_Address,
  TokenSwapAddress,
  ownerAddress,
} from "../contractAddress/address";

async function main() {
  const ownerSig = await ethers.getImpersonatedSigner(ownerAddress);

  // getting contract
  const tokenSwapContract = await ethers.getContractAt(
    "ITokenSwap",
    TokenSwapAddress
  );
  const tokenAContract = await ethers.getContractAt("ITokenAB", TokenA_Address);
  const tokenBContract = await ethers.getContractAt("ITokenAB", TokenB_Address);

  // Balance Before TokenSwap
  const initialBalanceTokenA = await tokenAContract.balanceOf(ownerSig);
  const initialBalanceTokenB = await tokenBContract.balanceOf(ownerSig);
  console.log({
    initialBalanceTokenA: ethers.formatEther(initialBalanceTokenA),
    initialBalanceTokenB: ethers.formatEther(initialBalanceTokenB),
  });

  // Approval
  const allowanceAmount = ethers.parseEther("100000");

  // await tokenAContract
  //   .connect(ownerSig)
  //   .approve(tokenSwapContract, allowanceAmount);

  // await tokenBContract
  //   .connect(ownerSig)
  //   .approve(tokenSwapContract, allowanceAmount);

  const allowanceTokenA = await tokenAContract.allowance(
    ownerSig,
    tokenSwapContract
  );
  const allowanceTokenB = await tokenBContract.allowance(
    ownerSig,
    tokenSwapContract
  );

  console.log({
    allowanceTokenA: ethers.formatEther(allowanceTokenA),
    allowanceTokenB: ethers.formatEther(allowanceTokenB),
  });

  const amountTokenA = ethers.parseEther("2000");
  const amountTokenB = ethers.parseEther("1000");

  // tokenAddress and amount
  const swapTokenAForTokenB = await tokenSwapContract
    .connect(ownerSig)
    .swapToken(TokenA_Address, amountTokenA);
  await swapTokenAForTokenB.wait();

  const swapTokenBForTokenA = await tokenSwapContract
    .connect(ownerSig)
    .swapToken(TokenB_Address, amountTokenB);
  await swapTokenBForTokenA.wait();

  const afterBalanceTokenA = await tokenAContract.balanceOf(ownerSig);
  const afterBalanceTokenB = await tokenBContract.balanceOf(ownerSig);
  console.log({
    afterBalanceTokenA: ethers.formatEther(afterBalanceTokenA),
    afterBalanceTokenB: ethers.formatEther(afterBalanceTokenB),
  });
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
