//SPDX-License-Identifier: BSD-3-Clause
pragma solidity 0.8.20;

interface LensInterface {
    struct CompBalanceMetadataExt {
        uint balance;
        uint votes;
        address delegate;
        uint allocated;
    }

    function getCompBalanceMetadataExt(
        address comp,
        address comptroller,
        address account
    ) external returns (CompBalanceMetadataExt memory);
}