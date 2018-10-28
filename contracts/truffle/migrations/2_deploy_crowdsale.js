var DaiCrowdsale = artifacts.require("./DaiCrowdsale.sol");
var TokenA = artifacts.require('./FixedSupplyToken.sol')
var TokenB = artifacts.require('./FixedSupplyToken.sol')

module.exports = function(deployer) {
    deployer.deploy(TokenA)
    .then(()=> deployer.deploy(TokenB))
    .then(()=> deployer.deploy(DaiCrowdsale, 1, process.env.PK, TokenA.address, TokenB.address ))
};
