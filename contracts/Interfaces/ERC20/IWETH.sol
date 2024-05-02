//SPDX-License-Identifier: BSD-3-Clause
pragma solidity 0.8.20

interface IWETH is IERC20 {
    function deposit() external payable;

    function withdraw(uint256 amount) external;
}