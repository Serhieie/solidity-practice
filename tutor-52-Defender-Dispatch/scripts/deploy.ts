import hre, { ethers } from 'hardhat';
import 'dotenv/config';
import type { MyToken } from '../typechain-types';
import { Defender } from '@openzeppelin/defender-sdk';

async function main() {
  // const tokenAddr = '0x3FEe25aD350Dd4E12C014c09E43E2faF75893E85';
  // const privateKey = process.env.PRIVATE_KEY;
  // if (!privateKey) {
  //   throw new Error('Private key is not provided');
  // }
  // // const wallet = new ethers.Wallet(privateKey, ethers.provider);
  // const owner = '0x046F99c7B5ab3bF7aF41063E64F679A40b2e4B08';
  // // const Factory = await ethers.getContractFactory('MyToken', wallet);
  // // const dep: MyToken = await Factory.deploy();
  // // await dep.waitForDeployment();
  // // const tokenA = await dep.getAddress();
  // // console.log(tokenA);
  // // await hre.run('verify:verify', {
  // //   address: tokenAddr,
  // //   // constructorArguments: [owner, owner, owner],
  // // });
  // const mtk: MyToken = await ethers.getContractAt('MyToken', tokenAddr);
  // // console.log(await mtk.hasRole(await mtk.DEFAULT_ADMIN_ROLE(), owner));
  // // console.log(await mtk.ownerOf(0));
  // // const relayerAddr = '0xC282693eB35452608bbFf5637cFdC1D47F0B4880';
  // const credentials = {
  //   apiKey: `${process.env.DEFENDER_KEY}`,
  //   apiSecret: `${process.env.DEFENDER_SECRET}`,
  //   relayerApiKey: `${process.env.RELAY_KEY}`,
  //   relayerApiSecret: `${process.env.RELAY_SECRET}`,
  // };
  // //send tranact
  // // const client = new Defender({
  // //   relayerApiKey: `${process.env.RILAY_KEY}`,
  // //   relayerApiSecret: `${process.env.RILAY_SECRET}`,
  // // });
  // // const tx = await client.relayerSigner.sendTransaction({
  // //   to,
  // //   value,
  // //   data,
  // //   gasLimit,
  // //   speed: 'fast',
  // // });
  // const client = new Defender(credentials);
  // const provider = client.relaySigner.getProvider();
  // console.log(provider);
  // // const erc20 = new ethers.Contract(ERC20_ADDRESS, ERC20_ABI, signer);
  // // const tx = await erc20.transfer(beneficiary, (1e18).toString());
  // // const mined = await tx.wait();
  // const relayAddr = '0xC282693eB35452608bbFf5637cFdC1D47F0B4880';
  // const minterRole = await mtk.MINTER_ROLE();
  // // // const pauserRole = await mtk.PAUSER_ROLE();
  // const txGrant = await mtk.grantRole(minterRole, relayAddr);
  // await txGrant.wait(1);
  // console.log(await mtk.connect(provider).hasRole(minterRole, relayAddr));
  // const revokeTx = await mtk.revokeRole(await mtk.PAUSER_ROLE(), relayAddr);
  // await revokeTx.wait(1);
}

main()
  .then(() => console.log('running'))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });

// RELAYER

// const { ethers } = require('ethers');
// const { DefenderRelaySigner, DefenderRelayProvider } = require('defender-relay-client/lib/ethers');

// const ABI = ["function safeMint(address to) public"];
// const TO = "0x719C2d2bcC155c85190f20E1Cc3710F90FAFDa16";
// const ADDRESS = "0x8cE6E5CBf50e058F94868f47d88fDE4aeEAC2d09";

// async function main(signer, to) {
//   const nft = new ethers.Contract(ADDRESS, ABI, signer);

//   const tx = await nft.safeMint(to);

//   console.log(tx.hash);
// }

// exports.handler = async function(params) {
//   const provider = new DefenderRelayProvider(params);
//   const signer = new DefenderRelaySigner(params, provider);

//   await main(signer, TO);
// }
