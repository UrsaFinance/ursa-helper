//SPDX-License-Identifier: BSD-3-Clause
pragma solidity 0.8.20;

abstract contract CompareStrings {
    function compareStrings(
        string memory a,
        string memory b
    ) internal pure returns (bool) {
        if (keccak256(bytes(a)) == keccak256(bytes(b))) {
            return true;
        } else {
            return false;
        }
    }
}
