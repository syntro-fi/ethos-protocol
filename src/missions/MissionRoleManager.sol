// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AccessControl} from "openzeppelin/contracts/access/AccessControl.sol";
import {IAuthentication} from "ethos/modules/interfaces/IAuthentication.sol";

error ManagerAuthenticationFailed();
error VerifierAuthenticationFailed();
error ContributorAuthenticationFailed();

abstract contract MissionRoleManager is AccessControl {
    bytes32 public constant SPONSOR_ROLE = keccak256("SPONSOR_ROLE");
    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");
    bytes32 public constant VERIFIER_ROLE = keccak256("VERIFIER_ROLE");
    bytes32 public constant CONTRIBUTOR_ROLE = keccak256("CONTRIBUTOR_ROLE");

    IAuthentication public authModule;

    constructor(address _authModule) {
        authModule = IAuthentication(_authModule);
    }

    function _setupInitialRoles(address _owner, address _sponsor) internal {
        _grantRole(DEFAULT_ADMIN_ROLE, _owner);
        _grantRole(SPONSOR_ROLE, _owner);
        _grantRole(MANAGER_ROLE, _owner);
        _grantRole(SPONSOR_ROLE, _sponsor);
        _grantRole(MANAGER_ROLE, _sponsor);
    }

    function grantManagerRole(address _manager) external onlyRole(SPONSOR_ROLE) {
        _authenticateManager(_manager);
        _grantRole(MANAGER_ROLE, _manager);
    }

    function revokeManagerRole(address _manager) external onlyRole(SPONSOR_ROLE) {
        _revokeRole(MANAGER_ROLE, _manager);
    }

    function grantVerifierRole(address _verifier) external onlyRole(MANAGER_ROLE) {
        _authenticateVerifier(_verifier);
        _grantRole(VERIFIER_ROLE, _verifier);
    }

    function revokeVerifierRole(address _verifier) external onlyRole(MANAGER_ROLE) {
        _revokeRole(VERIFIER_ROLE, _verifier);
    }

    function _grantContributorRole(address _contributor) internal onlyRole(MANAGER_ROLE) {
        _authenticateContributor(_contributor);
        _grantRole(CONTRIBUTOR_ROLE, _contributor);
    }

    function revokeContributorRole(address _contributor) external onlyRole(MANAGER_ROLE) {
        _revokeRole(CONTRIBUTOR_ROLE, _contributor);
    }

    function _authenticateContributor(address _contributor) internal view {
        if (!authModule.authenticateContributor(_contributor))
            revert ContributorAuthenticationFailed();
    }

    function _authenticateVerifier(address _verifier) internal view {
        if (!authModule.authenticateVerifier(_verifier)) revert VerifierAuthenticationFailed();
    }

    function _authenticateManager(address _manager) internal view {
        if (!authModule.authenticateManager(_manager)) revert ManagerAuthenticationFailed();
    }
}
