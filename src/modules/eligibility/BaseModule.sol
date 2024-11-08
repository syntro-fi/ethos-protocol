// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {MissionConfig, MissionConfigValidator} from "ethos/missions/MissionConfig.sol";
import {ZeroAddress} from "ethos/Errors.sol";

import {IMissionEligibility} from "ethos/missions/interfaces/IMissionEligibility.sol";

abstract contract BaseModule is IMissionEligibility {
    function check(address user, MissionConfig calldata config) public view virtual override {
        if (user == address(0)) revert ZeroAddress();
        MissionConfigValidator.validate(config);
        // Default implementation always succeeds for non-zero addresses
    }
}
