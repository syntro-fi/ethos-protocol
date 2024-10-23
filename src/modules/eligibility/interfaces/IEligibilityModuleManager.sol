// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IEligibilityModuleManager {
    enum UserType {
        Contributor,
        Verifier
    }

    event ModuleEnabled(address indexed module, UserType userType);
    event ModuleDisabled(address indexed module, UserType userType);

    error InvalidModule();
    error ModuleAlreadyEnabled();
    error ModuleNotEnabled();

    function enable(address module) external;

    function disable(address module) external;

    function getEligibilityModules() external view returns (address[] memory);

    function isEligibilityModuleEnabled(address module) external view returns (bool);
}
