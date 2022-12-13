// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface ILiquidityPool {
  function swap(IERC20 _tokenIn, uint256 _amountTokenIn) external;

  function addLiquidity(uint256 _amountTokenA, uint256 _amountTokenB) external;

  function removeLiquidity(uint256 _amountLP) external;
}
