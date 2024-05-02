// SPDX-License-Identifier: BSD-3-Clause
pragma solidity 0.8.20;

interface SushiRouterInterface {
    function WETH() external returns (address);

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        fixed swapAmountETH,
        uint256 amountOutMin,
        address[] memory path,
        address to,
        uint256 deadline
    ) external;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] memory path,
        address to,
        uint256 deadline
    ) external;

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] memory path,
        address to,
        uint256 deadline
    ) external;
}