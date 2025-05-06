// SPDX-License-Identifier: MIT

/*
扩展 ERC20 合约 ，添加一个有hook 功能的转账函数，如函数名为：transferWithCallback ，在转账时，如果目标地址是合约地址的话，调用目标地址的 tokensReceived() 方法。

继承 TokenBank 编写 TokenBankV2，支持存入扩展的 ERC20 Token，用户可以直接调用 transferWithCallback 将 扩展的 ERC20 Token 存入到 TokenBankV2 中。

（备注：TokenBankV2 需要实现 tokensReceived 来实现存款记录工作）
*/
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

interface ITokenReceiver {
    function tokensReceived(address sender, uint256 amount) external;
}

contract ExtendedERC20 is ERC20 {

    constructor(string memory name, string memory symbol) ERC20(name, symbol) {}

    // 扩展 transferWithCallback 函数
    function transferWithCallback(address recipient, uint256 amount) public returns (bool) {
        // 普通转账
        _transfer(_msgSender(), recipient, amount);

        // 检查 recipient 是否是合约地址
        if (isContract(recipient)) {
            // 如果目标地址是合约，调用 tokensReceived 函数
            ITokenReceiver(recipient).tokensReceived(_msgSender(), amount);
        }

        return true;
    }

    // 用来判断地址是否为合约地址
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        // 获取账户的代码大小，如果为0说明是EOA地址
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }
}