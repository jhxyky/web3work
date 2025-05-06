// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./SimpleNFT.sol";
import "./1/BaseERC20.sol";

contract NFTMarket is ITokenReceiver {
    BaseERC20 public token;
    SimpleNFT public nft;

    struct Listing {
        address seller;
        uint256 price;
    }

    mapping(uint256 => Listing) public listings;

    constructor(address _token, address _nft) {
        token = BaseERC20(_token);
        nft = SimpleNFT(_nft);
    }

    function list(uint256 tokenId, uint256 price) external {
        require(nft.ownerOf(tokenId) == msg.sender, "Not NFT owner");

        nft.approve(address(this), tokenId);

        listings[tokenId] = Listing({
            seller: msg.sender,
            price: price
        });
    }

    function buyNFT(uint256 tokenId) external {
        Listing memory item = listings[tokenId];
        require(item.seller != address(0), "Not listed");

        require(token.transferFrom(msg.sender, item.seller, item.price), "Payment failed");

        nft.transferFrom(item.seller, msg.sender, tokenId);

        delete listings[tokenId];
    }

    // 这个是支持 token 直接购买（通过 tokensReceived 自动触发）
    function tokensReceived(address from, uint256 amount, bytes calldata data) external override {
        require(msg.sender == address(token), "Only accept BaseERC20 token");

        require(data.length == 32, "Invalid data"); // tokenId
        uint256 tokenId = abi.decode(data, (uint256));

        Listing memory item = listings[tokenId];
        require(item.seller != address(0), "Not listed");
        require(amount >= item.price, "Insufficient payment");

        nft.transferFrom(item.seller, from, tokenId);

        delete listings[tokenId];
    }
}