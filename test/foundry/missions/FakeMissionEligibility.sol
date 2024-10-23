// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IMissionEligibility} from "ethos/missions/interfaces/IMissionEligibility.sol";
import {NotEligible} from "ethos/Errors.sol";
import {MissionConfig} from "ethos/missions/MissionConfig.sol";
import {IModule} from "ethos/modules/interfaces/IModule.sol";

contract FakeMissionEligibility is IMissionEligibility, IModule {
    bool private _isEligible;

    function check(address, MissionConfig memory) external view override {
        if (!_isEligible) revert NotEligible();
    }

    function setEligible(bool eligible) external {
        _isEligible = eligible;
    }

    function moduleId() external pure override returns (bytes4) {
        return bytes4(keccak256(abi.encodePacked("FakeMissionEligibility")));
    }
}
