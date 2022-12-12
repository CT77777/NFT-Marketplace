// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface INFTmarketplace {
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
    ) external;

    function applySellTransaction(
        address _buyer,
        IERC721 _nftSell,
        uint256 _nftIdSell,
        IERC20 _tradingToken,
        uint256 _amountSell
    ) external;

    function applyBidTransaction(
        address _seller,
        IERC721 _nftBid,
        uint256 _nftIdBid,
        IERC20 _tradingToken,
        uint256 _amountBid
    ) external;

    function confirmExchangeTransaction(uint256 _transactionId) external;

    function confirmSellTransaction(uint256 _transactionId) external;

    function confirmBidTransaction(uint256 _transactionId) external;

    function revokeExchangeTransaction(uint256 _transactionId) external;

    function revokeSellTransaction(uint256 _transactionId) external;

    function revokeBidTransaction(uint256 _transactionId) external;

    function getUserTransaction(
        address _user
    )
        external
        view
        returns (
            uint256[] memory exchangeTransaction,
            uint256[] memory sellTransaction,
            uint256[] memory bidTransaction
        );

    function getAllExchangeTransaction()
        external
        view
        returns (uint256[] memory);

    function getAllSellTransaction() external view returns (uint256[] memory);

    function getAllBidTransaction() external view returns (uint256[] memory);
}
