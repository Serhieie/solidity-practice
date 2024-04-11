import {
  loadFixture,
  ethers,
  expect,
  Signer,
  hre,
  time,
  BigNumberish,
} from './setup';

describe('DutchAuction', function () {
  async function deploy() {
    const [buyer, buyer2, owner] = await ethers.getSigners();
    const DutchAuctionFactory = await ethers.getContractFactory('DutchAuction');
    const auc = await DutchAuctionFactory.deploy(1000000, 1, 'item1');
    await auc.waitForDeployment();

    return { owner, buyer, buyer2, auc };
  }

  it('allows to buy', async function () {
    const { auc, buyer } = await loadFixture(deploy);

    await time.increase(60);

    //помітка часу останнього блоку
    const latest = await time.latest();
    const newLatest = latest + 1;
    await time.setNextBlockTimestamp(newLatest);

    //вирішення проблеми неспівпадіння часу блоків
    const startPrice = await auc.startingPrice();
    const startAt = await auc.startAt();
    const elapsed = BigInt(newLatest) - startAt;
    const discount = elapsed * (await auc.discountRate());
    const price = startPrice - discount;

    //якшо треба протестувати рефанд то просто можна додати будь яку сумму
    const buyTx = await auc.buy({ value: price + BigInt(100) });
    await buyTx.wait();

    expect(await ethers.provider.getBalance(auc.target)).to.eq(price);
    await expect(buyTx).to.changeEtherBalance(buyer, -price);
  });
});
