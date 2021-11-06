const Betting = artifacts.require('Betting');
module.exports = function (deployer) {
  deployer.deploy(Betting, [web3.utils.soliditySha3("team1"), web3.utils.soliditySha3("team2")]);
}