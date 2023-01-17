import { ethers } from "hardhat";
import { readFileSync, readFile } from "fs";
import { BigNumber } from "ethers";
import abiJSON from './abi.json';
import { Console } from "console";

async function main() {
  const ycoAddress = "0x3D0293f06daF4311B482564330D57C8Db6C10893";
  const erc20ABI = abiJSON.abi;
  const provider = ethers.providers.getDefaultProvider("mainnet");
  const ycoContract = new ethers.Contract(ycoAddress, erc20ABI, provider);
  // const signer = new ethers.Wallet(process.env.PRIVATE_KEY!, provider);
  let holders: Array<string> = [];
  let i = 0;
  let allFileContents = readFileSync("./holders.txt");
  allFileContents.toString().split(/\r?\n/).forEach(line =>  {
    holders[i] = line;
    console.log(`Line from file: ${line}`);
    i++;
  });
  console.log("Balances:");
  let balances: Array<BigNumber> = [];
  let code;
  for (i = 0; i < holders.length; i++) {
    code = await ethers.provider.getCode(holders[i]);
    if (code == "0x") {
      balances[i] = await ycoContract.balanceOf(holders[i]);
      console.log(`Contract ${holders[i]}: ${balances[i]} YCO`);
      await sleep(3000);
    }
  }
  console.log("Balances requested");
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
