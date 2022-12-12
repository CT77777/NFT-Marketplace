//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./transactionStateReporter.sol";

contract transactionContent is transactionStateReporter {
    struct ExchangeTransaction {
        uint256 transactionId;
        address requestor;
        address receiver;
        IERC721 nftRequestor;
        uint256 nftIdRequestor;
        IERC721 nftReceiver;
        uint256 nftIdReceiver;
        IERC20 tradingToken;
        uint256 amountRequestor;
        uint256 amountReceiver;
        transactionState state;
    }

    struct SellTransaction {
        address requestor;
        address buyer;
        IERC721 nftSell;
        uint256 nftIdSell;
        IERC20 tradingToken;
        uint256 amountSell;
        transactionState state;
    }

    struct BidTransaction {
        address requestor;
        address seller;
        IERC721 nftBid;
        uint256 nftIdBid;
        IERC20 tradingToken;
        uint256 amountBid;
        transactionState state;
    }
}
