// SPDX-License-Identifier: BSD-3-Clause
pragma solidity 0.8.20;

interface GlpOracleInterface {
    function getGLPPrice() external view returns (uint256);

    function getPlvGLPPrice() external view returns (uint256);
}