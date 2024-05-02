//SPDX-License-Identifier: BSD-3-Clause
pragma solidity 0.8.20;

import "./ICERC20.sol";

interface ICETH is ICERC20 {
    function liquidateBorrow(
        address borrower,
        ICERC20 cTokenCollateral
    ) external payable;
}