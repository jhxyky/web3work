// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
/*
扩展 ERC20 合约 ，添加一个有hook 功能的转账函数，如函数名为：transferWithCallback ，在转账时，如果目标地址是合约地址的话，调用目标地址的 tokensReceived() 方法。

继承 TokenBank 编写 TokenBankV2，支持存入扩展的 ERC20 Token，用户可以直接调用 transferWithCallback 将 扩展的 ERC20 Token 存入到 TokenBankV2 中。

（备注：TokenBankV2 需要实现 tokensReceived 来实现存款记录工作）
*/
import "./ExtendedERC20.sol";

contract TokenBankV2 {

    // 存款记录
    mapping(address => uint256) public deposits;

    // Token 地址
    ExtendedERC20 public token;

    constructor(address tokenAddress) {
        token = ExtendedERC20(tokenAddress);
    }

    // 存款函数，允许存入扩展的 ERC20 Token
    function deposit(uint256 amount) public {
        // 调用 transferWithCallback 将扩展 ERC20 Token 存入银行
        token.transferWithCallback(address(this), amount);
    }

    // tokensReceived 方法是 TokenBankV2 用于记录存款的地方
    // 被调用时记录存款金额
    function tokensReceived(address sender, uint256 amount) external {
        require(msg.sender == address(token), "Only the token can call this");

        // 记录用户存款
        deposits[sender] += amount;
    }

    // 查询用户的存款余额
    function getDeposit(address user) public view returns (uint256) {
        return deposits[user];
    }
}