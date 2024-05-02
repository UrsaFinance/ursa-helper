//SPDX-License-Identifier: BSD-3-Clause
pragma solidity 0.8.20;

interface IUrsa {
    function allowance(
        address account,
        address spender
    ) external view returns (uint);

    function approve(address spender, uint rawAmount) external returns (bool);

    function balanceOf(address account) external view returns (uint);

    function transfer(address dst, uint rawAmount) external returns (bool);

    function transferFrom(
        address src,
        address dst,
        uint rawAmount
    ) external returns (bool);

    function delegate(address delegatee) external;

    function delegateBySig(
        address delegatee,
        uint nonce,
        uint expiry,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    function getCurrentVotes(address account) external view returns (uint96);

    function getPriorVotes(
        address account,
        uint blockNumber
    ) external view returns (uint96);
}