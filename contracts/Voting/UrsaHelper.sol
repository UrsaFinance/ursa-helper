//SPDX-License-Identifier: BSD-3-Clause
pragma solidity 0.8.20;

import "./UrsaHelperConstants.sol";

/**
 * @title Ursa Helper
 * @author Ursa Finance
 * @notice This contract is meant to serve as a source of guidance or to help third parties execute
    pre-defined strategies within the protocol. The executeStrategy function performs the following
    functions:
        -claim LODE from money markets if there is any to claim
        -relocks currently staked LODE for current lock time if applicable
        -stakes the contract's current LODE balance for current lock time if applicable
        -votes with pre-defined strategy
        -claims WETH rewards from staking contract
    The contract also has a function to delegate the contract's voting power to itself to enable voting.
    The contract must stake and lock LODE and delegate voting power prior to executing a strategy.
    All functions are virtual and can be overridden by the child contract's owner.
    The Ursa Staking, Voting, Unitroller, and Lens contracts must be defined by the child contract.
 */
abstract contract UrsaHelper is UrsaHelperConstants {
    /**
     * @notice Claims WETH rewards from staking
     */
    function claimStakingRewards() internal virtual {
        STAKING.claimRewards();
    }

    /**
     * @notice Claims LODE rewards from Ursa Markets
     */
    function claimMarketRewards(address user) internal virtual {
        UNITROLLER.claimComp(user);
    }

    /**
     * @notice Stakes LODE tokens
     * @param amount the amount of LODE to stake
     * @param lockTime the lock time (in seconds), can only be 10 seconds, 90 days or 180 days
     */
    function stakeLODE(uint256 amount, uint256 lockTime) internal virtual {
        require(
            lockTime == 10 seconds ||
                lockTime == 90 days ||
                lockTime == 180 days,
            "Invalid Lock Time"
        );
        uint256 balance = LODE.balanceOf(address(this));
        require(amount <= balance, "Invalid Stake Amount");
        STAKING.stakeLODE(amount, lockTime);
    }

    /**
     * @notice Relock LODE tokens for boosted rewards
     * @param _lockTime the lock time to relock the staked position for, same input options as staking function
     */
    function relock(address user, uint256 _lockTime) internal virtual {
        require(
            _lockTime == 90 days || _lockTime == 180 days,
            "Invalid relock time"
        );
        uint256 lockTime = STAKING.getStLodeLockTime(user);
        require(isEligibleForRelock(user), "Not Eligible for Relock");
        STAKING.relock(lockTime);
    }

    /**
     * @notice Function to check if given acocunt is eligible for relocking or not
     * @param account the account to check eligibility for
     * @return true = eligible, false = ineligible
     */
    function isEligibleForRelock(
        address account
    ) internal view virtual returns (bool) {
        StakingRewardsInterface.StakingInfo memory stakeInfo = STAKING.stakers(
            account
        );
        uint256 lockTime = stakeInfo.lockTime;
        if (lockTime == 10 seconds || lockTime == 0) {
            return false;
        }
        uint256 startTime = stakeInfo.startTime;
        uint256 timeUntilEligible = (lockTime * 80) / 100;
        uint256 eligibleTimestamp = startTime + timeUntilEligible;
        if (block.timestamp >= eligibleTimestamp) {
            return true;
        } else {
            return false;
        }
    }

    /**
     * @notice View function to see pending LODE rewards from Ursa markets
     */
    function getPendingMarketRewards(
        address user
    ) internal virtual returns (uint256) {
        LensInterface.CompBalanceMetadataExt memory marketRewardsData = LENS
            .getCompBalanceMetadataExt(
                address(LODE),
                address(UNITROLLER),
                user
            );
        return marketRewardsData.allocated;
    }

    /**
     * @notice View function to see pending WETH rewards from Ursa markets
     */
    function getPendingStakingRewards(
        address user
    ) internal virtual returns (uint256) {
        return STAKING.pendingRewards(user);
    }

    /**
     * @notice Delegate voting power to yourself (the contract)
     */
    function delegateVotingPower(address user) internal virtual {
        address currentDelegate = VOTING.delegates(user);
        if (currentDelegate == address(0) || currentDelegate != user) {
            VOTING.delegate(user);
        } else {
            return;
        }
    }

    /**
     * @notice Function to set voting strategy. Intended to be used for initialization but can also be used to add multiple tokens/operations at once
     * @param _tokens array of token name strings
     * @param _operations array of desired operations (1 for supply 2 for borrow)
     * @param _allocations the allocations of voting power to give each token/operation in % mantissa (e.g. 50% is 500000000000000000)
     */
    function setStrategy(
        string[] memory _tokens,
        VotingPowerInterface.OperationType[] memory _operations,
        uint256[] memory _allocations
    ) internal virtual {
        require(
            _tokens.length == _operations.length &&
                _tokens.length == _allocations.length,
            "Mismatched Data"
        );
        for (uint i = 0; i < _tokens.length; i++) {
            setStrategyforToken(_tokens[i], _operations[i], _allocations[i]);
        }
    }

    /**
     * @notice set strategy for one token. Can either be new or currently stored token
     * @param token the string name of the token
     * @param operation the operation being stored for the token
     * @param allocation the allocation being given to the token/operation in % mantissa (e.g. 50% is 500000000000000000)
     */
    function setStrategyforToken(
        string memory token,
        VotingPowerInterface.OperationType operation,
        uint256 allocation
    ) internal virtual {
        uint256 totalShareAllocated;

        if (strategies.length == 0) {
            require(allocation < BASE, "Max voting power exceeded");
            strategies[strategies.length] = Strategy(
                token,
                operation,
                allocation
            );
            return;
        }

        bytes memory hypotheticalStrategy = abi.encode(
            Strategy(token, operation, allocation)
        );

        if (isIncluded[hypotheticalStrategy]) {
            //if it is included, we need to remove the old allocation, add the new one and make sure that it doesnt exceed 100% voting power.
            for (uint i = 0; i < strategies.length; i++) {
                //get current total including what is to be removed later
                totalShareAllocated += strategies[i].allocation;
            }
            //add currently desired allocation
            totalShareAllocated += allocation;
            for (uint i = 0; i < strategies.length; i++) {
                //find the strategy in the strategy storage array
                bytes memory strategyEncoded = abi.encode(strategies[i]);
                if (
                    keccak256(strategyEncoded) ==
                    keccak256(hypotheticalStrategy)
                ) {
                    uint256 currentStrategyAllocation = strategies[i]
                        .allocation;
                    //remove allocation for this particular strategy from total and make sure total at this point does not exceed 100% voting power.
                    totalShareAllocated -= currentStrategyAllocation;
                    require(
                        totalShareAllocated <= BASE,
                        "Max voting power exceeded. Modify existing strategy."
                    );
                    strategies[i] = Strategy(token, operation, allocation);
                }
            }
        } else {
            //if this strategy has not been added, we need to make sure adding it will not exceed 100% voting power
            for (uint i = 0; i < strategies.length; i++) {
                totalShareAllocated += strategies[i].allocation;
            }
            totalShareAllocated += allocation;
            require(
                totalShareAllocated <= BASE,
                "Max voting power exceeded. Modify existing strategy."
            );
            strategies[strategies.length] = Strategy(
                token,
                operation,
                allocation
            );
            isIncluded[hypotheticalStrategy] = true;
        }
    }

    /**
     * @notice set strategy for one token. Can either be new or currently stored token
     * @param token the string name of the token
     * @param operation the operation being stored for the token
     * @param allocation the allocation being given to the token/operation in % mantissa (e.g. 50% is 500000000000000000)
     */
    function removeStrategy(
        string memory token,
        VotingPowerInterface.OperationType operation,
        uint256 allocation
    ) internal virtual {
        Strategy memory strategyToBeDeleted;
        Strategy memory strategyToBeMoved;
        uint8 index;
        bytes memory encodedInputStrategy = abi.encode(
            Strategy(token, operation, allocation)
        );
        require(isIncluded[encodedInputStrategy], "Strategy not included");
        for (uint8 i = 0; i < strategies.length; i++) {
            bytes memory strategyEncoded = abi.encode(strategies[i]);
            if (keccak256(strategyEncoded) == keccak256(encodedInputStrategy)) {
                strategyToBeDeleted = strategies[i];
                strategyToBeMoved = strategies[(strategies.length - 1)];
                index = i;
            }
        }
        strategies[index] = strategyToBeMoved;
        strategies[(strategies.length - 1)] = strategyToBeDeleted;

        delete strategies[(strategies.length - 1)];
        isIncluded[encodedInputStrategy] = false;
    }

    /**
     * @notice Vote with pre-determined voting strategy
     * @dev converts stored share in % mantissa to its corresponding amount of voting power
     */
    function voteWithStrategy() internal virtual {
        address delegate = VOTING.delegates(address(this));

        if (delegate != address(this)) {
            delegateVotingPower(address(this));
        }

        uint256 totalVotingPower = VOTING.getPastVotes(
            msg.sender,
            (block.number - 1)
        );

        string[] memory tokens;
        VotingPowerInterface.OperationType[] memory operations;
        uint256[] memory sharesActual;

        for (uint i = 0; i < strategies.length; i++) {
            tokens[i] = strategies[i].tokenSymbol;
            operations[i] = strategies[i].operation;
            sharesActual[i] =
                (totalVotingPower * strategies[i].allocation) /
                BASE;
        }

        VOTING.vote(tokens, operations, sharesActual);
    }

    /**
     * @notice execute strategy (described at top level of contract)
     */
    function executeStrategy() internal virtual {
        if (getPendingMarketRewards(msg.sender) > 0) {
            claimMarketRewards(msg.sender);
        }
        StakingRewardsInterface.StakingInfo memory stakeInfo = STAKING.stakers(
            msg.sender
        );
        uint256 lockTime = stakeInfo.lockTime;
        if (isEligibleForRelock(msg.sender)) {
            relock(msg.sender, lockTime);
        }
        uint256 LODEbalance = LODE.balanceOf(address(this));
        if (LODEbalance > 0) {
            STAKING.stakeLODE(LODEbalance, lockTime);
        }
        if (strategies.length > 0) {
            voteWithStrategy();
        }
        if (getPendingStakingRewards(msg.sender) > 0) {
            claimStakingRewards();
        }
    }
}
