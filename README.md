# UGV Token Project

This project contains migration of YCO token from Ethererum mainnet to Polygon as UGV token with following features: staking and vesting. There are contracts, deploy scripts and migration scritps which get YCO holders, check their balances and transfer equivalent UGV value to holders in Polygon. 

The following commands are used while development and deployment:

```shell
yarn hardhat compile
yarn hardhat deploy --network polygon
yarn hardhat test
yarn hardhat run scripts/getBalances.ts
```
