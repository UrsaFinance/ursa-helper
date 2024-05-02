//SPDX-License-Identifier: BSD-3-Clause
pragma solidity 0.8.20;

import "../Interfaces/UniswapV2Interface.sol";
import "../Interfaces/Interfaces.sol";
import "@openzeppelin/contracts/access/Ownable2Step.sol";

abstract contract WETHUtils is IWETH, Ownable2Step {
    //NOTE:Only involves swapping tokens for tokens, any operations involving ETH will be wrap/unwrap calls to WETH contract

    //the WETH address on ***ARBITRUM ONE***
    IWETH WETH = IWETH(0x82aF49447D8a07e3bd95BD0d56f35241523fBab1);

    function wrapEther(uint256 amount) public returns (uint256) {
        (bool sent, ) = address(WETH).call{value: amount}("");
        require(sent, "Failed to send Ether");
        uint256 wethAmount = WETH.balanceOf(address(this));
        return wethAmount;
    }

    function unwrapEther(uint256 amountIn) public returns (uint256) {
        IWETH(address(WETH)).withdraw(amountIn);
        uint256 etherAmount = address(this).balance;
        return etherAmount;
    }

    function withdrawWETH() external onlyOwner {
        uint256 amount = WETH.balanceOf(address(this));
        require(
            WETH.transferFrom(address(this), msg.sender, amount),
            "Transfer must succeed"
        );
    }

    function withdrawETH() external payable onlyOwner {
        uint256 balance = address(this).balance;
        (bool sent, ) = msg.sender.call{value: balance}("");
        require(sent, "Failed to send Ether");
    }
}
