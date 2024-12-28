require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config()

//Hardhat failed to send contract verification request and returned ECONNRESET 如何通过代理解决 Etherscan 验证失败的问题？
//https://github.com/smartcontractkit/full-blockchain-solidity-course-js/discussions/2247
const { ProxyAgent, setGlobalDispatcher } = require("undici");
const proxyAgent = new ProxyAgent("http://127.0.0.1:7890");
setGlobalDispatcher(proxyAgent);

/** @type import('hardhat/config').HardhatUserConfig */

//提取.env存储的值
const SEPOLIA_URL = process.env.SEPOLIA_URL;
const PRIVATE_KEY = process.env.PRIVATE_KEY;
const API_KEY = process.env.API_KEY;
const POLYGON_URL = process.env.POLYGON_URL;
const POLYGON_API_KEY = process.env.POLYGON_API_KEY;

module.exports = {
  solidity: "0.8.22",
  networks:{
    sepolia:{
      url:SEPOLIA_URL,
      accounts:[PRIVATE_KEY],
      chainId:11155111
    },
    polygon:{
      url:POLYGON_URL,
      accounts:[PRIVATE_KEY],
      chainId:80002
    }
  },
  etherscan: {
    // Your API key for Etherscan,，允许你在 Hardhat 中自动验证和上传智能合约源代码到 Etherscan。
    //使用 Etherscan 的验证功能可以提高合约的透明度，允许其他开发者和用户查看和审核你的合约代码，增加可信度。
    apiKey: {
      sepolia:API_KEY,
      polygonAmoy:POLYGON_API_KEY
    }
  }
};
