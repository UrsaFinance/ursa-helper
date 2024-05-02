// SPDX-License-Identifier: BSD-3-Clause
pragma solidity 0.8.20;

// 6/26/2023: https://docs.balancer.fi/reference/contracts/deployment-addresses/mainnet.html#gauges-and-governance
interface ProtocolFeesCollectorInterface {
    function getFlashLoanFeePercentage() external view returns (uint256);
}