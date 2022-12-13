// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./transactionContent.sol";

interface INFTmarketplace is transactionContent {
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
    IERC721 _nftBid,
    IERC20 _tradingToken,
    uint256 _amountBid
  ) external;

  function confirmExchangeTransaction(uint256 _transactionId) external;

  function confirmSellTransaction(uint256 _transactionId) external;

  function confirmBidTransaction(
    uint256 _transactionId,
    uint256 _nftIdBid
  ) external;

  function revokeExchangeTransaction(uint256 _transactionId) external;

  function revokeSellTransaction(uint256 _transactionId) external;

  function revokeBidTransaction(uint256 _transactionId) external;

  function fragment(uint256[] calldata _utilityNFTid) external;

  function recombine(uint256[] calldata _utilityNFTid) external;

  function getUserTransaction(
    address _user
  )
    external
    view
    returns (uint256[] memory, uint256[] memory, uint256[] memory);

  function getAllExchangeTransaction()
    external
    view
    returns (ExchangeTransaction[] memory);

  function getAllSellTransaction()
    external
    view
    returns (SellTransaction[] memory);

  function getAllBidTransaction()
    external
    view
    returns (BidTransaction[] memory);
}
