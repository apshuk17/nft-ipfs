const { network, ethers } = require("hardhat");

const FUND_AMOUNT = "10000000000000000000";

let tokenUris = [
    "ipfs://QmaVkBn2tKmjbhphU7eyztbvSQU5EXDdqRyXZtRhSGgJGo",
    "ipfs://QmYQC5aGZu2PTH8XzbJrbDnvhj3gVs7ya33H9mqUNvST3d",
    "ipfs://QmZYmH5iDbD6v3U2ixoVAjioSzvWJszDzYdbeCLquGSpVm",
]

module.exports = async ({ getNamedAccounts, deployments }) => {
  const { deployer } = await getNamedAccounts();
  const { deploy, log } = deployments;

  const chainId = network.config.chainId;

  let vrfCoordinatorV2Address, subscriptionId;

  // If we are on testnet or mainnet, vrfCoordinatorV2Address exist
  //, however if we are on a local chain, it doen't
  if (chainId === 31337) {
    // create a fake VRF node
    const vrfCoordinatorV2Mock = await ethers.getContract(
      "VRFCoordinatorV2Mock"
    );
    vrfCoordinatorV2Address = vrfCoordinatorV2Mock.address;
    const tx = await vrfCoordinatorV2Mock.createSubscription();
    const txReceipt = await tx.wait(1);
    subscriptionId = txReceipt.events[0].args.subId;
    await vrfCoordinatorV2Mock.fundSubscription(subscriptionId, FUND_AMOUNT);
  } else {
    // use the real ones, here rinkeby VRF
    vrfCoordinatorV2Address = "0x6168499c0cFfCaCD319c818142124B7A15E857ab";
    subscriptionId = "3959";
  }

  args = [
    vrfCoordinatorV2Address,
    "0xd89b2bf150e3b9e13446986e571fb9cab24b13cea0a43ea20a6049a85cc807cc",
    subscriptionId,
    "500000",
    tokenUris
  ]

  const randomIpfsNFT = await deploy('RandomIpfsNFT', {
      from: deployer,
      log: true,
      args
  })
};
