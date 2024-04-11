import {
  loadFixture,
  ethers,
  expect,
  Signer,
  hre,
  time,
  BigNumberish,
} from './setup';
import { Sample } from '../typechain-types';

describe('Sample', function () {
  async function deploy() {
    const [owner] = await ethers.getSigners();
    const Factory = await ethers.getContractFactory('Sample');
    const sample: Sample = await Factory.deploy();
    await sample.waitForDeployment();

    return { owner, sample };
  }

  async function getAt(addr: string, slot: number | string | BigNumberish) {
    return await ethers.provider.getStorage(addr, slot);
  }

  it('checks state', async function () {
    const { sample } = await loadFixture(deploy);
    const pos = ethers.getBigInt(
      ethers.solidityPackedKeccak256(['uint256'], [0])
    );
    const nextPos = pos + BigInt(1);

    const mappingPos = ethers.getBigInt(
      ethers.solidityPackedKeccak256(['uint256', 'uint256'], [sample.target, 3])
    );

    const wrongMappingPos = ethers.getBigInt(
      ethers.solidityPackedKeccak256(['uint256', 'uint256'], [1122, 3])
    );

    const slots = [0, 1, 2, pos, nextPos, mappingPos, wrongMappingPos];

    const sampleAddress = await sample.getAddress();

    slots.forEach(async slot => {
      console.log(String(slot), '--->', await getAt(sampleAddress, slot));
    });
  });
});
