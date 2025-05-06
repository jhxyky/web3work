// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SimpleNFT {
    string public name = "SimpleNFT";
    string public symbol = "SNFT";

    uint256 public nextTokenId;
    mapping(uint256 => address) public ownerOf;
    mapping(address => uint256) public balanceOf;
    mapping(uint256 => address) public approvals;

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    function mint(address to) external {
        uint256 tokenId = nextTokenId;
        nextTokenId++;
        ownerOf[tokenId] = to;
        balanceOf[to]++;
        emit Transfer(address(0), to, tokenId);
    }

    function approve(address to, uint256 tokenId) external {
        address owner = ownerOf[tokenId];
        require(msg.sender == owner, "Only owner can approve");
        approvals[tokenId] = to;
        emit Approval(owner, to, tokenId);
    }

    function transferFrom(address from, address to, uint256 tokenId) pub
    lic {
        require(ownerOf[tokenId] == from, "Not owner");
        require(msg.sender == from || approvals[tokenId] == msg.sender, "Not approved");

        ownerOf[tokenId] = to;
        balanceOf[from]--;
        balanceOf[to]++;
        delete approvals[tokenId];

        emit Transfer(from, to, tokenId);
    }
}