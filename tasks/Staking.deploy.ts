import { task } from "hardhat/config";

task("deploy:staking", "Deploy Staking contract").setAction(
    async function ({ _ }, { getNamedAccounts, deployments: { deploy } }) {
        const { deployer } = await getNamedAccounts();

        return await deploy("UGVStaking", {
            from: deployer,
            args: [],
            log: true,
        });
    }
);