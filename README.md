# Token Swap Contract

## Description:

A smart contract that enables users to perform token swaps between tokenA and tokenB in both direction and uses the Constant Product Market Marker(CPMM), formula (X \* Y = K) to calculate the exchange rate for each swap.
It has functions that allows users to:

- AddLiquidity to the Pool, addLiquidity()
- RemoveLiquidity from the Pool, removeLiquidity()
- SwapTokens, swapTokens()
- Calculates the rate of TokenA For TokenB using the Constant Product Market Marker(CPMM), calculateRateOf_TokenA_For_TokenB()
- Calculates the rate of TokenB For TokenA using the Constant Product Market Marker(CPMM), calculateRateOf_TokenB_For_TokenA()
- Gets the Liquidity reserve of TokenA, getReserveA()
- Gets the Liquidity reserve of TokenB, getReserveB()
- Gets the reserve for each liquidity Provider using their address as key in the mapping, getLiquidityProvider()

Smart contract written in [Solidity](https://soliditylang.org/) and [Hardhat](https://hardhat.org/) for the contract development and [TypeScript](https://www.typescriptlang.org/) and [Ethersjs](https://docs.ethers.org/v6/) for the scripting and contract interactions.

- TokenAContractAddress:
  https://sepolia.etherscan.io/token/0x8646Ae354bAfd642d1269b132685f8e05bb3401e

- TokenBContractAddress:
  https://sepolia.etherscan.io/token/0xB6e41410b3A58062177547684073e19E8d5b5B74

- TokenSwapContractAddress:
  https://sepolia.etherscan.io/address/0x6a56F81D65f034957c9ccf86Cb74Fc7464dB47D4#code
