//SPDX-License-Identifier: BSD-3-Clause
pragma solidity 0.8.20;

interface ComptrollerInterface {
    function claimComp(address holder) external;

    function enterMarkets(
        address[] calldata cTokens
    ) external returns (uint[] memory);

    function exitMarket(address cToken) external returns (uint);

    function enableLooping(bool state) external returns (bool);

    function isLoopingEnabled(address user) external view returns (bool);

    function getAccountLiquidity(
        address account
    ) external view returns (uint, uint, uint);

    function getHypotheticalAccountLiquidity(
        address account,
        address cTokenModify,
        uint redeemTokens,
        uint borrowAmount
    ) external view returns (uint, uint, uint);

    function checkMembership(
        address account,
        address cToken
    ) external view returns (bool);

    function oracle() external view returns (address);

    function markets(
        address cToken
    ) external view returns (bool, uint256, bool);

    function compAccrued(address user) external view returns (uint256);

    function compBorrowSpeeds(address market) external view returns (uint256);

    function compSupplySpeeds(address market) external view returns (uint256);

    function borrowCaps(address market) external view returns (uint256);

    function supplyCaps(address market) external view returns (uint256);
}
