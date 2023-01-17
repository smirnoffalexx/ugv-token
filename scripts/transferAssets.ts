import { ethers } from "hardhat";
import { readFileSync, readFile } from "fs";
import { BigNumber } from "ethers";
import abiJSON from './abi.json';

async function main() {
  const ugvAddress = "0x3D0293f06daF4311B482564330D57C8Db6C10893"; // paste UGV token address
  const erc20ABI = abiJSON.abi;
  const provider = ethers.getDefaultProvider("matic");
  const ugvContract = new ethers.Contract(ugvAddress, erc20ABI, provider);
  console.log("Network:", await provider.getNetwork());
  // const signer = new ethers.Wallet(process.env.PRIVATE_KEY!, provider);
  let holders: Array<string> = [];
  let amounts: Array<string> = [];
  let i = 0;
  let allFileContents = readFileSync("./balances.txt");
  allFileContents.toString().split(/\r?\n/).forEach(line => {
    [holders[i], amounts[i]] = line.split(": ", 2);
    console.log(`Holder: ${holders[i]} with balance ${amounts[i]}`);
    i++;
  });
//   let code
//   let addresses = ["0x3D0293f06daF4311B482564330D57C8Db6C10893", "0x01d50e3899A79791c2448B9f489ae0Be30Dbd345"];
//   let amounts = [100, 200];
//   code = await ethers.provider.getCode(holders[i]);
//   if (code === "0x") {
//     await ugvContract.transfer(holders[i], Number(amounts[i]) * 10);
//     console.log(`${amounts[i]} UGV transferred to ${holders[i]}`);
//   }
  for (let i = 0; i < holders.length; i++) {
    if (amounts[i] != "0") {
        await ugvContract.transfer(holders[i], Number(amounts[i]) * 10);
        console.log(`${amounts[i]} UGV transferred to ${holders[i]}`);
        await sleep(1000);
    }
  }

  console.log("Assets transferred");
}

function sleep(ms: number) {
  return new Promise( resolve => setTimeout(resolve, ms) );
}
    
// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});