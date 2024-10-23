// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IModule} from "ethos/modules/interfaces/IModule.sol";
import {MissionConfig} from "ethos/missions/MissionConfig.sol";

import {BaseModule} from "./BaseModule.sol";

contract AlwaysEligibleModule is BaseModule, IModule {
    function moduleId() public pure override returns (bytes4) {
        return bytes4(keccak256("AlwaysEligibleModule"));
    }

    function check(address user, MissionConfig calldata config) public view override(BaseModule) {
        super.check(user, config);
        // Always eligible; NOP
    }
}
