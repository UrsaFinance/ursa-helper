//SPDX-License-Identifier: BSD-3-Clause
pragma solidity 0.8.20;

import "../Interfaces/IUrsaAggregator.sol";
import "../Interfaces/Interfaces.sol";
import "../Utils/CompareStrings.sol";

contract UrsaAggregatorHelper is CompareStrings {
    function swap(
        IUrsaAggregator aggregator,
        address _tokenA,
        address _tokenB,
        uint256 _amountIn,
        uint256 _amountOut,
        address _to
    ) internal {
        uint256 maxSteps = 4;
        FormattedOffer memory offer = aggregator.findBestPath(
            _amountIn,
            _tokenA,
            _tokenB,
            maxSteps
        );
        address[] memory path = offer.path;
        address[] memory adapters = offer.adapters;

        string memory tokenASymbol = IERC20Extended(_tokenA).symbol();
        string memory tokenBSymbol = IERC20Extended(_tokenB).symbol();

        string memory WETH = "WETH";

        Trade memory trade;

        trade.amountIn = _amountIn;
        trade.amountOut = _amountOut;
        trade.adapters = adapters;
        trade.path = path;

        if (compareStrings(tokenASymbol, WETH)) {
            //swap is going from WETH to token B
            aggregator.swapNoSplitFromAVAX(trade, _to, 0);
        } else if (compareStrings(tokenBSymbol, WETH)) {
            //swap is going from token A to WETH
            aggregator.swapNoSplitToAVAX(trade, _to, 0);
        } else {
            //swap is going from erc20 to erc20
            aggregator.swapNoSplit(trade, _to, 0);
        }
    }
}
