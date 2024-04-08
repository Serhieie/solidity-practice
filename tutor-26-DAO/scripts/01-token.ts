import { HardhatRuntimeEnvironment } from "hardhat/types";
import hre from "hardhat";

import "dotenv/config";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployments, getNameAccounts } = hre.;
  const { deploy } = deployments;
  const { deployer } = await getNameAccounts();

  await deploy("MyToken", { from: deployer, log: true });
};
