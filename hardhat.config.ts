import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "dotenv/config";
import "hardhat-deploy";
import "hardhat-contract-sizer";
import { task } from "hardhat/config";

const config: HardhatUserConfig = {
  defaultNetwork: "hardhat",
  solidity: {
    compilers: [
      {
        version: "0.8.20",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200
          },
          evmVersion: 'paris',
          viaIR: true
        }
      }
    ]
  },
  networks: {
    hardhat: {
      forking: {
        url: `https://arb-mainnet.g.alchemy.com/v2/${process.env.ALCHEMY_KEY_FORKING}`,
        blockNumber: 123724197,
      },
    },
    arbitrum: {
      url: `https://arb-mainnet.g.alchemy.com/v2/${process.env.ALCHEMY_API_KEY_ARBITRUM}`,
      accounts:
        process.env.DEPLOY_PRIVATE_KEY == undefined
          ? []
          : [`0x${process.env.DEPLOY_PRIVATE_KEY}`],
    },
    arbitrumgoerli: {
      url: `https://arb-goerli.g.alchemy.com/v2/${process.env.ALCHEMY_API_KEY_ARBITRUMGOERLI}`,
      chainId: 421613,
      accounts:
        process.env.DEPLOY_PRIVATE_KEY == undefined
          ? []
          : [`0x${process.env.DEPLOY_PRIVATE_KEY}`],
    },
    rinkeby: {
      url: "https://rinkeby.infura.io/v3",
      accounts:
        process.env.DEPLOY_PRIVATE_KEY == undefined
          ? []
          : [`0x${process.env.DEPLOY_PRIVATE_KEY}`],
    },
  },
  etherscan: {
    apiKey: {
      arbitrumOne: `${process.env.ETHERSCAN_API_KEY}`,
    },
    customChains: [
      {
        network: "arbitrumgoerli",
        chainId: 421613,
        urls: {
          apiURL: "https://api-goerli.arbiscan.io/api",
          browserURL: "https://goerli.arbiscan.io",
        },
      },
    ],
  },
};

export default config;
