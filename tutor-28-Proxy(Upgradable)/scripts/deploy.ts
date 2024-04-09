import { ethers, upgrades } from "hardhat";

async function main() {
  // Зчитуємо аккаунт для розгортання контракту
  const [deployer] = await ethers.getSigners();

  console.log("Deploying contracts with the account:", deployer.address);

  // Зчитуємо фабрику контракту
  const MyContract = await ethers.getContractFactory("MyContract");

  // Розгортаємо контракт Proxy
  console.log("Deploying Proxy contract...");
  const myContractProxy = await upgrades.deployProxy(
    MyContract,
    ["constructor arguments"],
    { initializer: "initialize" }
  );
  await myContractProxy.deployed();

  console.log("Proxy contract deployed to:", myContractProxy.address);
}

// Запускаємо основну функцію
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
