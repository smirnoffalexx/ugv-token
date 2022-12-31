import { task } from "hardhat/config";

task("deploy:token", "Deploy UGV Token").setAction(
    async function ({ _ }, { getNamedAccounts, deployments: { deploy } }) {
        const { deployer } = await getNamedAccounts();

        return await deploy("UGVToken", {
            from: deployer,
            args: [],
            log: true,
        });
    }
);