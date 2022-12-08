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

    function applyTransaction(
        address _receiver,
        IERC721 nftRequestor,
        uint256 nftIdRequestor,
        IERC721 nftReceiver,
        uint256 nftIdReceiver,
        IERC20 tradingToken,
        uint256 amountRequestor,
        uint256 amountReveiver
    ) external;

    function confirmTransaction(uint256 _transactionId) external;

    function revokeTransaction(uint256 _transactionId) external;

    function getUserTransaction(
        address _user
    ) external returns (uint256[] memory);

    function getAllTransaction() external returns (uint256[] memory);
}
