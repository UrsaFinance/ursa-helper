// SPDX-License-Identifier: BSD-3-Clause
pragma solidity 0.8.20;

interface IPlutusDepositor {
    function redeem(uint256 amount) external;

    function redeemAll() external;
}

interface IGLPRouter {
    function unstakeAndRedeemGlpETH(
        uint256 _glpAmount,
        uint256 _minOut,
        address payable _receiver
    ) external returns (uint256);

    function unstakeAndRedeemGlp(
        address tokenOut,
        uint256 glpAmount,
        uint256 minOut,
        address receiver
    ) external returns (uint256);
}

interface IGLPRewardTracker {
    function tokensPerInterval() external view returns (uint256);
}

interface IGLPManager {
    function getAums() external view returns (uint256[] memory);
}

interface IGLPVault {
    function getMinPrice(address _token) external view returns (uint256);
}

interface IGLP {
    function totalSupply() external view returns (uint256);
}
