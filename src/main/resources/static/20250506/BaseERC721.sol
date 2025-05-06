// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Address.sol";  // 导入Address库，提供一些与地址相关的工具函数
import "@openzeppelin/contracts/utils/Context.sol";   // 导入Context库，提供上下文信息
import "@openzeppelin/contracts/utils/Strings.sol";   // 导入Strings库，提供数字转换为字符串的工具函数
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";  // 导入IERC721Receiver接口，定义接收ERC721的标准方法

contract BaseERC721 {
    using Strings for uint256;  // 使用Strings库中的功能，主要是数字转字符串
    using Address for address; // 使用Address库中的功能，主要是地址相关操作

    // 定义ERC721的一些基本属性
    string private _name;  // 存储代币名称
    string private _symbol;  // 存储代币符号
    string private _baseURI;  // 存储基础URI

    // ERC721的核心数据结构
    mapping(uint256 => address) private _owners;  // 记录每个tokenId对应的所有者
    mapping(address => uint256) private _balances;  // 记录每个地址拥有的token数量
    mapping(uint256 => address) private _tokenApprovals;  // 记录每个tokenId被批准的地址
    mapping(address => mapping(address => bool)) private _operatorApprovals;  // 记录某个地址是否被授权管理另一个地址的所有NFT

    // 定义ERC721标准中的三个事件
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);  // 转账事件
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);  // 授权事件
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);  // 批量授权事件

    // 合约构造函数，初始化名称、符号和基础URI
    constructor(string memory name_, string memory symbol_, string memory baseURI_) {
        _name = name_;  // 设置代币名称  <-- 需要填入代币名称的值
        _symbol = symbol_;  // 设置代币符号  <-- 需要填入代币符号的值
        _baseURI = baseURI_;  // 设置基础URI  <-- 需要填入基础URI的值
    }

    // 实现IERC165接口的supportsInterface方法，判断当前合约是否支持某个接口
    function supportsInterface(bytes4 interfaceId) public pure returns (bool) {
        return
            interfaceId == 0x01ffc9a7 || // ERC165接口ID
            interfaceId == 0x80ac58cd || // ERC721接口ID
            interfaceId == 0x5b5e139f;   // ERC721Metadata接口ID
    }

    // 实现IERC721Metadata接口的name方法，返回代币名称
    function name() public view returns (string memory) {
        return _name;  // 返回代币名称
    }

    // 实现IERC721Metadata接口的symbol方法，返回代币符号
    function symbol() public view returns (string memory) {
        return _symbol;  // 返回代币符号
    }

    // 实现IERC721Metadata接口的tokenURI方法，返回token的URI
    function tokenURI(uint256 tokenId) public view returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");  // 如果tokenId不存在，抛出异常

        return string(abi.encodePacked(_baseURI, tokenId.toString()));  // 拼接基础URI和tokenId，返回完整的tokenURI
    }

    // 实现mint方法，铸造新的NFT并转给指定地址
    function mint(address to, uint256 tokenId) public {
        require(to != address(0), "ERC721: mint to the zero address");  // 不允许铸造到零地址
        require(!_exists(tokenId), "ERC721: token already minted");  // 不允许重复铸造

        _owners[tokenId] = to;  // 设置tokenId的拥有者
        _balances[to] += 1;  // 增加该地址的token数量

        emit Transfer(address(0), to, tokenId);  // 触发Transfer事件，表示铸造成功
    }

    // 实现IERC721接口的balanceOf方法，查询某个地址持有的NFT数量
    function balanceOf(address owner) public view returns (uint256) {
        return _balances[owner];  // 返回该地址持有的token数量
    }

    // 实现IERC721接口的ownerOf方法，查询某个tokenId的所有者
    function ownerOf(uint256 tokenId) public view returns (address) {
        require(_exists(tokenId), "ERC721: owner query for nonexistent token");  // 如果tokenId不存在，抛出异常

        return _owners[tokenId];  // 返回该tokenId的所有者
    }

    // 实现IERC721接口的approve方法，授权指定地址转移某个tokenId的所有权
    function approve(address to, uint256 tokenId) public {
        address owner = ownerOf(tokenId);  // 获取该tokenId的所有者
        require(to != owner, "ERC721: approval to current owner");  // 不允许授权给当前所有者

        require(msg.sender == owner || isApprovedForAll(owner, msg.sender), "ERC721: approve caller is not owner nor approved for all");  // 只能由所有者或者被授权的操作者调用

        _approve(to, tokenId);  // 调用内部方法进行批准
    }

    // 实现IERC721接口的getApproved方法，查询某个tokenId的批准地址
    function getApproved(uint256 tokenId) public view returns (address) {
        require(_exists(tokenId), "ERC721: approved query for nonexistent token");  // 如果tokenId不存在，抛出异常

        return _tokenApprovals[tokenId];  // 返回批准地址
    }

    // 实现IERC721接口的setApprovalForAll方法，授权或撤销对所有token的操作权限
    function setApprovalForAll(address operator, bool approved) public {
        require(operator != msg.sender, "ERC721: approve to caller");  // 不允许批准自己

        _operatorApprovals[msg.sender][operator] = approved;  // 设置对操作员的授权状态

        emit ApprovalForAll(msg.sender, operator, approved);  // 触发ApprovalForAll事件
    }

    // 实现IERC721接口的isApprovedForAll方法，查询某个地址是否被授权管理另一个地址的所有token
    function isApprovedForAll(address owner, address operator) public view returns (bool) {
        return _operatorApprovals[owner][operator];  // 返回授权状态
    }

    // 实现IERC721接口的transferFrom方法，转移tokenId的所有权
    function transferFrom(address from, address to, uint256 tokenId) public {
        require(_isApprovedOrOwner(msg.sender, tokenId), "ERC721: transfer caller is not owner nor approved");  // 只能由所有者或批准者转移

        _transfer(from, to, tokenId);  // 调用内部转移方法
    }

    // 实现IERC721接口的safeTransferFrom方法，安全地转移tokenId的所有权
    function safeTransferFrom(address from, address to, uint256 tokenId) public {
        safeTransferFrom(from, to, tokenId, "");  // 默认情况下不发送额外的数据
    }

    // 实现IERC721接口的safeTransferFrom方法，带数据的安全转移tokenId的所有权
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public {
        require(_isApprovedOrOwner(msg.sender, tokenId), "ERC721: transfer caller is not owner nor approved");  // 只能由所有者或批准者转移

        _safeTransfer(from, to, tokenId, _data);  // 调用安全转移方法
    }

    // 内部方法：安全转移tokenId的所有权，并检查接收方是否实现了ERC721Receiver接口
    function _safeTransfer(address from, address to, uint256 tokenId, bytes memory _data) internal {
        _transfer(from, to, tokenId);  // 调用常规转移方法

        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");  // 检查接收方是否是ERC721接收者
    }

    // 内部方法：判断tokenId是否存在
    function _exists(uint256 tokenId) internal view returns (bool) {
        return _owners[tokenId] != address(0);  // 如果tokenId的所有者地址不是零地址，则表示该tokenId存在
    }

    // 内部方法：判断调用者是否有权管理指定tokenId
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view returns (bool) {
        address owner = ownerOf(tokenId);  // 获取tokenId的所有者
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));  // 判断调用者是否为所有者、批准者或被授权管理所有资产的操作员
    }

    // 内部方法：执行实际的token转移操作
    function _transfer(address from, address to, uint256 tokenId) internal {
        require(ownerOf(tokenId) == from, "ERC721: transfer from incorrect owner");  // 确保当前所有者是从地址

        _approve(address(0), tokenId);  // 取消token的批准

        _balances[from] -= 1;  // 减少源地址的token数量
        _balances[to] += 1;    // 增加目标地址的token数量
        _owners[tokenId] = to;  // 更新tokenId的所有者

        emit Transfer(from, to, tokenId);  // 触发Transfer事件
    }

    // 内部方法：批准某个地址转移tokenId的所有权
    function _approve(address to, uint256 tokenId) internal {
        _tokenApprovals[tokenId] = to;  // 设置批准地址
        emit Approval(ownerOf(tokenId), to, tokenId);  // 触发Approval事件
    }

    // 内部方法：检查接收方是否实现了ERC721Receiver接口
    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory _data)
    private returns (bool)
    {
        if (to.isContract()) {  // 如果接收方是合约地址
            try IERC721Receiver(to).onERC721Received(msg.sender, from, tokenId, _data) returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;  // 返回的selector必须匹配
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");  // 如果没有实现ERC721Receiver，则抛出异常
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))  // 否则，传递错误信息
                    }
                }
            }
        } else {
            return true;  // 如果接收方不是合约，则认为转移成功
        }
    }
}