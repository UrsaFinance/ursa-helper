//SPDX-License-Identifier: BSD-3-Clause
pragma solidity 0.8.20;

import "./ERC20/IERC20Extended.sol";

interface StakingRewardsInterface is IERC20Extended {
    struct StakingInfo {
        uint256 lodeAmount;
        uint256 stLODEAmount;
        uint256 startTime;
        uint256 lockTime;
        uint256 relockStLODEAmount;
        uint256 nextStakeId;
        uint256 totalEsLODEStakedByUser;
        uint256 threeMonthRelockCount;
        uint256 sixMonthRelockCount;
    }

    function stakeLODE(uint256 amount, uint256 lockTime) external;

    function unstakeLODE(uint256 amount) external;

    function convertEsLODEToLODE() external returns (uint256);

    function relock(uint256 lockTime) external;

    function claimRewards() external;

    function getStLODEAmount(address _address) external view returns (uint256);

    function getStLodeLockTime(
        address _address
    ) external view returns (uint256);

    function getEsLODEStaked(address _address) external view returns (uint256);

    function stakers(address user) external view returns (StakingInfo memory);

    function pendingRewards(
        address _user
    ) external view returns (uint256 _pendingweth);

    function totalStaked() external view returns (uint256);

    function totalEsLODEStaked() external view returns (uint256);

    function weeklyRewards() external view returns (uint256);
}