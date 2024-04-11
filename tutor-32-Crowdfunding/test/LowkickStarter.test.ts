import { loadFixture, ethers, expect, Signer, hre, time } from './setup';
import type { LowkickStarter } from '../typechain-types';
import { Campaign__factory } from '../typechain-types';

describe('LowkickStarter', function () {
  async function deploy() {
    const [owner, pladger] = await ethers.getSigners();
    const LowkickStarterFactory = await ethers.getContractFactory(
      'LowkickStarter',
      owner
    );
    const lowkick = await LowkickStarterFactory.deploy();
    await lowkick.waitForDeployment();

    return { owner, pladger, lowkick };
  }

  it('allows pladger to pladge and claim', async function () {
    const { owner, pladger, lowkick } = await loadFixture(deploy);
    const endsAt = Math.floor(Date.now() / 1000) + 30;
    const startTx = await lowkick.start(1000, endsAt);
    await startTx.wait();

    const campaignAddress = (await lowkick.campaigns(1)).targetContract;
    const campaignAsOwner = Campaign__factory.connect(campaignAddress, owner);
    expect(await campaignAsOwner.endsAt()).to.eq(endsAt);

    const campaignAsPledger = Campaign__factory.connect(
      campaignAddress,
      pladger
    );
    const pledgeTx = await campaignAsPledger.pledge({ value: 1500 });
    await pledgeTx.wait();

    await expect(campaignAsOwner.claim()).to.be.reverted;
    expect((await lowkick.campaigns(1)).claimed).to.be.false;
    await time.increase(40);

    await expect(() => campaignAsOwner.claim()).to.changeEtherBalances(
      [campaignAsOwner, owner],
      [-1500, 1500]
    );

    expect((await lowkick.campaigns(1)).claimed).to.be.true;
  });
});
