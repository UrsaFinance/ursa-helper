//SPDX-License-Identifier: BSD-3-Clause
pragma solidity 0.8.20;

import "./LiquidityUtilsConstants.sol";

// TODO: add ownable?
contract LiquidityUtils is LiquidityUtilsConstants {
    /**
     * @notice Simulates a leveraged position or looping operation and checks whether the user can perform it with their current balance
     * @param _token The underlying token that the user wants to leverage
     * @param _lTokenToBorrow The lToken that the user wants to borrow
     * @param _amount The amount of the token that the user wants to use
     * @param _decimals The decimals of the token to borrow
     * @param _collateralFactor The collateral factor of the asset you are supplying (example: 750000000000000000, which equates to 75%)
     * @param _leverage The desired leverage
     * @param _divisor The divisor used in the leverage computation (example: 1e4)
     * @param _user The user's address
     * @param _protocolFeePercentage The protocol fee percentage (example: 25, which equates to .0025%)
     * @return 0 if the operation can be performed, 1 otherwise
     * The Ursa Unitroller, Price Oracle, PlvGlp Oracle, Balancer Vault, Balancer Fees Collector, lPLVGLP and lUSDC contracts must be defined by the child contract.
     */
    function mockPositionOperation(
        IERC20 _token,
        IERC20 _lTokenToBorrow,
        uint256 _amount,
        uint8 _decimals,
        uint64 _collateralFactor,
        uint16 _leverage,
        uint16 _divisor,
        address _user,
        uint256 _protocolFeePercentage
    ) external view returns (uint256) {
        {
            uint256 hypotheticalSupply;
            uint256 decimalScale;
            uint256 decimalExp;
            uint256 tokenDecimals;
            uint256 price;

            (
                uint256 loanAmount, // IERC20 tokenToBorrow

            ) = getNotionalLoanAmountIn1e18(
                    _token,
                    _amount,
                    _leverage,
                    _divisor
                );

            loanAmount =
                (loanAmount * (10000 + _protocolFeePercentage)) /
                10000;

            // mock a hypothetical borrow to see what state it puts the account in (before factoring in our new liquidity)
            (
                ,
                uint256 hypotheticalLiquidity,
                uint256 hypotheticalShortfall
            ) = UNITROLLER.getHypotheticalAccountLiquidity(
                    _user,
                    address(_lTokenToBorrow),
                    0,
                    loanAmount
                );

            // if the account is still healthy without factoring in our newly supplied balance, we know for a fact they can support this operation.
            // so let's just return now and not waste any more time
            if (hypotheticalLiquidity > 0) {
                return 0; // pass
            } else {
                // otherwise, lets do some maths
                // lets get our hypotheticalSupply and see if it's greater than our hypotheticalShortfall
                // if it is, we know the account can support this operation
                if (_token == PLVGLP) {
                    uint256 plvGLPPriceInEth = PLVGLP_ORACLE.getPlvGLPPrice();
                    tokenDecimals = (10 ** 18);
                    hypotheticalSupply =
                        (plvGLPPriceInEth *
                            (loanAmount * (_collateralFactor / 1e18))) /
                        tokenDecimals;
                } else {
                    // tokenToBorrow should equal _token in every instance that doesn't involve plvGLP (which borrows USDC)
                    uint256 tokenPriceInEth = PRICE_ORACLE.getUnderlyingPrice(
                        address(_lTokenToBorrow)
                    );
                    decimalScale = 18 - _decimals;
                    decimalExp = (10 ** decimalScale);
                    price = tokenPriceInEth / decimalExp;
                    tokenDecimals = (10 ** _decimals);
                    hypotheticalSupply =
                        (price * (loanAmount * (_collateralFactor / 1e18))) /
                        tokenDecimals;
                }

                if (hypotheticalSupply > hypotheticalShortfall) {
                    return 0; // pass
                } else {
                    return 1; // fail
                }
            }
        }
    }

    /**
     * @dev Calculates the notional loan amount in a specific token, taking into account the specified leverage.
     * The notional loan amount is a way of calculating a loan amount that represents the underlying value of the loan,
     * considering the token and the leverage used.
     * @param _token The ERC20 token for which the notional loan amount is to be calculated.
     * @param _amount The quantity of the token.
     * @param _leverage The leverage factor to apply to the loan amount.
     * @return _loanAmount The calculated notional loan amount.
     * @return _tokenToBorrow The ERC20 token to be borrowed.
     *
     * This function checks for the token type and applies different logic based on the type:
     * 1. For PLVGLP, the token price in Ethereum (ETH) and the USDC price in ETH are used to compute the loan amount.
     * 2. For USDC_NATIVE, the function calculates the loan amount based on the given amount and the leverage.
     * 3. For any other tokens, the function assumes that the loan will be in the supplied token and uses the given amount and the leverage to calculate the loan amount.
     */
    function getNotionalLoanAmountIn1e18(
        IERC20 _token,
        uint256 _amount,
        uint16 _leverage,
        uint16 _divisor
    ) private view returns (uint256, IERC20) {
        // declare consts
        IERC20 _tokenToBorrow;
        uint256 _loanAmount;

        if (_token == PLVGLP) {
            uint256 _tokenPriceInEth;
            uint256 _usdcPriceInEth;
            uint256 _computedAmount;

            // constant used for converting plvGLP to USDC
            uint256 PLVGLP_DIVISOR = 1e30;

            // plvGLP borrows USDC to loop
            _tokenToBorrow = USDC_BRIDGED;
            _tokenPriceInEth = PRICE_ORACLE.getUnderlyingPrice(
                address(lPLVGLP)
            );
            _usdcPriceInEth = (PRICE_ORACLE.getUnderlyingPrice(address(lUSDC)) /
                1e12);
            _computedAmount =
                (_amount * ((_tokenPriceInEth * 1e18) / _usdcPriceInEth)) /
                PLVGLP_DIVISOR;

            _loanAmount = _getNotionalLoanAmountIn1e18(
                _computedAmount,
                _leverage,
                _divisor
            );
        } else if (_token == USDC_NATIVE) {
            _tokenToBorrow = USDC_BRIDGED;
            _loanAmount = _getNotionalLoanAmountIn1e18(
                _amount, // we can just send over the exact amount
                _leverage,
                _divisor
            );
        } else {
            // the rest of the contracts just borrow whatever token is supplied
            _tokenToBorrow = _token;
            _loanAmount = _getNotionalLoanAmountIn1e18(
                _amount, // we can just send over the exact amount
                _leverage,
                _divisor
            );
        }

        return (_loanAmount, _tokenToBorrow);
    }

    /**
     * @dev Internal helper function that calculates the notional loan amount based on the token quantity and the leverage.
     * @param _notionalTokenAmountIn1e18 The quantity of the token, represented in a denomination of 1e18.
     * @param _leverage The leverage factor to apply to the loan amount.
     * @return The notional loan amount, computed by multiplying the notional token amount by the leverage factor (minus the divisor), then dividing by the divisor.
     *
     * The `unchecked` block is used to ignore overflow errors. This is because the operation of multiplying the leverage and the notional token amount may cause an overflow.
     * The function assumes that the inputs (_notionalTokenAmountIn1e18 and _leverage) have been validated beforehand.
     */
    function _getNotionalLoanAmountIn1e18(
        uint256 _notionalTokenAmountIn1e18,
        uint16 _leverage,
        uint16 _divisor
    ) private pure returns (uint256) {
        unchecked {
            return
                ((_leverage - _divisor) * _notionalTokenAmountIn1e18) /
                _divisor;
        }
    }
}
