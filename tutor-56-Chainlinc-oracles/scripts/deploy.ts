import hre, { ethers } from 'hardhat';

async function main() {
  //   const Factory = await ethers.getContractFactory('Randomizer');
  //   const rand = await Factory.deploy(11060);
  //   await rand.waitForDeployment();

  //   console.log(rand.target);

  const randAddr = '0xBE89c90f32cC0D28A200d1b84120Fc8A3A425962';
  await hre.run('verify:verify', {
    address: randAddr,
    constructorArguments: [11060],
  });
}

main()
  .then(() => console.log('running'))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
