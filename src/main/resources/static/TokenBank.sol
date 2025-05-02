// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title TokenBank - 存取 BaseERC20 Token 的银行
interface IERC20 {
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function transfer(address to, uint256 amount) external returns (bool);
}

contract TokenBank {
    IERC20 public token;
    mapping(address => uint256) public balances;

    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);

    constructor(address _tokenAddress) {
        token = IERC20(_tokenAddress);
    }

    /// @notice 存Token
    function deposit(uint256 amount) external {
        require(amount > 0, "Deposit amount must be greater than 0");

        bool success = token.transferFrom(msg.sender, address(this), amount);
        require(success, "Token transfer failed");

        balances[msg.sender] += amount;

        emit Deposit(msg.sender, amount);
    }

    /// @notice 取Token
    function withdraw(uint256 amount) external {
        require(amount > 0, "Withdraw amount must be greater than 0");
        require(balances[msg.sender] >= amount, "Insufficient balance");

        balances[msg.sender] -= amount;

        bool success = token.transfer(msg.sender, amount);
        require(success, "Token transfer failed");

        emit Withdraw(msg.sender, amount);
    }

    /// @notice 查询某个用户存在银行里的Token数量
    function balanceOf(address user) external view returns (uint256) {
        return balances[user];
    }
}