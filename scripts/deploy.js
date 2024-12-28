const { ethers } = require("hardhat");

async function main() {
  //using factory mode to build contract examples and simplify deployment
  const [deployer] = await ethers.getSigners(); // 获取当前钱包地址，作为部署者
  const initialOwner = deployer.address; // 这里可以是任意的地址，作为初始拥有者
  //读取合约的源代码，并进行编译。通常它会从指定的路径或项目中查找合约的编译文件。
  // 因为这些过程可能涉及到文件操作、网络请求等，可能需要一些时间，所以它是异步的
  const chainBattlesFactory = await ethers.getContractFactory("PinaDemo");
  console.log("contract deploying");
  //deploy 会发送一笔交易到区块链上，要求矿工将合约的字节码（bytecode）写入区块链。
  const chainBattles = await chainBattlesFactory.deploy(initialOwner);
  //用来等待部署的合约被确认，意思是等待合约被成功地广播到区块链并且进入一个块。
  await chainBattles.waitForDeployment();
  console.log(
    `contract has been deployed successfully, contract address is ${chainBattles.target}`
  );

  if ((hre.network.config.chainId == 11155111 || hre.network.config.chainId == 80002) && process.env.API_KEY) {
    // 等待一定时间，确保合约部署信息同步到区块链浏览器（Etherscan / Polygonscan）
    console.log("waiting for five confirmations");
    await chainBattles.deploymentTransaction().wait(5);
  
    // 根据当前的网络来决定验证
    console.log("start to verify");
  
    const networkName = hre.network.name;  // 获取当前网络名称
    let apiKey;
  
    // 根据不同的网络选择正确的 Etherscan API 密钥
    if (networkName === "sepolia") {
      apiKey = process.env.API_KEY;
    } else if (networkName === "polygonAmoy") {
      apiKey = process.env.POLYGON_API_KEY;
    }
  
    // 自动化合约验证
    await hre.run("verify:verify", {
      address: chainBattles.target,
      constructorArguments: [initialOwner],
      apiKey: apiKey,  // 确保使用正确的 API 密钥
    });
  
  } else {
    console.log("verification skip");
  }
  
}

main()
  .then()
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
