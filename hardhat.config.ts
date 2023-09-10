import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";

import "dotenv/config";

const SEPOLIA_RPC_URL = process.env.SEPOLIA_RPC_URL;

const BASE_GEROLI_RPC = process.env.BASE_GEROLI_RPC;

const PRIVATE_KEY = process.env.PRIVATE_KEY;

const ETH_MAINNET_RPC_URL = process.env.ETH_MAINNET_RPC_URL;

const ETHERSCAN_API_KEY = process.env.ETHERSCAN_API_KEY;

const GOERLI_RPC_URL = process.env.GOERLI_RPC_URL;

const config: HardhatUserConfig = {
  defaultNetwork: "hardhat",
  networks: {
    hardhat: {},

    sepolia: {
      url: SEPOLIA_RPC_URL,
      // @ts-ignore
      accounts: [PRIVATE_KEY],
      chainId: 11155111,
    },

    goerli: {
      url: GOERLI_RPC_URL,
      // @ts-ignore
      accounts: [PRIVATE_KEY],
      chainId: 5,
    },

    base: {
      url: BASE_GEROLI_RPC,
      // @ts-ignore
      accounts: [PRIVATE_KEY],
    },
    mainnet: {
      url: ETH_MAINNET_RPC_URL,
      // @ts-ignore
      accounts: [PRIVATE_KEY],
    },

    localhost: {
      url: "http://localhost:8545",
      chainId: 31337,
    },
  },
  solidity: "0.8.8",
  etherscan: {
    apiKey: ETHERSCAN_API_KEY,
  },
};

export default config;
