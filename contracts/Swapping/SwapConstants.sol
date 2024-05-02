//SPDX-License-Identifier: BSD-3-Clause
pragma solidity 0.8.20;

import "../Interfaces/ISwapRouter.sol";
import "../Interfaces/Interfaces.sol";

contract SwapConstants {
    IERC20 internal constant GLP =
        IERC20(0x1aDDD80E6039594eE970E5872D247bf0414C8903);
    IWETH internal constant WETH =
        IWETH(0x82aF49447D8a07e3bd95BD0d56f35241523fBab1);

    ISwapRouter internal constant UNI_ROUTER =
        ISwapRouter(0xE592427A0AEce92De3Edee1F18E0157C05861564);
    SushiRouterInterface internal constant SUSHI_ROUTER =
        SushiRouterInterface(0x1b02dA8Cb0d097eB8D57A175b88c7D8b47997506);
    SushiRouterInterface FRAX_ROUTER =
        SushiRouterInterface(0xCAAaB0A72f781B92bA63Af27477aA46aB8F653E7);
    CurveInterface CURVE_WSTETH_POOL =
        CurveInterface(0x4c2Af2Df2a7E567B5155879720619EA06C5BB15D);
    IPlutusDepositor PLUTUS_DEPOSITOR =
        IPlutusDepositor(0xEAE85745232983CF117692a1CE2ECf3d19aDA683);
    IGLPRouter GLP_ROUTER =
        IGLPRouter(0xB95DB5B167D75e6d04227CfFFA61069348d271F5);
}
