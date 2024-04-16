import 'dotenv/config';
import { HardhatUserConfig } from 'hardhat/config';
import '@nomicfoundation/hardhat-toolbox';
import '@openzeppelin/hardhat-upgrades';

const { ETHERSCAN_API_KEY, SEPOLIA_RPC_URL, PRIVATE_KEY } = process.env;

const config: HardhatUserConfig = {
  solidity: {
    version: '0.8.24',
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
  defender: {
    apiKey: process.env.DEFENDER_KEY as string,
    apiSecret: process.env.DEFENDER_SECRET as string,
  },
  etherscan: {
    apiKey: ETHERSCAN_API_KEY,
  },

  networks: {
    sepolia: {
      url: SEPOLIA_RPC_URL ? SEPOLIA_RPC_URL : '',
      accounts: PRIVATE_KEY ? [PRIVATE_KEY] : [],
      chainId: 11155111,
    },
    hardhat: {},
  },
  sourcify: {
    enabled: true,
  },
};

export default config;
