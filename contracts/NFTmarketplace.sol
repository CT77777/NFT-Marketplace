// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./interface/INFTmarketplace.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/// @title NFT marketplace for NFT exchanging and trading
/// @author CT Chan
/// @notice You can use this contract to exchange or trade NFT by WETH/ USDT/ USDC and with few charge
/// @custom:murmurcats MMC holder own zero charge utility
contract NFTmarketplace is INFTmarketplace, ERC20 {
  IERC721 public utilityNFT;
  uint256 public charge;

  IERC20 public WETH;
  IERC20 public USDT;
  IERC20 public USDC;

  ExchangeTransaction[] public exchangeTransactions;
  SellTransaction[] public sellTransactions;
  BidTransaction[] public bidTransactions;

  mapping(address => uint256[]) userExchangeTransactions;
  mapping(address => uint256[]) userSellTransactions;
  mapping(address => uint256[]) userBidTransactions;

  modifier tradingTokenCheck(IERC20 _tradingToken) {
    require(
      _tradingToken == WETH || _tradingToken == USDT || _tradingToken == USDC,
      "trading token is not allowed"
    );
    _;
  }

  modifier nonReentrancy() {
    bool lock;
    require(!lock, "nonReentrancy");
    lock = true;
    _;
    lock = false;
  }

  constructor(
    IERC721 _utilityNFT,
    uint256 _charge,
    IERC20 _WETH,
    IERC20 _USDT,
    IERC20 _USDC
  ) ERC20("Fractional MurMurCats", "FMMC") {
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
  ) external override tradingTokenCheck(_tradingToken) {
    require(address(_nftRequestor) != address(0), "outNFT address is zero");
    require(
      _nftIdRequestor <=
        IERC721Enumerable(address(_nftRequestor)).totalSupply(),
      "token Id is invalid for outNFT"
    );
    require(
      _nftRequestor.ownerOf(_nftIdRequestor) == msg.sender,
      "requestor is not the owner of outNFT"
    );

    require(address(_nftReceiver) != address(0), "inNFT address is zero");
    require(
      _nftIdReceiver <= IERC721Enumerable(address(_nftReceiver)).totalSupply(),
      "token Id is invalid for inNFT"
    );
    require(
      _nftReceiver.ownerOf(_nftIdReceiver) == _receiver,
      "receiver is not the owner of inNFT"
    );

    exchangeTransactions.push(
      ExchangeTransaction({
        transactionId: exchangeTransactions.length,
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

    userExchangeTransactions[msg.sender].push(exchangeTransactions.length);
    userExchangeTransactions[_receiver].push(exchangeTransactions.length);
  }

  function applySellTransaction(
    address _buyer,
    IERC721 _nftSell,
    uint256 _nftIdSell,
    IERC20 _tradingToken,
    uint256 _amountSell
  ) external override tradingTokenCheck(_tradingToken) {
    require(address(_nftSell) != address(0), "Selling NFT address is zero");
    require(
      _nftIdSell <= IERC721Enumerable(address(_nftSell)).totalSupply(),
      "token Id is invalid in selling NFT"
    );
    require(
      _nftSell.ownerOf(_nftIdSell) == msg.sender,
      "Not owner of selling NFT"
    );

    sellTransactions.push(
      SellTransaction({
        transactionId: sellTransactions.length,
        requestor: msg.sender,
        buyer: _buyer,
        nftSell: _nftSell,
        nftIdSell: _nftIdSell,
        tradingToken: _tradingToken,
        amountSell: _amountSell,
        state: transactionState.inProgress
      })
    );

    userSellTransactions[msg.sender].push(sellTransactions.length);

    if (_buyer != address(0)) {
      userSellTransactions[_buyer].push(sellTransactions.length);
    }
  }

  function applyBidTransaction(
    IERC721 _nftBid,
    IERC20 _tradingToken,
    uint256 _amountBid
  ) external override tradingTokenCheck(_tradingToken) {
    require(address(_nftBid) != address(0), "bid NFT address is zero");
    require(
      _tradingToken.balanceOf(msg.sender) >= _amountBid,
      "Not enough balance of trading token"
    );

    bidTransactions.push(
      BidTransaction({
        transactionId: bidTransactions.length,
        requestor: msg.sender,
        nftBid: _nftBid,
        tradingToken: _tradingToken,
        amountBid: _amountBid,
        state: transactionState.inProgress
      })
    );
  }

  function confirmExchangeTransaction(
    uint256 _transactionId
  ) external override {
    ExchangeTransaction storage exchangeTransaction = exchangeTransactions[
      _transactionId
    ];
    require(
      exchangeTransaction.state == transactionState.inProgress,
      "transaction is not inProgress"
    );
    require(msg.sender == exchangeTransaction.receiver, "Not the receiver");
    require(
      exchangeTransaction.nftRequestor.ownerOf(
        exchangeTransaction.nftIdRequestor
      ) == exchangeTransaction.requestor,
      "requestor is not the owner of outNFT"
    );
    require(
      exchangeTransaction.nftReceiver.ownerOf(
        exchangeTransaction.nftIdReceiver
      ) == msg.sender,
      "receiver is not the owner of inNFT"
    );

    exchangeTransaction.state = transactionState.completed;

    if (exchangeTransaction.amountRequestor != 0) {
      exchangeTransaction.tradingToken.transferFrom(
        exchangeTransaction.requestor,
        msg.sender,
        exchangeTransaction.amountRequestor
      );
    }

    if (exchangeTransaction.amountReceiver != 0) {
      exchangeTransaction.tradingToken.transferFrom(
        msg.sender,
        exchangeTransaction.requestor,
        exchangeTransaction.amountReceiver
      );
    }

    exchangeTransaction.nftRequestor.transferFrom(
      exchangeTransaction.requestor,
      msg.sender,
      exchangeTransaction.nftIdRequestor
    );
    exchangeTransaction.nftReceiver.transferFrom(
      msg.sender,
      exchangeTransaction.requestor,
      exchangeTransaction.nftIdReceiver
    );
  }

  function confirmSellTransaction(uint256 _transactionId) external override {
    SellTransaction storage sellTransaction = sellTransactions[_transactionId];
    require(
      sellTransaction.state == transactionState.inProgress,
      "transaction is invalid"
    );
    require(
      sellTransaction.nftSell.ownerOf(sellTransaction.nftIdSell) ==
        sellTransaction.requestor,
      "Requestor is not owner of selling NFT"
    );
    require(
      sellTransaction.tradingToken.balanceOf(msg.sender) >=
        sellTransaction.amountSell,
      "Not enough tranding token balance"
    );
    if (sellTransaction.buyer != address(0)) {
      require(msg.sender == sellTransaction.buyer, "Not the specific buyer");
    }

    sellTransaction.state = transactionState.completed;

    sellTransaction.tradingToken.transferFrom(
      msg.sender,
      sellTransaction.requestor,
      sellTransaction.amountSell
    );

    sellTransaction.nftSell.transferFrom(
      sellTransaction.requestor,
      msg.sender,
      sellTransaction.nftIdSell
    );
  }

  function confirmBidTransaction(
    uint256 _transactionId,
    uint256 _nftIdBid
  ) external override {
    BidTransaction storage bidTransaction = bidTransactions[_transactionId];
    require(
      bidTransaction.state == transactionState.inProgress,
      "transaction is invalid"
    );
    require(
      bidTransaction.nftBid.balanceOf(msg.sender) > 0,
      "Don't have any bid NFT"
    );
    require(
      bidTransaction.tradingToken.balanceOf(bidTransaction.requestor) >=
        bidTransaction.amountBid,
      "Bider have'nt enough balance of trading token"
    );

    bidTransaction.state = transactionState.completed;

    bidTransaction.tradingToken.transferFrom(
      bidTransaction.requestor,
      msg.sender,
      bidTransaction.amountBid
    );

    bidTransaction.nftBid.transferFrom(
      msg.sender,
      bidTransaction.requestor,
      _nftIdBid
    );
  }

  function revokeExchangeTransaction(uint256 _transactionId) external override {
    ExchangeTransaction storage exchangeTransaction = exchangeTransactions[
      _transactionId
    ];
    require(
      exchangeTransaction.state == transactionState.inProgress,
      "transaction is already completed or revoked"
    );
    require(msg.sender == exchangeTransaction.requestor, "Only requestor");
    exchangeTransaction.state = transactionState.revoked;
  }

  function revokeSellTransaction(uint256 _transactionId) external override {
    SellTransaction storage sellTransaction = sellTransactions[_transactionId];
    require(
      sellTransaction.state == transactionState.inProgress,
      "transaction is already completed or revoked"
    );
    require(msg.sender == sellTransaction.requestor, "Only requestor");
    sellTransaction.state = transactionState.revoked;
  }

  function revokeBidTransaction(uint256 _transactionId) external override {
    BidTransaction storage bidTransaction = bidTransactions[_transactionId];
    require(
      bidTransaction.state == transactionState.inProgress,
      "transaction is already completed or revoked"
    );
    require(msg.sender == bidTransaction.requestor, "Only requestor");
    bidTransaction.state = transactionState.revoked;
  }

  function fragment(uint256[] calldata _utilityNFTid) external override {
    uint256 amountNFT = _utilityNFTid.length;
    for (uint256 i = 0; i < amountNFT; i++) {
      require(
        _utilityNFTid[i] <=
          IERC721Enumerable(address(utilityNFT)).totalSupply(),
        "token Id is invalid"
      );
      require(
        msg.sender == utilityNFT.ownerOf(_utilityNFTid[i]),
        "Not owner of the token"
      );
      utilityNFT.transferFrom(msg.sender, address(this), _utilityNFTid[i]);
    }
    uint256 amountFragments = amountNFT * 100 ether;
    _mint(msg.sender, amountFragments);
  }

  function recombine(
    uint256[] calldata _utilityNFTid
  ) external override nonReentrancy {
    uint256 amountNFT = _utilityNFTid.length;
    uint256 amountFragments = amountNFT * 5 ether;
    require(
      balanceOf(msg.sender) >= amountFragments,
      "Not enough balance of the fractional NFT"
    );

    for (uint256 i = 0; i < amountNFT; i++) {
      require(
        _utilityNFTid[i] <=
          IERC721Enumerable(address(utilityNFT)).totalSupply(),
        "token Id is invalid"
      );
      require(
        address(this) == utilityNFT.ownerOf(_utilityNFTid[i]),
        "Valut does'nt have this token Id"
      );
      utilityNFT.transferFrom(address(this), msg.sender, _utilityNFTid[i]);
    }

    _burn(msg.sender, amountFragments);
  }

  function getUserTransaction(
    address _user
  )
    external
    view
    override
    returns (uint256[] memory, uint256[] memory, uint256[] memory)
  {
    return (
      userExchangeTransactions[_user],
      userSellTransactions[_user],
      userBidTransactions[_user]
    );
  }

  function getAllExchangeTransaction()
    external
    view
    override
    returns (ExchangeTransaction[] memory)
  {
    return exchangeTransactions;
  }

  function getAllSellTransaction()
    external
    view
    override
    returns (SellTransaction[] memory)
  {
    return sellTransactions;
  }

  function getAllBidTransaction()
    external
    view
    override
    returns (BidTransaction[] memory)
  {
    return bidTransactions;
  }
}
