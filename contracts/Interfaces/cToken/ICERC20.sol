//SPDX-License-Identifier: BSD-3-Clause
pragma solidity 0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface ICERC20 is IERC20 {
    // CToken
    /**
     * @notice Get the underlying balance of the `owner`
     * @dev This also accrues interest in a transaction
     * @param owner The address of the account to query
     * @return The amount of underlying owned by `owner`
     */
    function balanceOfUnderlying(address owner) external returns (uint256);

    /**
     * @notice Returns the current per-block borrow interest rate for this cToken
     * @return The borrow interest rate per block, scaled by 1e18
     */
    function borrowRatePerBlock() external view returns (uint256);

    /**
     * @notice Returns the current per-block supply interest rate for this cToken
     * @return The supply interest rate per block, scaled by 1e18
     */
    function supplyRatePerBlock() external view returns (uint256);

    /**
     * @notice Accrue interest then return the up-to-date exchange rate
     * @return Calculated exchange rate scaled by 1e18
     */
    function exchangeRateCurrent() external returns (uint256);

    // Cerc20
    function mint(uint256 mintAmount) external returns (uint256);

    function redeem(uint256 redeemTokens) external returns (uint256);

    function underlying() external view returns (address);

    function liquidateBorrow(
        address borrower,
        uint256 repayAmount,
        address cTokenCollateral
    ) external;

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function approve(address spender, uint256 amount) external returns (bool);

    function getAccountSnapshot(address account) external view returns (uint, uint, uint, uint);

    function totalBorrows() external view returns (uint);
    
    function totalSupply() external view returns (uint);

    function totalReserves() external view returns (uint);

    function getCash() external view returns (uint);

    function reserveFactorMantissa() external view returns (uint);

    function interestRateModel() external view returns (address);

    function exchangeRateStored() external view returns (uint);

    function accrualBlockNumber() external view returns (uint);

    function addReserves(uint256 amount) external returns (uint);

    function borrowBalanceStored(address user) external view returns (uint);
}
