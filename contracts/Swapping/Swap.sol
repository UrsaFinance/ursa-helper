//SPDX-License-Identifier: BSD-3-Clause
pragma solidity 0.8.20;

// import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/Ownable2Step.sol";
import "../Interfaces/UniswapV2Interface.sol";
import "../Interfaces/AggregatorV3Interface.sol";
import "./SwapConstants.sol";

// TODO: add Ownable/Ownable2Step
abstract contract Swap is SwapConstants, Ownable2Step {
    function swapThroughUniswap(
        address token0Address,
        address token1Address,
        uint256 amountIn,
        uint256 minAmountOut
    ) internal returns (uint256) {
        uint24 poolFee = 3000;

        ISwapRouter.ExactInputParams memory params = ISwapRouter
            .ExactInputParams({
                path: abi.encodePacked(token0Address, poolFee, token1Address),
                recipient: address(this),
                deadline: block.timestamp,
                amountIn: amountIn,
                amountOutMinimum: minAmountOut
            });

        uint256 amountOut = UNI_ROUTER.exactInput(params);
        return amountOut;
    }

    // NOTE:Only involves swapping tokens for tokens, any operations involving ETH
    // will be wrap/unwrap calls to WETH contract
    function swapThroughSushiswap(
        address token0Address,
        address token1Address,
        uint256 amountIn,
        uint256 minAmountOut
    ) internal {
        address[] memory path = new address[](2);
        path[0] = token0Address;
        path[1] = token1Address;
        address to = address(this);
        uint256 deadline = block.timestamp;
        SUSHI_ROUTER.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            amountIn,
            minAmountOut,
            path,
            to,
            deadline
        );
    }

    function swapThroughFraxswap(
        address token0Address,
        address token1Address,
        uint256 amountIn,
        uint256 minAmountOut
    ) internal {
        address[] memory path = new address[](2);
        path[0] = token0Address;
        path[1] = token1Address;
        address to = address(this);
        uint256 deadline = block.timestamp;
        FRAX_ROUTER.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            amountIn,
            minAmountOut,
            path,
            to,
            deadline
        );
    }

    //function to swap wstETH ONLY
    //if to = true, swap is wstETH -> WETH
    //if to = false, swap is WETH -> wstETH
    //TODO: this is janky af
    function swapThroughCurve(
        uint256 amountIn,
        uint256 minAmountOut,
        bool to
    ) internal {
        address[9] memory route;
        uint256[3][4] memory swapParams;
        address[4] memory pools = [
            0x0000000000000000000000000000000000000000,
            0x0000000000000000000000000000000000000000,
            0x0000000000000000000000000000000000000000,
            0x0000000000000000000000000000000000000000
        ];

        if (to) {
            route = [
                0x82aF49447D8a07e3bd95BD0d56f35241523fBab1,
                0x82aF49447D8a07e3bd95BD0d56f35241523fBab1,
                0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE,
                0x6eB2dc694eB516B16Dc9FBc678C60052BbdD7d80,
                0x5979D7b546E38E414F7E9822514be443A4800529,
                0x0000000000000000000000000000000000000000,
                0x0000000000000000000000000000000000000000,
                0x0000000000000000000000000000000000000000,
                0x0000000000000000000000000000000000000000
            ];

            swapParams = [
                [uint256(0), uint256(0), uint256(15)],
                [uint256(0), uint256(1), uint256(1)],
                [uint256(0), uint256(0), uint256(0)],
                [uint256(0), uint256(0), uint256(0)]
            ];
        } else {
            route = [
                0x5979D7b546E38E414F7E9822514be443A4800529,
                0x6eB2dc694eB516B16Dc9FBc678C60052BbdD7d80,
                0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE,
                0x82aF49447D8a07e3bd95BD0d56f35241523fBab1,
                0x82aF49447D8a07e3bd95BD0d56f35241523fBab1,
                0x0000000000000000000000000000000000000000,
                0x0000000000000000000000000000000000000000,
                0x0000000000000000000000000000000000000000,
                0x0000000000000000000000000000000000000000
            ];

            swapParams = [
                [uint256(1), uint256(0), uint256(1)],
                [uint256(0), uint256(0), uint256(15)],
                [uint256(0), uint256(0), uint256(0)],
                [uint256(0), uint256(0), uint256(0)]
            ];
        }

        CURVE_WSTETH_POOL.exchange_multiple(
            route,
            swapParams,
            amountIn,
            minAmountOut,
            pools
        );
    }

    //unwraps a position in plvGLP to native ETH, must be wrapped into WETH prior to repaying flash loan
    function unwindPlutusPosition() internal {
        PLUTUS_DEPOSITOR.redeemAll();
        uint256 glpAmount = GLP.balanceOf(address(this));
        //TODO: update with a method to calculate minimum out given 2.5% slippage constraints.
        uint256 minOut = 0;
        GLP_ROUTER.unstakeAndRedeemGlp(
            address(WETH),
            glpAmount,
            minOut,
            address(this)
        );
    }

    function plutusRedeem() internal {
        PLUTUS_DEPOSITOR.redeemAll();
    }

    function glpRedeem() internal {
        uint256 balance = GLP.balanceOf(address(this));
        GLP_ROUTER.unstakeAndRedeemGlp(
            address(WETH),
            balance,
            0,
            address(this)
        );
    }

    function wrapEther(uint256 amount) internal returns (uint256) {
        (bool sent, ) = address(WETH).call{value: amount}("");
        require(sent, "Failed to send Ether");
        uint256 wethAmount = WETH.balanceOf(address(this));
        return wethAmount;
    }

    function unwrapEther(uint256 amountIn) internal returns (uint256) {
        WETH.withdraw(amountIn);
        uint256 etherAmount = address(this).balance;
        return etherAmount;
    }

    function withdrawWETH() external onlyOwner {
        uint256 amount = WETH.balanceOf(address(this));
        WETH.transferFrom(address(this), msg.sender, amount);
    }

    function withdrawETH() external payable onlyOwner {
        uint256 balance = address(this).balance;
        (bool sent, ) = msg.sender.call{value: balance}("");
        require(sent, "Failed to send Ether");
    }

    receive() external payable {}
}
