// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {MissionConfig} from "ethos/missions/MissionConfig.sol";

interface IMissionEligibility {
    function isEligible(address user, MissionConfig memory config) external view returns (bool);
}
