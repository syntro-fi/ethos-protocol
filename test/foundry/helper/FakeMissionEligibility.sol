// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IMissionEligibility} from "ethos/modules/interfaces/IMissionEligibility.sol";
import {NotEligible} from "ethos/modules/eligibility/Errors.sol";
import {MissionConfig} from "ethos/missions/MissionConfig.sol";

contract FakeMissionEligibility is IMissionEligibility {
    bool private _isEligible;

    function check(address, MissionConfig memory) external view override {
        if (!_isEligible) revert NotEligible();
    }

    function setEligible(bool eligible) external {
        _isEligible = eligible;
    }
}
