const { ethers } = require("hardhat");

module.exports = async ({ getNamedAccounts, deployments }) => {
  const { deployer } = await getNamedAccounts(); // remember to add namedAccounts to config
  const { deploy, log } = deployments;

  const farmtokens = await deploy("Farmtoken", {
    from: deployer,
    log: true,
  });
  const farmtoken = await ethers.getContract("Farmtoken", deployer);

  const staking = await deploy("Staking", {
    from: deployer,
    args: [farmtokens.address],
    log: true,
    waitConfirmations: 1,
  });

  log("Staking contract deployed to:", staking.address, "by", deployer);
  log("Tokencontract deployed to:", farmtokens.address, "by", deployer);

  await farmtoken.transfer(staking.address, "" + 100 * 10 ** 18);
};

module.exports.tags = ["Farmtoken", "Staking", "all"];
