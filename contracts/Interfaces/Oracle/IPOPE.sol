//SPDX-License-Identifier: BSD-3-Clause
pragma solidity 0.8.20;

interface IPOPE {
    function getUnderlyingPrice(address cToken) external view returns (uint256);

    function ethUsdAggregator() external view returns (address);
}