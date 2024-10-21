// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title IAuthentication
/// @notice Interface for authenticating contributors, verifiers and managers. This
//          could be checking a government id, a unique phone number or something more elaborate
interface IAuthentication {
    /// @notice Verifies if a given address passes the KYC checks required for contributors
    /// @param walletAddress The address to authenticate
    /// @return bool True if the address passes KYC checks, false otherwise
    function authenticateContributor(address walletAddress) external view returns (bool);

    /// @notice Verifies if a given address passes the KYC checks required for an verifier
    /// @param walletAddress The address to authenticate
    /// @return bool True if the address passes KYC checks, false otherwise
    function authenticateVerifier(address walletAddress) external view returns (bool);

    /// @notice Verifies if a given address passes the KYC checks required for a manager
    /// @param walletAddress The address to authenticate
    /// @return bool True if the address passes KYC checks, false otherwise
    function authenticateManager(address walletAddress) external view returns (bool);
}
