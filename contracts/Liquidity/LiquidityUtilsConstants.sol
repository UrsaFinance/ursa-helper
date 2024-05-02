//SPDX-License-Identifier: BSD-3-Clause
pragma solidity 0.8.20;

import {IVault} from "../Interfaces/IVault.sol";
import {GlpOracleInterface, PriceOracleProxyETHInterface, ProtocolFeesCollectorInterface, ICERC20, IERC20} from "../Interfaces/Interfaces.sol";
import {ComptrollerInterface} from "../Interfaces/UrsaInterfaces.sol";

contract LiquidityUtilsConstants {
    PriceOracleProxyETHInterface PRICE_ORACLE;
    IVault BALANCER_VAULT;
    GlpOracleInterface PLVGLP_ORACLE;
    ProtocolFeesCollectorInterface BALANCER_PROTOCOL_FEES_COLLECTOR;
    ComptrollerInterface UNITROLLER;
    ICERC20 lPLVGLP;
    ICERC20 lUSDC;

    // ComptrollerInterface internal constant UNITROLLER =
    //     ComptrollerInterface(0xa86DD95c210dd186Fa7639F93E4177E97d057576);
    // GlpOracleInterface internal constant PLVGLP_ORACLE =
    //     GlpOracleInterface(0x5ba0828A5488c20a9C6521a90ecc9c49e5390604);
    // PriceOracleProxyETHInterface internal constant PRICE_ORACLE =
    //     PriceOracleProxyETHInterface(
    //         0xcCf9393df2F656262FD79599175950faB4D4ec01
    //     );

    IERC20 internal constant USDC_BRIDGED =
        IERC20(0xFF970A61A04b1cA14834A43f5dE4533eBDDB5CC8);
    IERC20 internal constant USDC_NATIVE =
        IERC20(0xaf88d065e77c8cC2239327C5EDb3A432268e5831);
    IERC20 internal constant PLVGLP =
        IERC20(0x5326E71Ff593Ecc2CF7AcaE5Fe57582D6e74CFF1);

    // ICERC20 internal constant lPLVGLP =
    //     ICERC20(0xeA0a73c17323d1a9457D722F10E7baB22dc0cB83);
    // ICERC20 internal constant lUSDC =
    //     ICERC20(0x4C9aAed3b8c443b4b634D1A189a5e25C604768dE);

    // BALANCER
    // IVault internal constant BALANCER_VAULT =
    //     IVault(0xBA12222222228d8Ba445958a75a0704d566BF2C8);
    // IProtocolFeesCollector internal constant BALANCER_PROTOCOL_FEES_COLLECTOR =
    //     IProtocolFeesCollector(0xce88686553686DA562CE7Cea497CE749DA109f9F);

    // ORACLES
    // IGlpOracleInterface internal constant PLVGLP_ORACLE =
    //     IGlpOracleInterface(0x5ba0828A5488c20a9C6521a90ecc9c49e5390604);
    // IPriceOracleProxyETH internal constant PRICE_ORACLE =
    //     IPriceOracleProxyETH(0xcCf9393df2F656262FD79599175950faB4D4ec01);
}
