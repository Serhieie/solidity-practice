import { loadFixture } from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { expect } from "chai";
import { ethers } from "hardhat";

describe("HardhatDemo", function () {
  async function deploy() {
    const [deployer, user] = await ethers.getSigners();

    const HardhatDemoFactory = await ethers.getContractFactory("HardhatDemo");
    const demo = await HardhatDemoFactory.deploy();
    await demo.waitForDeployment();

    return { demo, user, deployer };
  }

  it("allows to call get()", async function () {
    const { demo, user } = await loadFixture(deploy);

    expect(await demo.get()).to.eq(111);
  });
});
