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
  // const currentTimestampInSeconds = Math.round(Date.now() / 1000);
  // const ONE_YEAR_IN_SECS = 365 * 24 * 60 * 60;
  // const unlockTime = currentTimestampInSeconds + ONE_YEAR_IN_SECS;

  // const lockedAmount = ethers.utils.parseEther("1");

  // const Lock = await ethers.getContractFactory("Lock");
  // const lock = await Lock.deploy(unlockTime, { value: lockedAmount });

  // await lock.deployed();

  // console.log(`Lock with 1 ETH and unlock timestamp ${unlockTime} deployed to ${lock.address}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
