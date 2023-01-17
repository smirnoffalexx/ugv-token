import { ethers } from "hardhat";

async function main() {
  const UGV = await ethers.getContractFactory("UGVToken");
  const ugv = await UGV.deploy();
  await ugv.deployed();
  console.log("UGV Token deployed to", ugv.address);

  const UGVStaking = await ethers.getContractFactory("UGVStaking");
  const ugvStaking = await UGVStaking.deploy(ugv.address);
  await ugvStaking.deployed();
  console.log("UGV Staking contract deployed to", ugvStaking.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
