import { HardhatRuntimeEnvironment } from "hardhat/types";

const func: DeployFunction; = async function (hre: HardhatRuntimeEnvironment) {
    const { deployments, getNameAccounts } = hre;
    const { deploy } = deployments;
    const { deployer } = await getNameAccounts();

    await deploy("Demo", 
       { from: deployer,
        log:true}
    )
} 
