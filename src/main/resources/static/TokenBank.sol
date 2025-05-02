// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/*
编写一个 TokenBank 合约，可以将自己的 Token 存入到 TokenBank， 和从 TokenBank 取出。
TokenBank 有两个方法：
deposit() : 需要记录每个地址的存入数量；
withdraw（）: 用户可以提取自己的之前存入的 token。
*/
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract TokenBank is Ownable {
    IERC20 public token;

    mapping(address => uint256) public balanceOf;

    constructor(address _tokenAddress) {
        token = IERC20(_tokenAddress);
    }

    // 用户存款
    function deposit(uint256 amount) external {
        require(amount > 0, "Amount must be greater than 0");

        // 用户需要先approve给Bank合约授权
        bool success = token.transferFrom(msg.sender, address(this), amount);
        require(success, "Transfer failed");

        balanceOf[msg.sender] += amount;
    }

    // 用户查看自己存了多少（balanceOf已经是public，可以直接查）
    // function balanceOf(address user) external view returns (uint256) { }

    // 管理员提取所有Token
    function withdraw() external onlyOwner {
        uint256 balance = token.balanceOf(address(this));
        require(balance > 0, "No tokens to withdraw");

        bool success = token.transfer(owner(), balance);
        require(success, "Withdraw failed");
    }
}