// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

contract ERC721test1 is ERC721Enumerable {
  constructor() ERC721("ERC721test1", "ERC721t1") {}

  function mint(uint256 _amount) external payable {
    for (uint256 i = 0; i < _amount; i++) {
      uint256 tokenId = totalSupply();
      _mint(msg.sender, tokenId);
    }
  }
}
