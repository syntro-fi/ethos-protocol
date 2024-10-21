// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AccessControl} from "openzeppelin/contracts/access/AccessControl.sol";

import {ModuleRegistry} from "ethos/modules/ModuleRegistry.sol";
import {Modules} from "ethos/modules/Modules.sol";

import {MissionConfig} from "./MissionConfig.sol";
import {Mission} from "./Mission.sol";

error ModuleRegistryNotProvided();
error EligibilityModuleNotFound();
error AuthenticationModuleNotFound();
error MissionNotFound();

contract MissionFactory is AccessControl {
    ModuleRegistry public moduleRegistry;
    address public owner;

    event MissionCreated(address missionAddress);

    constructor(address _moduleRegistry) {
        if (_moduleRegistry == address(0)) revert ModuleRegistryNotProvided();

        moduleRegistry = ModuleRegistry(_moduleRegistry);
        owner = msg.sender;

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function createMission(MissionConfig memory config) external returns (address) {
        address eligibilityModuleAddress = moduleRegistry.get(
            Modules.CONTRIBUTOR_ELIGIBILITY_MODULE
        );
        if (eligibilityModuleAddress == address(0)) revert EligibilityModuleNotFound();
        address authModuleAddress = moduleRegistry.get(Modules.AUTHENTICATION_MODULE);
        if (authModuleAddress == address(0)) revert AuthenticationModuleNotFound();

        Mission newMission = new Mission(
            config,
            authModuleAddress,
            eligibilityModuleAddress,
            owner // Pass the owner of the MissionFactory as the mission owner
        );
        emit MissionCreated(address(newMission));
        return address(newMission);
    }
}
