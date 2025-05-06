// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ITokenReceiver {
    function tokensReceived(address from, uint256 amount, bytes calldata data) external;
}

contract BaseERC20 {
    string public name = "BaseERC20";
    string public symbol = "BERC20";
    uint8 public decimals = 18;
    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor() {
        totalSupply = 100_000_000 * (10 ** decimals);
        balanceOf[msg.sender] = totalSupply;
    }

    function transfer(address to, uint256 amount) public returns (bool) {
        _transfer(msg.sender, to, amount, "");
        return true;
    }

    function transferWithData(address to, uint256 amount, bytes calldata data) public returns (bool) {
        _transfer(msg.sender, to, amount, data);
        return true;
    }

    function _transfer(address from, address to, uint256 amount, bytes memory data) internal {
        require(balanceOf[from] >= amount, "ERC20: insufficient balance");
        require(to != address(0), "ERC20: transfer to zero address");

        balanceOf[from] -= amount;
        balanceOf[to] += amount;

        emit Transfer(from, to, amount);

        // 检查是否是合约，并调用 tokensReceived
        if (isContract(to)) {
            try ITokenReceiver(to).tokensReceived(from, amount, data) {
            } catch {
                // 如果不是支持 tokensReceived 的合约，可以忽略
            }
        }
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) public returns (bool) {
        require(allowance[from][msg.sender] >= amount, "ERC20: allowance exceeded");
        allowance[from][msg.sender] -= amount;
        _transfer(from, to, amount, "");
        return true;
    }

    function isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }
}