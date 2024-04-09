import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import { ethers, upgrades } from "hardhat";

describe("Ubgradable token", function () {
  async function deploy() {
    const [deployer] = await ethers.getSigners();
    const NFTFactory = await ethers.getContractFactory("NFT");
    const token = await upgrades.deployProxy(NFTFactory, [deployer.address], {
      initializer: "initialize",
      kind: "uups",
    });
    await token.waitForDeployment();

    return { token, deployer };
  }

  it("works", async function () {
    const { token, deployer } = await loadFixture(deploy);
    const mintTx = await token.safeMint(deployer.address, "12312ad");
    await mintTx.wait();

    expect(await token.balanceOf(deployer.address)).to.eq(1);

    const NFTFactoryV2 = await ethers.getContractFactory("NFTv2");
    const token2 = await upgrades.upgradeProxy(token.target, NFTFactoryV2);

    //address of token2 will be same with token
    expect(await token2.balanceOf(deployer.address)).to.eq(1);
    expect(await token2.demo()).to.eq("It's work");
  });
});
