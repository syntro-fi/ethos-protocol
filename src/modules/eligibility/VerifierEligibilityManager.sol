// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AbstractEligibilityModuleManager} from "./AbstractEligibilityModuleManager.sol";

contract VerifierEligibilityManager is AbstractEligibilityModuleManager {
    constructor(address _sponsor) AbstractEligibilityModuleManager(_sponsor) {}

    function _getUserType() internal pure override returns (UserType) {
        return UserType.Verifier;
    }
}
