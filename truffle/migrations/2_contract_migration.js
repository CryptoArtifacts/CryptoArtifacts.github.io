var Contract = artifacts.require("CryptoArtifacts");

module.exports = function(deployer) {
  // deployment steps
  deployer.deploy(Contract);
};