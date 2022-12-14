// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract WETH is ERC20 {
  constructor() ERC20("Wrapped ETH", "WETH") {}

  function mint(uint256 _amount) external payable {
    _mint(msg.sender, _amount);
  }
}
