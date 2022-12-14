// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract USDT is ERC20 {
  constructor() ERC20("USD Tether", "USDT") {}

  function mint(uint256 _amount) external payable {
    _mint(msg.sender, _amount);
  }
}
