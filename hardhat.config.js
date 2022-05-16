require("@nomiclabs/hardhat-waffle");
require('hardhat-deploy');
require('dotenv').config();

const projectId = process.env.RINKEBY_PROJECT_ID.toString().trim();
const privateKey = process.env.PRIVATE_KEY.toString().trim();

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  solidity: "0.8.7",
  networks: {
    hardhat: {
      chainId: 31337
    },
    rinkeby: {
      url: `https://rinkeby.infura.io/v3/${projectId}`,
      accounts: [privateKey],
      chainId: 4
    }
  },
  namedAccounts: {
    deployer: {
      default: 0
    }
  }
};
