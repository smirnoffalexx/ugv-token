import { ethers } from "hardhat";
import { readFileSync, readFile } from "fs";
import { BigNumber } from "ethers";
import abiJSON from './abi.json';

async function main() {
    const ugvAddress = "0x3D0293f06daF4311B482564330D57C8Db6C10893";
    const erc20ABI = abiJSON.abi;
    const provider = ethers.providers.getDefaultProvider("polygon");
    const ugvContract = new ethers.Contract(ugvAddress, erc20ABI, provider);
    // const signer = new ethers.Wallet(process.env.PRIVATE_KEY!, provider);
    let holders: Array<String> = [];
    let i = 0;
    let allFileContents = readFileSync("./holders.txt");
    allFileContents.toString().split(/\r?\n/).forEach(line =>  {
      holders[i] = line;
      console.log(`Line from file: ${line}`);
      i++;
    });
    let code
    let addresses = ["0x3D0293f06daF4311B482564330D57C8Db6C10893", "0x01d50e3899A79791c2448B9f489ae0Be30Dbd345"];
    let amounts = [100, 200];
    for (let i = 0; i < addresses.length; i++) {
        code = await ethers.provider.getCode(addresses[i]);
        if (code === "0x") {
            await ugvContract.transfer(addresses[i], amounts[i]);
            console.log(`${amounts[i]} UGV transferred to ${addresses[i]}`);
        }
        await sleep(1000);
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