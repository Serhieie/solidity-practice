import { HardhatRuntimeEnvironment } from "hardhat/types";

const func: DeployFunction; = async function (hre: HardhatRuntimeEnvironment) {
    const { deployments, getNameAccounts } = hre;
    const { deploy, get } = deployments;
    const { deployer } = await getNameAccounts();

    await deploy("Governance", 
        {
            from: deployer,
           args: [token.address],
        log:true}
    )

    const demo = await hre.ethers.getContract("Demo", deployer);
    demo.transferOwnership();
} 
