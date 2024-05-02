// SPDX-License-Identifier: BSD-3-Clause
pragma solidity 0.8.20;

interface PriceOracleProxyETHInterface {
    function getUnderlyingPrice(address lToken) external view returns (uint256);

    struct AggregatorInfo {
        address source;
        uint8 base;
    }

    function aggregators(
        address lToken
    ) external returns (AggregatorInfo memory);
}