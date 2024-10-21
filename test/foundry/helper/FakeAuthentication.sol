// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IAuthentication} from "ethos/modules/interfaces/IAuthentication.sol";

contract FakeAuthentication is IAuthentication {
    mapping(address => bool) public authedManagers;
    mapping(address => bool) public authedVerifiers;
    mapping(address => bool) public authedContributors;

    // @dev impement IAuthentication
    function authenticateManager(address _manager) external view override returns (bool) {
        return authedManagers[_manager];
    }

    function authenticateVerifier(address _verifier) external view override returns (bool) {
        return authedVerifiers[_verifier];
    }

    function authenticateContributor(address _contributor) external view override returns (bool) {
        return authedContributors[_contributor];
    }

    // @dev test helper functions
    function setAuthedManager(address _manager, bool _isAuthed) external {
        authedManagers[_manager] = _isAuthed;
    }

    function setAuthedVerifier(address _verifier, bool _isAuthed) external {
        authedVerifiers[_verifier] = _isAuthed;
    }

    function setAuthedContributor(address _contributor, bool _isAuthed) external {
        authedContributors[_contributor] = _isAuthed;
    }
}
