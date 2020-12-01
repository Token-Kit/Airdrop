const connectionConfig = require('frg-ethereum-runners/config/network_config.json');
const HDWalletProvider = require('truffle-hdwallet-provider');

require('dotenv').config();

module.exports = {
  networks: {
    ganacheUnitTest: connectionConfig.ganacheUnitTest,
    gethUnitTest: connectionConfig.gethUnitTest,
    testrpcCoverage: connectionConfig.testrpcCoverage,
    ropsten: {
      provider: () => new HDWalletProvider(process.env.MNEMONIC, process.env.ROPSTEN_PROVIDER),
      network_id: 3,
      gas: 3000000,
      gasPrice: 10000000000
    },
    mainnet: {
      ref: 'mainnet-prod',
      network_id: 1,
      provider: () => new HDWalletProvider(process.env.MNEMONIC, process.env.MAINNET_PROVIDER),
      gas: 1217547,
      gasPrice: 118000000000
    }
  },
  mocha: {
    enableTimeouts: false,
    reporter: 'eth-gas-reporter',
    reporterOptions: {
      currency: 'USD'
    }
  },
  compilers: {
    solc: {
      version: '0.5.16'
    }
  }
};
