import { task } from "hardhat/config";

task("deploy:staking", "Deploy Staking contract").setAction(
    async function ({ _ }, { getNamedAccounts, deployments: { deploy } , ethers: { getContract } }) {
        const { deployer } = await getNamedAccounts();
        const ugvToken = await getContract("UGVToken");

        return await deploy("UGVStaking", {
            from: deployer,
            args: [ugvToken.address],
            log: true,
        });
    }
);