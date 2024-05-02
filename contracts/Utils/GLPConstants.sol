//SPDX-License-Identifier: BSD-3-Clause
pragma solidity 0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../Interfaces/GLPInterfaces.sol";

contract SwapConstants {
    IERC20 internal constant GLP =
        IERC20(0x4277f8F2c384827B5273592FF7CeBd9f2C1ac258);
    IGLPManager GLP_MANAGER =
        IGLPManager(0x321F653eED006AD1C29D174e17d96351BDe22649);
    IGLPRewardTracker GLP_REWARD_TRACKER =
        IGLPRewardTracker(0x4e971a87900b931fF39d1Aad67697F49835400b6);
    IGLPVault GLP_VAULT = IGLPVault(0x489ee077994B6658eAfA855C308275EAd8097C4A);
}
