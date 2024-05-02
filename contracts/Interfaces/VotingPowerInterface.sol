//SPDX-License-Identifier: BSD-3-Clause
pragma solidity 0.8.20;

interface VotingPowerInterface {
    enum OperationType {
        SUPPLY,
        BORROW
    }

    function vote(
        string[] calldata tokens,
        OperationType[] calldata operations,
        uint256[] calldata shares
    ) external;

    function delegateVotes(address delegatee) external;

    function delegate(address delegatee) external;

    function delegates(address account) external view returns (address);

    function getRawVotingPower(address _user) external view returns (uint256);

    function delegateBySig(
        address delegatee,
        uint256 nonce,
        uint256 expiry,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    function getPastVotes(
        address account,
        uint256 timepoint
    ) external view returns (uint256);

    function lastVotedWeek(address user) external view returns (uint);

    function votingPeriod() external view returns (uint);

    function userVotes(address user, uint period) external view returns (uint);

    function clock() external view returns (uint);

    function getCurrentWeek() external view returns (uint);

    function previouslyVoted(address user) external view returns (bool);

    function getResults()
        external
        view
        returns (string[] memory, OperationType[] memory, uint256[] memory);

    function LODE_SPEED() external view returns (uint256);
}
