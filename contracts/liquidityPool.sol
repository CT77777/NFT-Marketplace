//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./interface/ILiquidityPool.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";

contract liquidityPool is ILiquidityPool, ERC20 {
    using Math for uint256;

    IERC20 public FRAGMENTS;
    IERC20 public WETH;

    constructor(
        IERC20 _FRAGMENTS,
        IERC20 _WETH
    ) ERC20("Liquidity Provider token", "LPT") {
        FRAGMENTS = _FRAGMENTS;
        WETH = _WETH;
    }

    function swap(
        IERC20 _tokenIn,
        uint256 _amountTokenIn,
        IERC20 _tokenOut
    ) external override returns (uint256 amountTokenOut) {
        require(_tokenIn != _tokenOut, "tokenIn and tokenOut is the same");
        require(
            _tokenIn == FRAGMENTS || _tokenIn == WETH,
            "tokenIn is not allowed"
        );
        require(
            _tokenOut == FRAGMENTS || _tokenOut == WETH,
            "tokenOut is not allowed"
        );
        require(
            _tokenIn.balanceOf(msg.sender) >= _amountTokenIn,
            "Not enough balance of tokenIn"
        );

        uint256 tokenInReserve = _tokenIn.balanceOf(address(this));
        uint256 tokenOutReserve = _tokenOut.balanceOf(address(this));
        uint256 k = tokenInReserve * tokenOutReserve;

        _tokenIn.transferFrom(msg.sender, address(this), _amountTokenIn);
        uint256 actualAmountTokenIn = _tokenIn.balanceOf(address(this)) -
            tokenInReserve;

        // derive from x * y = k
        uint256 actualAmountTokenOut = (tokenOutReserve * actualAmountTokenIn) /
            (tokenInReserve + actualAmountTokenIn);
        _tokenOut.transferFrom(address(this), msg.sender, actualAmountTokenOut);

        uint256 tokenInReserveCurrent = _tokenIn.balanceOf(address(this));
        uint256 tokenOutReserveCurrent = _tokenOut.balanceOf(address(this));
        require(
            tokenInReserveCurrent * tokenOutReserveCurrent >= k,
            "k doesn't pass criteria"
        );

        amountTokenOut = actualAmountTokenOut;

        return amountTokenOut;
    }

    function addLiquidity(uint256 _amountInFRAGMENTS) external override {
        require(_amountInFRAGMENTS != 0, "Input FRAGMENTS amount is zero");
        if (totalSupply() == 0) {
            uint256 realPriceNFT = 5 ether;
            uint256 amountInFRAGMENTS = _amountInFRAGMENTS;
            uint256 WETHInRatio = (amountInFRAGMENTS * type(uint32).max) /
                (100 ether);
            uint256 amountInWETH = (realPriceNFT * WETHInRatio) /
                type(uint32).max;
            require(
                WETH.balanceOf(msg.sender) >= amountInWETH,
                "Not enough WETH balance"
            );
            uint256 liquidity = Math.sqrt(amountInFRAGMENTS * amountInWETH);
            _mint(msg.sender, liquidity);
            FRAGMENTS.transferFrom(
                msg.sender,
                address(this),
                amountInFRAGMENTS
            );
            WETH.transferFrom(msg.sender, address(this), amountInWETH);
        } else {
            uint256 reserveFRAGMENTS = FRAGMENTS.balanceOf(address(this));
            uint256 reserveWETH = WETH.balanceOf(address(this));
            uint256 amountInFRAGMENTS = _amountInFRAGMENTS;

            uint256 amountInWETHCalcualted = amountInFRAGMENTS *
                ((reserveWETH * type(uint32).max) / reserveFRAGMENTS);
            uint256 amountInWETH = amountInWETHCalcualted / type(uint32).max;

            uint256 liquidity = Math.sqrt(amountInFRAGMENTS * amountInWETH);
            _mint(msg.sender, liquidity);
            FRAGMENTS.transferFrom(
                msg.sender,
                address(this),
                amountInFRAGMENTS
            );
            WETH.transferFrom(msg.sender, address(this), amountInWETH);
        }
    }

    function removeLiquidity(uint256 _amountLPT) external override {
        require(_amountLPT != 0, "Input LPT amount is zero");
        require(balanceOf(msg.sender) >= _amountLPT, "Not enough LPT balance");
        uint256 totalSupplyCurrrent = totalSupply();
        uint256 ratio = (_amountLPT * type(uint32).max) / totalSupplyCurrrent;
        uint256 reserveFRAGMENTS = FRAGMENTS.balanceOf(address(this));
        uint256 reserveWETH = WETH.balanceOf(address(this));

        uint256 amountOutFRAGMENTS = (reserveFRAGMENTS * ratio) /
            type(uint32).max;
        uint256 amountOutWETH = (reserveWETH * ratio) / type(uint32).max;

        _burn(msg.sender, _amountLPT);
        FRAGMENTS.transferFrom(msg.sender, address(this), amountOutFRAGMENTS);
        WETH.transferFrom(msg.sender, address(this), amountOutWETH);
    }

    function getTotalSupply() external view returns (uint256) {
        return totalSupply();
    }
}
