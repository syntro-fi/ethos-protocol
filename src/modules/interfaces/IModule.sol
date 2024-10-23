// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IModule {
    /// @notice Returns a unique identifier for this module
    /// @return A 4-byte identifier for the module
    function moduleId() external pure returns (bytes4);
}
