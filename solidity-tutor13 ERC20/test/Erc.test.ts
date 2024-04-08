import { loadFixture, ethers, expect } from "./setup";
import tokenJSON from "../artifacts/contracts/Erc.sol/SGRToken.json";
// import { ERC20 } from "../contracts/ERC20.sol";
// import { BigNumber } from "ethers";

describe("TShop", () => {
  async function deploy() {
    const [owner, buyer] = await ethers.getSigners();
    const TShopFactory = await ethers.getContractFactory("TShop", owner);
    const shop = await TShopFactory.deploy();
    await shop.waitForDeployment();
    // const erc20 = new ethers.Contract(await shop.token(), tokenJSON.abi, owner);
    const erc20 = await ethers.getContractAt("IERC20", await shop.token());

    return { owner, buyer, shop, erc20 };
  }

  it("Should should have an owner and token", async () => {
    const { shop, owner } = await loadFixture(deploy);
    expect(await shop.owner()).to.eq(owner.address);
    expect(await shop.token()).to.be.properAddress;
  });

  it("Allow to buy", async () => {
    const tokenToBuyAmount = 100000;
    const { shop, buyer, erc20 } = await loadFixture(deploy);

    const txData = { value: tokenToBuyAmount, to: shop.getAddress() };
    const tx = await buyer.sendTransaction(txData);
    await tx.wait();
    expect(await erc20.balanceOf(buyer.address)).to.eq(tokenToBuyAmount);
    await expect(() => tx).to.changeEtherBalance(shop, tokenToBuyAmount);
    await expect(tx).to.emit(shop, "Bought").withArgs(tokenToBuyAmount, buyer.address);
  });

  it("Allows to sell", async () => {
    const { shop, buyer, erc20 } = await loadFixture(deploy);
    const tx = await buyer.sendTransaction({
      value: 100000,
      to: shop.getAddress(),
    });
    await tx.wait();

    const tokenToSellAmount = 50000;

    const approval = await erc20.connect(buyer).approve(shop.target, tokenToSellAmount);
    await approval.wait();
    const sellTx = await shop.connect(buyer).sell(tokenToSellAmount);

    expect(await erc20.balanceOf(buyer.address)).to.eq(50000);
    await expect(() => sellTx).to.changeEtherBalance(shop, -tokenToSellAmount);
    await expect(sellTx).to.emit(shop, "Sold").withArgs(tokenToSellAmount, buyer.address);
  });
});
