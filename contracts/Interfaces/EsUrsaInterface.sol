//SPDX-License-Identifier: BSD-3-Clause
pragma solidity 0.8.20;

import "./ERC20/IERC20Extended.sol";

interface IesLODE is IERC20Extended {
    function balanceOf(address account) external view returns (uint256);

    function totalSupply() external view returns (uint256);
}
