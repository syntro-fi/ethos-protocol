// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {MissionConfig} from "ethos/missions/MissionConfig.sol";
import {IModule} from "ethos/modules/interfaces/IModule.sol";

import {BaseModule} from "./BaseModule.sol";

contract PassportKYCModule is BaseModule, IModule {
    error KYCFailed();

    function moduleId() public pure override returns (bytes4) {
        return bytes4(keccak256("PassportKYCModule"));
    }

    function check(address user, MissionConfig calldata config) public view override(BaseModule) {
        super.check(user, config);

        // TODO: this is just a stupid example, replace with real KYC check
        if (user != config.sponsor) revert KYCFailed();
    }
}
