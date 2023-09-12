import { ethers, network } from "hardhat";
import {
  TokenA_Address,
  TokenB_Address,
  TokenSwapAddress,
  ownerAddress,
} from "../contractAddress/address";

async function main() {
  // const [ownerSig] = await ethers.getSigners();

  const ownerSig = await ethers.getImpersonatedSigner(ownerAddress);

  // getting contracts
  const tokenSwapContract = await ethers.getContractAt(
    "ITokenSwap",
    TokenSwapAddress
  );
  const tokenAContract = await ethers.getContractAt("ITokenAB", TokenA_Address);
  const tokenBContract = await ethers.getContractAt("ITokenAB", TokenB_Address);

  // Balance Before Adding Liquidity
  console.log("\n============Balance Before Adding Liquidity================");
  const initialBalanceTokenA = await tokenAContract.balanceOf(ownerAddress);
  const initialBalanceTokenB = await tokenBContract.balanceOf(ownerAddress);

  console.log({
    InitialBalanceTokenA: ethers.formatEther(initialBalanceTokenA),
    InitialBalanceTokenB: ethers.formatEther(initialBalanceTokenB),
  });

  const amountTokenA = ethers.parseEther("20");
  const amountTokenB = ethers.parseEther("10");
  const allowanceAmount = ethers.parseEther("1000");

  // APPROVALS

  // await tokenAContract
  //   .connect(ownerSig)
  //   .approve(tokenSwapContract, allowanceAmount);
  // await tokenBContract
  //   .connect(ownerSig)
  //   .approve(tokenSwapContract, allowanceAmount);

  // Check allowances
  const allowanceA = await tokenAContract.allowance(
    ownerSig,
    tokenSwapContract
  );
  const allowanceB = await tokenBContract.allowance(
    ownerSig,
    tokenSwapContract
  );
  console.log({
    AllowanceOfTokenA: ethers.formatEther(allowanceA),
    AllowanceOfTokenB: ethers.formatEther(allowanceB),
  });

  // ADDING LIQUIDITY
  const txReceipt = tokenSwapContract
    .connect(ownerSig)
    .addLiquidity(amountTokenA, amountTokenB);
  (await txReceipt).wait();

  console.log("\n==============BALANCE AFTER ADDING LIQUIDITY=========");
  // Balance After Adding Liquidity
  const afterBalanceTokenA = await tokenAContract.balanceOf(ownerAddress);
  const afterBalanceTokenB = await tokenBContract.balanceOf(ownerAddress);
  const balanceOfTokenSwapAddressOnA = await tokenAContract.balanceOf(
    TokenSwapAddress
  ); // Balance of swap contract on tokenA
  const balanceOfTokenSwapAddressOnB = await tokenBContract.balanceOf(
    TokenSwapAddress
  ); // Balance of swap contract on tokenB

  console.log({
    AfterBalanceTokenA: ethers.formatEther(afterBalanceTokenA),
    AfterBalanceTokenB: ethers.formatEther(afterBalanceTokenB),

    BalanceOfSwapContractAddressOnTokenA: ethers.formatEther(
      balanceOfTokenSwapAddressOnA
    ),
    BalanceOfSwapContractAddressOnTokenB: ethers.formatEther(
      balanceOfTokenSwapAddressOnB
    ),
  });

  console.log("\n===========GETTING RESERVES OF LIQUIDITY POOL===========");
  const reserveA = await tokenSwapContract.getReserveA();
  const reserveB = await tokenSwapContract.getReserveB();
  const reserveAB = await tokenSwapContract.getReserveA_and_ReserveB();
  const CPMM = await tokenSwapContract.getCPMM();
  console.log({
    LiquidityPoolA: ethers.formatEther(reserveA),
    LiquidityPoolB: ethers.formatEther(reserveB),
    LiquidityPoolAB: reserveAB,
    ConstantProductMarketMarker: ethers.formatEther(CPMM),
  });
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
