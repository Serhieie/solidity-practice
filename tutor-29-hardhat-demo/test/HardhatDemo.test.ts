import { loadFixture } from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { expect } from "chai";
import { ethers } from "hardhat";
import { HardhatDemo, HardhatDemo__factory } from "../typechain-types";

describe("HardhatDemo", function () {
  async function deploy() {
    const [deployer, user] = await ethers.getSigners();

    const HardhatDemoFactory = await ethers.getContractFactory("HardhatDemo");
    const demo: HardhatDemo = await HardhatDemoFactory.deploy();
    await demo.waitForDeployment();

    return { demo, user, deployer };
  }

  it("allows to call get()", async function () {
    const { demo } = await loadFixture(deploy);
    expect(await demo.get()).to.eq(111);
  });

  it("allows to call pay() & message", async function () {
    const { demo } = await loadFixture(deploy);
    const value = 10;
    const tx = await demo.pay("hi", { value: value });
    await tx.wait();
    expect(await demo.get()).to.eq(value);
    expect(await demo.message()).to.eq("hi");
  });

  it("allows to call callMe() from user address", async function () {
    const { demo, user } = await loadFixture(deploy);
    const targetAddress = await demo.getAddress();
    const demoAsUser = HardhatDemo__factory.connect(targetAddress, user);
    const tx = await demoAsUser.callMe();
    await tx.wait();
    expect(await demoAsUser.caller()).to.eq(user.address);
  });

  it("It revert call of callError() with panic", async function () {
    const { demo } = await loadFixture(deploy);
    await expect(demo.callError()).to.be.revertedWithPanic();
  });
});
