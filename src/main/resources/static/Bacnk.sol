// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
// 声明当前合约使用的Solidity版本是0.8.0及以上，这个是必须写的

contract Bank {
    address public owner;
    // 管理员地址，部署合约的人就是管理员

    struct UserInfo {
        address user;     // 用户的钱包地址
        uint256 balance;  // 用户的存款余额
    }
    // 定义一个结构体，方便后面存储用户的地址和存款金额（比如排行榜）

    mapping(address => uint256) public balances;
    // 定义一个映射表，记录每个用户的钱包地址 => 存款余额

    UserInfo[3] public topUsers;
    // 定义一个固定长度为3的数组，存放存款最多的前3名用户信息

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }
    // 定义一个修饰器，限制只有管理员（owner）才能调用某些函数
    // `msg.sender` 是发起交易的人地址
    // 如果不是owner，就抛出错误 "Not owner"
    // `_` 是占位符，表示函数体的代码在这里执行

    constructor() {
        owner = msg.sender;
    }
    // 构造函数，部署合约时执行。把部署者的地址保存为owner。

    receive() external payable {
        deposit();
    }
    // 特殊的receive()函数：如果别人直接向合约地址转ETH，就自动调用deposit()。
    // payable表示可以接收ETH。

    function deposit() public payable {
        require(msg.value > 0, "Deposit must be greater than 0");
        // 存款金额必须大于0

        balances[msg.sender] += msg.value;
        // 把发起人的存款累加记录起来

        _updateTopUsers(msg.sender);
        // 更新排行榜，看一下这个用户是不是进了前3
    }

    function withdraw() external onlyOwner {
        payable(owner).transfer(address(this).balance);
    }
    // 只有管理员可以调用withdraw()，把合约里全部ETH转到管理员地址
    // address(this).balance是当前合约账户里的ETH余额
    // transfer是转账，payable(owner)确保目标地址可以收钱

    function _updateTopUsers(address user) internal {
        uint256 userBalance = balances[user];
        // 获取当前用户的总存款余额

        // 先看这个用户是不是已经在排行榜里面了
        for (uint256 i = 0; i < 3; i++) {
            if (topUsers[i].user == user) {
                topUsers[i].balance = userBalance;
                _sortTopUsers();
                return;
            }
        }

        // 如果不在排行榜上，看看是否有资格进榜
        if (userBalance > topUsers[2].balance) {
            // 如果这个用户的余额比第三名还多，就替换掉第三名
            topUsers[2] = UserInfo(user, userBalance);
            _sortTopUsers();
        }
    }

    function _sortTopUsers() internal {
        // 冒泡排序，把topUsers数组按存款额从高到低排列
        for (uint256 i = 0; i < 2; i++) {
            for (uint256 j = i + 1; j < 3; j++) {
                if (topUsers[j].balance > topUsers[i].balance) {
                    // 如果后面那个比前面的大，交换位置
                    UserInfo memory temp = topUsers[i];
                    topUsers[i] = topUsers[j];
                    topUsers[j] = temp;
                }
            }
        }
    }

    function getTopUsers() external view returns (UserInfo[3] memory) {
        return topUsers;
    }
    // 提供一个函数，可以让外部查看存款排行榜Top3
}