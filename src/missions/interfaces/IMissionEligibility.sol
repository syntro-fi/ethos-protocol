// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {MissionConfig} from "../MissionConfig.sol";

interface IMissionEligibility {
    function check(address user, MissionConfig calldata config) external view;
}
