// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./transactionContent.sol";

abstract contract INFTmarketplace is transactionContent {
    event appliedTransaction(
        address _requestor,
        address _receiver,
        IERC721 indexed _nftRequestor,
        IERC721 indexed _nftReceiver,
        IERC20 indexed _tradingToken
    );
    event confirmedTransaction(
        address _requestor,
        address _receiver,
        IERC721 indexed _nftRequestor,
        IERC721 indexed _nftReceiver,
        IERC20 indexed _tradingToken
    );
    event revokedTransaction(
        address _requestor,
        address _receiver,
        IERC721 indexed _nftRequestor,
        IERC721 indexed _nftReceiver,
        IERC20 indexed _tradingToken
    );

    function applyExchangeTransaction(
        address _receiver,
        IERC721 _nftRequestor,
        uint256 _nftIdRequestor,
        IERC721 _nftReceiver,
        uint256 _nftIdReceiver,
        IERC20 _tradingToken,
        uint256 _amountRequestor,
        uint256 _amountReveiver
    ) external virtual;

    function applySellTransaction(
        address _buyer,
        IERC721 _nftSell,
        uint256 _nftIdSell,
        IERC20 _tradingToken,
        uint256 _amountSell
    ) external virtual;

    function applyBidTransaction(
        address _seller,
        IERC721 _nftBid,
        uint256 _nftIdBid,
        IERC20 _tradingToken,
        uint256 _amountBid
    ) external virtual;

    function confirmExchangeTransaction(
        uint256 _transactionId
    ) external virtual;

    function confirmSellTransaction(uint256 _transactionId) external virtual;

    function confirmBidTransaction(uint256 _transactionId) external virtual;

    function revokeExchangeTransaction(uint256 _transactionId) external virtual;

    function revokeSellTransaction(uint256 _transactionId) external virtual;

    function revokeBidTransaction(uint256 _transactionId) external virtual;

    function getUserTransaction(
        address _user
    )
        external
        view
        virtual
        returns (
            uint256[] memory exchangeTransaction,
            uint256[] memory sellTransaction,
            uint256[] memory bidTransaction
        );

    function getAllExchangeTransaction()
        external
        view
        virtual
        returns (ExchangeTransaction[] memory);

    function getAllSellTransaction()
        external
        view
        virtual
        returns (SellTransaction[] memory);

    function getAllBidTransaction()
        external
        view
        virtual
        returns (BidTransaction[] memory);
}
