// SPDX-License-Identifier: BSD-3-Clause
pragma solidity 0.8.20;

interface CurveInterface {
    function exchange_multiple(
        address[9] memory,
        uint256[3][4] memory,
        uint256,
        uint256,
        address[4] memory
    ) external;
}