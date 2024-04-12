import {
  loadFixture,
  ethers,
  expect,
  Signer,
  hre,
  time,
  BigNumberish,
} from './setup';

describe('Demo', function () {
  async function deploy() {
    const [superadmin, withdrawer, minter] = await ethers.getSigners();
    const Factory = await ethers.getContractFactory('Demo');
    const demo = await Factory.deploy(withdrawer.address, minter.address);
    await demo.waitForDeployment();

    return { superadmin, demo, withdrawer };
  }

  it('works', async function () {
    const { demo, withdrawer } = await loadFixture(deploy);
    const withdrawerRole = await demo.WITHDRAWER_ROLE();
    const defaultAdmin = await demo.WITHDRAWER_ROLE();
    expect(await demo.getRoleAdmin(withdrawerRole)).to.eq(defaultAdmin);

    await demo.connect(withdrawer).withdraw();

    await expect(demo.withdraw()).to.be.revertedWith('no such role');
  });
});
