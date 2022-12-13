//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./interface/ILiquidityPool.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract liquidityPool is ILiquidityPool, ERC20 {
  IERC20 public fractionToken;
  IERC20 public WETH;

  constructor() ERC20("Liquidity Provide token", "LPT") {}

  function swap(IERC20 _tokenIn, uint256 _amountTokenIn) external override {}

  function addLiquidity(
    uint256 _amountTokenA,
    uint256 _amountTokenB
  ) external override {}

  function removeLiquidity(uint256 _amountLPT) external override {}
}
