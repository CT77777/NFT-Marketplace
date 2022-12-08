// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./INFTmarketplace.sol";

/// @title NFT marketplace for NFT exchanging and trading
/// @author CT Chan
/// @notice You can use this contract to exchange or trade NFT by WETH/ USDT/ USDC and with few charge
/// @custom:murmurcats MMC holder own zero charge utility
contract NFTmarketplace is INFTmarketplace {
    address public utilityNFT;
    uint256 public charge;

    struct Transaction {
        address requestor;
        address receiver;
        IERC721 nftRequestor;
        IERC721 nftReceiver;
        IERC20 tradingToken;
        uint256 amountRequestor;
        uint256 amountReceiver;
        uint256 state;
    }

    enum transactionState {
        inProgress,
        completed,
        revoked
    }

    Transaction[] private transactions;

    constructor() {}

    function applyTransaction(
        address _receiver,
        IERC721 nftRequestor,
        uint256 nftIdRequestor,
        IERC721 nftReceiver,
        uint256 nftIdReceiver,
        IERC20 tradingToken,
        uint256 amountRequestor,
        uint256 amountReveiver
    ) external override {}

    function confirmTransaction(uint256 _transactionId) external override {}

    function revokeTransaction(uint256 _transactionId) external override {}

    function getUserTransaction(
        address _user
    ) external override returns (uint256[] memory) {}

    function getAllTransaction() external override returns (uint256[] memory) {}
}
