//SPDX-License-Identifier: BSD-3-Clause
pragma solidity 0.8.20;

import {ILODE, StakingRewardsInterface, VotingPowerInterface, ComptrollerInterface, LensInterface} from "../Interfaces/UrsaInterfaces.sol";
import "../Interfaces/Interfaces.sol";

contract UrsaHelperConstants {
    IURSA URSA = IURSA(); // TODO: fill me in for ursa
    IWETH WETH = IWETH(); // TODO: fill me in for ursa
    StakingRewardsInterface STAKING;
    VotingPowerInterface VOTING;
    ComptrollerInterface UNITROLLER;
    LensInterface LENS;

    struct CompBalanceMetadataExt {
        uint balance;
        uint votes;
        address delegate;
        uint allocated;
    }

    uint256 constant BASE = 1e8;

    /* string[] tokens;
    OperationType[] operations;
    uint256[] shares; */

    mapping(bytes => bool) public isIncluded;

    struct Strategy {
        string tokenSymbol;
        VotingPowerInterface.OperationType operation;
        uint256 allocation;
    }

    Strategy[] strategies;
}
