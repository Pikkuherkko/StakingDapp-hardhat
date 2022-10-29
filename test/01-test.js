const { expect } = require("chai");
const { deployments, ethers, getNamedAccounts } = require("hardhat");

describe("Staking", () => {
  let Staking;
  let Farmtoken;
  let deployer;
  beforeEach(async () => {
    deployer = (await getNamedAccounts()).deployer;
    await deployments.fixture(["all"]);
    Staking = await ethers.getContract("Staking", deployer);
    Farmtoken = await ethers.getContract("Farmtoken", deployer);
  });

  describe("balance", () => {
    it("has tokens", async () => {
      const balance = await Farmtoken.balanceOf(Staking.address);
      console.log(ethers.utils.formatEther(balance));
    });
  });
});

// to be continued
