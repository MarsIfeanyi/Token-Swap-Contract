import { ethers } from "hardhat";
import {
  TokenA_Address,
  TokenB_Address,
  TokenSwapAddress,
  ownerAddress,
} from "../contractAddress/address";

async function main() {
  const ownerSig = await ethers.getImpersonatedSigner(ownerAddress);

  // Getting Contract
  const tokenSwapContract = await ethers.getContractAt(
    "ITokenSwap",
    TokenSwapAddress
  );
  const tokenAContract = await ethers.getContractAt("ITokenAB", TokenA_Address);
  const tokenBContract = await ethers.getContractAt("ITokenAB", TokenB_Address);

  console.log(
    "=========BALANCE ON THE POOL BEFORE REMOVING LIQUIDITY==========="
  );
  // Balance Before Removing Liquidity

  const initialBalanceTokenA = await tokenAContract.balanceOf(TokenSwapAddress);
  const initialBalanceTokenB = await tokenBContract.balanceOf(TokenSwapAddress);
  console.log({
    "Initial Pool Balance Of TokenA": ethers.formatEther(initialBalanceTokenA),
    "Initial Pool Balance Of TokenB": ethers.formatEther(initialBalanceTokenB),
  });

  // Checking the Initial Reserves
  const initialReserveA = await tokenSwapContract.getReserveA();
  const initialReserveB = await tokenSwapContract.getReserveB();
  console.log({
    "Initial Pool Reserve of TokenA": ethers.formatEther(initialReserveA),
    "Initial Pool Reserve of TokenB": ethers.formatEther(initialReserveB),
  });

  const amountTokenA = ethers.parseEther("20");
  const amountTokenB = ethers.parseEther("10");

  const txReceipt = await tokenSwapContract
    .connect(ownerSig)
    .removeLiquidity(amountTokenA, amountTokenB);
  await txReceipt.wait();

  console.log(
    "=========BALANCE ON THE POOL AFTER REMOVING LIQUIDITY==========="
  );
  // Balance After Removing Liquidity

  const afterBalanceTokenA = await tokenAContract.balanceOf(TokenSwapAddress);
  const afterBalanceTokenB = await tokenBContract.balanceOf(TokenSwapAddress);
  console.log({
    "Initial Pool Balance Of TokenA": ethers.formatEther(afterBalanceTokenA),
    "Initial Pool Balance Of TokenB": ethers.formatEther(afterBalanceTokenB),
  });

  // Checking the After Reserves
  const afterReserveA = await tokenSwapContract.getReserveA();
  const afterReserveB = await tokenSwapContract.getReserveB();
  console.log({
    "After Pool Reserve of TokenA": ethers.formatEther(afterReserveA),
    "After Pool Reserve of TokenB": ethers.formatEther(afterReserveB),
  });
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
