// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract BaseERC20 is ERC20 {
    constructor() ERC20("BaseERC20", "BERC20") {
        // 铸造 100,000,000 个代币给部署者（注意乘上 10^18，因为 decimals 是 18）
        _mint(msg.sender, 100_000_000 * 10 ** decimals());
    }
}