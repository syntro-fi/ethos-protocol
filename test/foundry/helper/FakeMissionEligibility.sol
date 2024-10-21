// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IMissionEligibility} from "ethos/modules/interfaces/IMissionEligibility.sol";
import {MissionConfig} from "ethos/missions/MissionConfig.sol";

contract FakeMissionEligibility is IMissionEligibility {
    bool private _isEligible;

    function isEligible(address, MissionConfig memory) external view override returns (bool) {
        return _isEligible;
    }

    function setEligible(bool eligible) external {
        _isEligible = eligible;
    }
}
