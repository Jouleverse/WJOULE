const WJ = artifacts.require("WJ");
const WJFuzzing = artifacts.require("fuzzing/WJFuzzing");
const TestFlashMinter = artifacts.require("tests/TestFlashLender");
const TestTransferReceiver = artifacts.require("tests/TestTransferReceiver");

module.exports = function(deployer, network, accounts) {
  deployer.deploy(WJ);
  deployer.deploy(WJFuzzing);
  deployer.deploy(TestFlashMinter);
  deployer.deploy(TestTransferReceiver);
};
