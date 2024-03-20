require("@nomiclabs/hardhat-waffle");
require("hardhat-typechain");

require("hardhat-circom");

require("dotenv").config();

const SEPOLIA_RPC_URL = process.env.SEPOLIA_RPC_URL || "";
const PRIVATE_KEY = process.env.PRIVATE_KEY || "";
const ETHERSCAN_API_KEY = process.env.ETHERSCAN_API_KEY || "";

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  defaultNetwork: "hardhat",
  paths: {
    artifacts: "./src/artifacts",
  },
  solidity: "0.6.11",
  networks: {
    hardhat: {
      chainId: 1337,
    },
    sepolia: {
      url: SEPOLIA_RPC_URL,
      accounts: [PRIVATE_KEY],
      chainId: 11155111,
      blockConfirmations: 6,
    },
    // goerli: {
    //   url: "https://goerli.infura.io/v3/"+process.env.GOERLI_PROJECTID,
    //   accounts: [process.env.a2key]
    // },

    // ropsten: {
    //   url: "https://ropsten.infura.io/v3/projectid",
    //   accounts: [process.env.a2key]
    // },
    // rinkeby: {
    //   url: "https://rinkeby.infura.io/v3/projectid",
    //   accounts: [process.env.a2key]
    // }
  },
  circom: {
    // (optional) Base path for input files, defaults to `./circuits/`
    inputBasePath: "./zk",
    // (required) The final ptau file, relative to inputBasePath, from a Phase 1 ceremony
    ptau: "./ptau/pot12_final.ptau",
    // (required) Each object in this array refers to a separate circuit
    circuits: [{ name: "circuit" }],
  },
};

// require("@nomiclabs/hardhat-waffle")
// require("hardhat-gas-reporter")
// require("@nomiclabs/hardhat-etherscan")
// require("dotenv").config()
// require("solidity-coverage")
// require("hardhat-deploy")
// // You need to export an object to set up your config
// // Go to https://hardhat.org/config/ to learn more
// /**
//  * @type import('hardhat/config').HardhatUserConfig
//  */

// const COINMARKETCAP_API_KEY = process.env.COINMARKETCAP_API_KEY || ""
// const SEPOLIA_RPC_URL =
//     process.env.SEPOLIA_RPC_URL || "https://eth-sepolia.g.alchemy.com/v2/YOUR-API-KEY"
// const PRIVATE_KEY = process.env.PRIVATE_KEY || ""
// const ETHERSCAN_API_KEY = process.env.ETHERSCAN_API_KEY || ""

// module.exports = {
//     defaultNetwork: "hardhat",
//     networks: {
//         hardhat: {
//             chainId: 31337,
//             // gasPrice: 130000000000,
//         },
//         sepolia: {
//             url: SEPOLIA_RPC_URL,
//             accounts: [PRIVATE_KEY],
//             chainId: 11155111,
//             blockConfirmations: 6,
//         },
//         mainnet: {
//             url: process.env.MAINNET_RPC_URL,
//             accounts: [PRIVATE_KEY],
//             chainId: 1,
//             blockConfirmations: 6,
//         },
//     },
//     solidity: {
//         compilers: [
//             {
//                 version: "0.8.8",
//             },
//             {
//                 version: "0.6.6",
//             },
//         ],
//     },
//     etherscan: {
//         apiKey: ETHERSCAN_API_KEY,
//     },
//     gasReporter: {
//         enabled: true,
//         currency: "USD",
//         outputFile: "gas-report.txt",
//         noColors: true,
//         // coinmarketcap: COINMARKETCAP_API_KEY,
//     },
//     namedAccounts: {
//         deployer: {
//             default: 0, // here this will by default take the first account as deployer
//             1: 0, // similarly on mainnet it will take the first account as deployer. Note though that depending on how hardhat network are configured, the account 0 on one network can be different than on another
//         },
//     },
//     mocha: {
//         timeout: 200000, // 200 seconds max for running tests
//     },
// }
