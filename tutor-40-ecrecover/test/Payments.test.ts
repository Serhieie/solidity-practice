import {
  loadFixture,
  ethers,
  expect,
  Signer,
  hre,
  time,
  BigNumberish,
} from './setup';
import { Payments } from '../typechain-types';

describe('Payments', function () {
  async function deploy() {
    const [owner, receiver] = await ethers.getSigners();
    const PaymentsFactory = await ethers.getContractFactory('Payments');
    const payment: Payments = await PaymentsFactory.deploy({
      value: ethers.parseUnits('100', 'ether'),
    });
    await payment.waitForDeployment();

    return { owner, payment, receiver };
  }

  it('should allow to send and receive payments', async function () {
    const { owner, receiver, payment } = await loadFixture(deploy);
    const amount = ethers.parseUnits('100', 'ether');
    const nonce = 1;

    const hash = ethers.solidityPackedKeccak256(
      ['address', 'uint256', 'uint256', 'address'],
      [receiver.address, amount, nonce, payment.target]
    );

    // console.log(
    //   'hash -->',
    //   ethers.solidityPackedKeccak256(
    //     ['string', 'bytes32'],
    //     ['\x19Ethereum Signed Message:\n32', hash]
    //   )
    // );

    const messageHashBinary = ethers.toBeArray(hash);

    //signMessage добавляє '\x19Ethereum Signed Message:\n32'
    const signature = await owner.signMessage(messageHashBinary);
    const tx = await payment.connect(receiver).claim(amount, nonce, signature);
    await tx.wait();

    expect(tx).to.changeEtherBalance(receiver, amount);
  });
});
