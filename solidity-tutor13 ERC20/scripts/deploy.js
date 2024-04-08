const hre = require("hardhat");
const ethers = hre.ethers;

// npx hardhat run scripts/deploy.js --network localhost

async function main() {
  const [signer] = await ethers.getSigners();

  const Erc = await ethers.getContractFactory("TShop", signer);
  const erc = await Erc.deploy();
  await erc.waitForDeployment();

  console.log(await erc.target);
  console.log(await erc.token());
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
