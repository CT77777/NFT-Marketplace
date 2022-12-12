// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./INFTmarketplace.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";

/// @title NFT marketplace for NFT exchanging and trading
/// @author CT Chan
/// @notice You can use this contract to exchange or trade NFT by WETH/ USDT/ USDC and with few charge
/// @custom:murmurcats MMC holder own zero charge utility
contract NFTmarketplace is INFTmarketplace {
    IERC721 public utilityNFT;
    uint256 public charge;

    IERC20 public WETH;
    IERC20 public USDT;
    IERC20 public USDC;

    struct Transaction {
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

    enum transactionState {
        inProgress,
        completed,
        revoked
    }

    Transaction[] private transactions;
    mapping(address => Transaction[]) userTransaction;

    constructor(
        IERC721 _utilityNFT,
        uint256 _charge,
        IERC20 _WETH,
        IERC20 _USDT,
        IERC20 _USDC
    ) {
        utilityNFT = _utilityNFT;
        charge = _charge;
        WETH = _WETH;
        USDC = _USDC;
        USDT = _USDT;
    }

    function applyExchangeTransaction(
        address _receiver,
        IERC721 _nftRequestor,
        uint256 _nftIdRequestor,
        IERC721 _nftReceiver,
        uint256 _nftIdReceiver,
        IERC20 _tradingToken,
        uint256 _amountRequestor,
        uint256 _amountReveiver
    ) external override {
        if (address(_nftRequestor) != address(0)) {
            require(
                _nftIdRequestor <=
                    IERC721Enumerable(address(_nftRequestor)).totalSupply()
            );
            require(_nftRequestor.ownerOf(_nftIdRequestor) == msg.sender);
        }

        if (address(_nftReceiver) != address(0)) {
            require(
                _nftIdReceiver <=
                    IERC721Enumerable(address(_nftReceiver)).totalSupply()
            );
            require(_nftReceiver.ownerOf(_nftIdReceiver) == _receiver);
        }

        transactions.push(
            Transaction({
                requestor: msg.sender,
                receiver: _receiver,
                nftRequestor: _nftRequestor,
                nftIdRequestor: _nftIdRequestor,
                nftReceiver: _nftReceiver,
                nftIdReceiver: _nftIdReceiver,
                tradingToken: _tradingToken,
                amountRequestor: _amountRequestor,
                amountReceiver: _amountReveiver,
                state: transactionState.inProgress
            })
        );
    }

    function applySellTransaction(
        address _buyer,
        IERC721 _nftSell,
        uint256 _nftIdSell,
        IERC20 _tradingToken,
        uint256 _amountSell
    ) external override {}

    function applyBidTransaction(
        address _seller,
        IERC721 _nftBid,
        uint256 _nftIdBid,
        IERC20 _tradingToken,
        uint256 _amountBid
    ) external override {}

    function confirmExchangeTransaction(
        uint256 _transactionId
    ) external override {}

    function confirmSellTransaction(uint256 _transactionId) external override {}

    function confirmBidTransaction(uint256 _transactionId) external override {}

    function revokeExchangeTransaction(
        uint256 _transactionId
    ) external override {}

    function revokeSellTransaction(uint256 _transactionId) external override {}

    function revokeBidTransaction(uint256 _transactionId) external override {}

    function getUserTransaction(
        address _user
    )
        external
        view
        override
        returns (
            uint256[] memory exchangeTransaction,
            uint256[] memory sellTransaction,
            uint256[] memory bidTransaction
        )
    {}

    function getAllExchangeTransaction()
        external
        view
        override
        returns (uint256[] memory)
    {}

    function getAllSellTransaction()
        external
        view
        override
        returns (uint256[] memory)
    {}

    function getAllBidTransaction()
        external
        view
        override
        returns (uint256[] memory)
    {}
}
