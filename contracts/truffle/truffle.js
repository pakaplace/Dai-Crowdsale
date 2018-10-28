const HDWalletProvider = require("truffle-hdwallet-provider");
const mnemonic = process.env.mnemonic;
const provider = "https://rinkeby.infura.io/"+process.env.infura;

module.exports = {
  // See <http://truffleframework.com/docs/advanced/configuration>
  // to customize your Truffle configuration!
  networks:{
    rinkeby: {
      provider: function() { 
        return new HDWalletProvider(mnemonic, provider) 
      },
      network_id: '4',
      gas: 4500000,
      gasPrice: 10000000000
    }
  }
};
