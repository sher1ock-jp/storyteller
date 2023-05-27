import { ethers } from "hardhat";

const main = async () => {
const storyContractFactory = await ethers.getContractFactory("storyTeller");
const storyContract = await storyContractFactory.deploy();
const storyPortal = await storyContract.deployed();

console.log("StoryTeller address: ", storyPortal.address);
};

const runMain = async () => {
try {
await main();
process.exit(0);
} catch (error) {
console.log(error);
process.exit(1);
}
};

runMain();